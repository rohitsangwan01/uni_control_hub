use crate::api::events::{ClientEvent, COMBINED_REPORT};
use crate::frb_generated::StreamSink;
use anyhow::anyhow;
use anyhow::Error;
use futures::StreamExt;
use nusb::DeviceId;
use nusb::{
    transfer::{ControlOut, ControlType, Recipient},
    Device, DeviceInfo,
};
use std::sync::Arc;
use std::thread;
use std::time::Duration;
use tokio::runtime;
use tokio::sync::Mutex;

#[derive(Clone)]
#[flutter_rust_bridge::frb(opaque)]
pub struct UsbClient {
    usb_devices: Arc<Mutex<Vec<UsbDevice>>>,
}

impl UsbClient {
    pub fn new() -> Self {
        Self {
            usb_devices: Arc::new(Mutex::new(vec![])),
        }
    }

    pub async fn watch_devices(&mut self, clients_tx: StreamSink<ClientEvent>) {
        let usb_devices: Arc<Mutex<Vec<UsbDevice>>> = Arc::clone(&self.usb_devices);
        async fn get_usb_device(device: DeviceInfo) -> Option<UsbDevice> {
            let usb_device = UsbDevice::new(device).await;
            if usb_device.is_none() {
                return None;
            }
            let usb_device = usb_device.unwrap();
            let report: Vec<u8> = COMBINED_REPORT.to_vec();
            if let Err(_) = usb_device.register_hid(report).await {
                //log::error!("Error: {:?}", err);
                return None;
            }
            return Some(usb_device);
        }

        async fn on_device_connected(
            event: DeviceInfo,
            usb_devices: Arc<Mutex<Vec<UsbDevice>>>,
            clients_tx: StreamSink<ClientEvent>,
        ) {
            if let Some(usb_device) = get_usb_device(event).await {
                println!("UsbConnected: {:?}", usb_device.manufacturer);
                let id = usb_device.uid.clone();
                usb_devices.lock().await.push(usb_device);
                let _ = clients_tx.add(ClientEvent::Added(id));
            }
        }

        let clients_tx = clients_tx.clone();
        thread::spawn(move || {
            let runtime = runtime::Builder::new_current_thread().enable_time().build();
            if runtime.is_err() {
                log::error!("Failed to create runtime");
                return;
            }
            runtime.unwrap().block_on(async move {
                let devices = match nusb::list_devices().await {
                    Ok(devices) => devices,
                    Err(err) => {
                        println!("Error: {:?}", err);
                        return;
                    }
                };

                let clients_tx_1 = clients_tx.clone();
                // Load All Connected Devices first
                for device in devices {
                    on_device_connected(device, usb_devices.clone(), clients_tx_1.clone()).await;
                }

                // Watch for new devices
                let mut watcher = match nusb::watch_devices() {
                    Ok(watcher) => watcher,
                    Err(err) => {
                        println!("Error: {:?}", err);
                        return;
                    }
                };

                let clients_tx_2 = clients_tx.clone();
                while let Some(event) = watcher.next().await {
                    match event {
                        nusb::hotplug::HotplugEvent::Connected(device) => {
                            on_device_connected(device, usb_devices.clone(), clients_tx_2.clone())
                                .await;
                        }
                        nusb::hotplug::HotplugEvent::Disconnected(device) => {
                            println!("UsbDisconnected {event:?}");
                            let mut devices = usb_devices.lock().await;
                            // Get uid from device
                            let mut device_uid = None;
                            for d in devices.iter() {
                                if d.device_id == device {
                                    device_uid = Some(d.uid.clone());
                                    break;
                                }
                            }
                            // remove device from devices
                            devices.retain(|d| d.device_id != device);
                            if let Some(uid) = device_uid {
                                let _ = clients_tx.add(ClientEvent::Removed(uid));
                            }
                        }
                    }
                }
            })
        });
    }

    pub async fn send_hid_event(&mut self, event: Vec<u8>, uid: String) {
        for usb_device in self.usb_devices.lock().await.iter() {
            if usb_device.uid != uid {
                continue;
            }
            let _ = usb_device.send_hid_event(event.clone()).await;
        }
    }
}

#[flutter_rust_bridge::frb(ignore)]
struct UsbDevice {
    pub uid: String,
    pub device_id: DeviceId,
    pub device: Device,
    pub manufacturer: String,
    pub max_packet_size: usize,
    interface: Option<nusb::Interface>,
}

