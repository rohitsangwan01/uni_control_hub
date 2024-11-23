use crate::hid_report::COMBINED_REPORT;
use anyhow::anyhow;
use anyhow::Error;
use futures::StreamExt;
use nusb::{
    transfer::{Completion, ControlOut, ControlType, Recipient, ResponseBuffer},
    Device, DeviceInfo,
};

pub struct UsbClient {
    usb_devices: Vec<UsbDevice>,
}

impl UsbClient {
    pub fn new() -> Self {
        Self {
            usb_devices: vec![],
        }
    }

    pub async fn load_devices(&mut self) -> Result<(), Error> {
        for device in nusb::list_devices().unwrap() {
            if let Some(usb_device) = self.get_usb_device(device).await {
                println!("GotDevice: {:?}", usb_device.manufacturer);
                self.usb_devices.push(usb_device);
            }
        }

        tokio::spawn(async move {
            let mut watcher = nusb::watch_devices().unwrap();
            while let Some(event) = watcher.next().await {
                println!("HotplugEvent: {event:?}");
            }
        });
        Ok(())
    }

    pub async fn get_usb_device(&mut self, device: DeviceInfo) -> Option<UsbDevice> {
        let usb_device = UsbDevice::new(device);
        if usb_device.is_none() {
            return None;
        }

        let usb_device = usb_device.unwrap();

        let report: Vec<u8> = COMBINED_REPORT.to_vec();
        if let Err(err) = usb_device.register_hid(report).await {
            println!("Error: {:?}", err);
            return None;
        }
        return Some(usb_device);
    }

    pub async fn send_hid_event(&self, event: Vec<u8>) -> Result<(), Error> {
        for usb_device in self.usb_devices.iter() {
            usb_device.send_hid_event(event.clone()).await?;
        }
        Ok(())
    }
}

pub struct UsbDevice {
    pub device: Device,
    pub manufacturer: String,
    pub max_packet_size: usize,
}

impl UsbDevice {
    pub fn new(device_info: DeviceInfo) -> Option<Self> {
        let device = match device_info.open() {
            Ok(dev) => dev,
            Err(e) => {
                println!("Failed to open device: {}", e);
                return None;
            }
        };
        let manufacturer = device_info.manufacturer_string();
        if manufacturer.is_none() {
            return None;
        }

        let config = match device.active_configuration() {
            Ok(config) => config,
            Err(e) => {
                println!("Unknown active configuration: {e}");
                return None;
            }
        };

        let mut max_packet_size = 64;
        for settings in config.interface_alt_settings() {
            for endpoint in settings.endpoints() {
                if endpoint.direction() == nusb::transfer::Direction::Out {
                    max_packet_size = endpoint.max_packet_size();
                    break;
                }
            }
        }

        Some(Self {
            device,
            manufacturer: manufacturer.unwrap().to_string(),
            max_packet_size,
        })
    }

    pub async fn register_hid(&self, descriptor: Vec<u8>) -> Result<(), Error> {
        let result: Completion<ResponseBuffer> = self
            .device
            .control_out(ControlOut {
                control_type: ControlType::Vendor,
                recipient: Recipient::Device,
                request: 54,
                value: 0,
                index: descriptor.len() as u16,
                data: &mut vec![0; 0],
            })
            .await;
        if let Err(err) = result.status {
            return Err(anyhow!(format!("TransferError: {:?}", err)));
        }

        let mut offset: usize = 0;
        let size = descriptor.len();
        while offset < size {
            let packet_length = (size - offset).min(self.max_packet_size);
            let packet = &mut descriptor.to_vec()[offset..(offset + packet_length)];

            let result: Completion<ResponseBuffer> = self
                .device
                .control_out(ControlOut {
                    control_type: ControlType::Vendor,
                    recipient: Recipient::Device,
                    request: 56,
                    value: 0,
                    index: offset as u16,
                    data: packet,
                })
                .await;
            if let Err(err) = result.status {
                return Err(anyhow!(format!("TransferError: {:?}", err)));
            }
            offset += packet_length;
        }
        return Ok(());
    }

    pub async fn unregister_hid(&self) -> Result<(), Error> {
        let result = self
            .device
            .control_out(ControlOut {
                control_type: ControlType::Vendor,
                recipient: Recipient::Endpoint,
                request: 55,
                value: 0,
                index: 0,
                data: &mut vec![0; 0],
            })
            .await;
        if let Err(err) = result.status {
            return Err(anyhow!(format!("TransferError: {:?}", err)));
        }
        return Ok(());
    }

    pub async fn send_hid_event(&self, event: Vec<u8>) -> Result<(), Error> {
        let result = self
            .device
            .control_out(ControlOut {
                control_type: ControlType::Vendor,
                recipient: Recipient::Device,
                request: 57,
                value: 0,
                index: 0,
                data: &mut event.to_vec(),
            })
            .await;
        if let Err(err) = result.status {
            return Err(anyhow!(format!("TransferError: {:?}", err)));
        }
        return Ok(());
    }
}