impl UsbDevice {
    async fn new(device_info: DeviceInfo) -> Option<Self> {
        let device = match device_info.open().await {
            Ok(dev) => dev,
            Err(e) => {
                println!("Failed to open device: {}", e);
                return None;
            }
        };
        let mut manufacturer = device_info.manufacturer_string();
        if manufacturer.is_none() {
            manufacturer = device_info.product_string();
        }
        if manufacturer.is_none() {
            println!("Manufacturer is None");
            return None;
        }

        let config = match device.active_configuration() {
            Ok(config) => config,
            Err(e) => {
                println!("Unknown active configuration: {e}");
                return None;
            }
        };

        let mut max_packet_size: usize = 0;
        for settings in config.interface_alt_settings() {
            for endpoint in settings.endpoints() {
                if endpoint.direction() == nusb::transfer::Direction::Out {
                    max_packet_size = endpoint.max_packet_size();
                    break;
                }
            }
            if max_packet_size != 0 {
                break;
            }
        }
        if max_packet_size == 0 {
            max_packet_size = 64;
        }

        // Claim Interface on Windows
        #[allow(unused_mut)]
        let mut interface: Option<nusb::Interface> = None;
        #[cfg(any(target_os = "windows"))]
        {
            let result = device.claim_interface(0);
            if result.is_ok() {
                interface = Some(result.unwrap());
            } else {
                log::debug!("Failed to claim interface: {:?}", result.err());
                return None;
            }
        }

        let uid = format!(
            "{:04X}:{:04X}",
            device_info.vendor_id(),
            device_info.product_id()
        );

        Some(Self {
            uid,
            device_id: device_info.id(),
            device,
            manufacturer: manufacturer.unwrap().to_string(),
            max_packet_size,
            interface,
        })
    }

    async fn register_hid(&self, descriptor: Vec<u8>) -> Result<(), Error> {
        let result = self
            .control_out(
                ControlType::Vendor,
                Recipient::Device,
                54,
                0,
                descriptor.len() as u16,
                vec![0; 0],
            )
            .await;
        if let Err(err) = result {
            return Err(anyhow!(format!("TransferError: {:?}", err)));
        }

        let mut offset: usize = 0;
        let size = descriptor.len();
        while offset < size {
            let packet_length = (size - offset).min(self.max_packet_size);
            let packet: Vec<u8> = descriptor.to_vec()[offset..(offset + packet_length)].to_vec();
            let result = self
                .control_out(
                    ControlType::Vendor,
                    Recipient::Device,
                    56,
                    0,
                    offset as u16,
                    packet,
                )
                .await;
            if let Err(err) = result {
                return Err(anyhow!(format!("TransferError: {:?}", err)));
            }
            offset += packet_length;
        }
        return Ok(());
    }

    #[allow(unused)]
    async fn unregister_hid(&self) -> Result<(), Error> {
        let result = self
            .device
            .control_out(
                ControlOut {
                    control_type: ControlType::Vendor,
                    recipient: Recipient::Endpoint,
                    request: 55,
                    value: 0,
                    index: 0,
                    data: &mut vec![0; 0],
                },
                Duration::from_secs(2),
            )
            .await;
        if let Err(err) = result {
            return Err(anyhow!(format!("TransferError: {:?}", err)));
        }
        return Ok(());
    }

    async fn send_hid_event(&self, event: Vec<u8>) -> Result<(), Error> {
        let result = self
            .control_out(ControlType::Vendor, Recipient::Device, 57, 0, 0, event)
            .await;
        if let Err(err) = result {
            return Err(anyhow!(format!("TransferError: {:?}", err)));
        }
        return Ok(());
    }

    async fn control_out(
        &self,
        control_type: ControlType,
        recipient: Recipient,
        request: u8,
        value: u16,
        index: u16,
        data: Vec<u8>,
    ) -> Result<(), nusb::transfer::TransferError> {
        let timeout = Duration::from_secs(2);
        let control_out = ControlOut {
            control_type,
            recipient,
            request,
            value,
            index,
            data: &data,
        };
        // Linux/Macos can make control transfers without claiming an interface
        #[cfg(any(target_os = "linux", target_os = "macos"))]
        {
            return self.device.control_out(control_out, timeout).await;
        }
        // Windows have to claim interface first
        #[allow(unreachable_code)]
        if let Some(interface) = self.interface.clone() {
            return interface.control_out(control_out, timeout).await;
        } else {
            log::error!("Failed to find the claimed interface");
            return Err(nusb::transfer::TransferError::Fault);
        }
    }
}
