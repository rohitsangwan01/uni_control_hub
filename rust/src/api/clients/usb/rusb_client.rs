// use crate::hid_report::COMBINED_REPORT;
// use anyhow::Error;
// use rusb::{
//     constants::{LIBUSB_ENDPOINT_OUT, LIBUSB_REQUEST_TYPE_VENDOR},
//     Context, Device, DeviceDescriptor, DeviceHandle, GlobalContext, Hotplug, UsbContext,
// };
// use std::{thread::sleep, time::Duration};

// pub struct UsbClient {
//     usb_devices: Vec<UsbDevice>,
// }

// impl UsbClient {
//     pub fn new() -> Self {
//         Self {
//             usb_devices: vec![],
//         }
//     }
//     async fn load_devices(&mut self) -> Result<(), Error> {
//         for device in rusb::devices().unwrap().iter() {
//             if let Some(usb_device) = self.get_usb_device(device) {
//                 self.usb_devices.push(usb_device);
//             }
//         }
//         Ok(())
//     }

//     async fn send_hid_event(&self, event: Vec<u8>) -> Result<(), Error> {
//         for usb_device in self.usb_devices.iter() {
//             usb_device.send_hid_event(event.clone())?;
//         }
//         Ok(())
//     }

//     fn get_usb_device(&mut self, device: Device<GlobalContext>) -> Option<UsbDevice> {
//         let usb_device = UsbDevice::new(device);
//         if usb_device.is_none() {
//             return None;
//         }

//         let usb_device = usb_device.unwrap();
//         println!("UsbDevice: {:?}", usb_device.manufacturer);

//         let report: Vec<u8> = COMBINED_REPORT.to_vec();
//         if let Err(err) = usb_device.register_hid(report) {
//             println!("Error: {:?}", err);
//             return None;
//         }
//         return Some(usb_device);
//     }

//     fn register_hotplug() -> Result<(), rusb::Error> {
//         let context = Context::new()?;
//         let mut reg = Some(
//             rusb::HotplugBuilder::new()
//                 .enumerate(true)
//                 .register(&context, Box::new(HotPlugHandler {}))?,
//         );

//         loop {
//             context.handle_events(None).unwrap();
//             if let Some(reg) = reg.take() {
//                 context.unregister_callback(reg);
//                 break;
//             }
//         }
//         Ok(())
//     }
// }

// pub struct UsbDevice {
//     pub handle: DeviceHandle<GlobalContext>,
//     pub descriptor: DeviceDescriptor,
//     pub manufacturer: String,
// }

// impl UsbDevice {
//     pub fn new(device: Device<GlobalContext>) -> Option<Self> {
//         let device_desc = device.device_descriptor();
//         if device_desc.is_err() {
//             return None;
//         }
//         let descriptor = device_desc.unwrap();
//         let handle_response =
//             rusb::open_device_with_vid_pid(descriptor.vendor_id(), descriptor.product_id());
//         if handle_response.is_none() {
//             return None;
//         }
//         let handle = handle_response.unwrap();
//         let manufacturer_result = handle.read_manufacturer_string_ascii(&descriptor);
//         if manufacturer_result.is_err() {
//             return None;
//         }
//         let manufacturer = manufacturer_result.unwrap();
//         Some(Self {
//             handle,
//             descriptor,
//             manufacturer,
//         })
//     }

//     pub fn register_hid(&self, descriptor: Vec<u8>) -> Result<(), rusb::Error> {
//         if let Err(err) = self.handle.write_control(
//             LIBUSB_ENDPOINT_OUT | LIBUSB_REQUEST_TYPE_VENDOR,
//             54,
//             0,
//             descriptor.len() as u16,
//             &mut vec![0; 0],
//             Duration::from_secs(2),
//         ) {
//             return Err(err);
//         }

//         let max_packet_size = self.descriptor.max_packet_size() as usize;
//         let mut offset: usize = 0;
//         let size = descriptor.len();
//         while offset < size {
//             println!(
//                 "Offset: {}, Size: {}, MaxPacketSize: {}",
//                 offset, size, max_packet_size
//             );
//             let packet_length = (size - offset).min(max_packet_size);
//             let packet = &mut descriptor.to_vec()[offset..(offset + packet_length)];
//             if let Err(err) = self.handle.write_control(
//                 LIBUSB_ENDPOINT_OUT | LIBUSB_REQUEST_TYPE_VENDOR,
//                 56,
//                 0,
//                 offset as u16,
//                 packet,
//                 Duration::from_secs(2),
//             ) {
//                 return Err(err);
//             }
//             offset += packet_length;
//         }
//         sleep(Duration::from_millis(500));
//         return Ok(());
//     }

//     pub fn unregister_hid(&self) -> Result<usize, rusb::Error> {
//         return self.handle.write_control(
//             LIBUSB_ENDPOINT_OUT | LIBUSB_REQUEST_TYPE_VENDOR,
//             55,
//             0,
//             0,
//             &mut vec![0; 0],
//             Duration::from_secs(2),
//         );
//     }

//     pub fn send_hid_event(&self, event: Vec<u8>) -> Result<usize, rusb::Error> {
//         return self.handle.write_control(
//             LIBUSB_ENDPOINT_OUT | LIBUSB_REQUEST_TYPE_VENDOR,
//             57,
//             0,
//             0,
//             &mut event.to_vec(),
//             Duration::from_secs(2),
//         );
//     }
// }

// struct HotPlugHandler;

// impl<T: UsbContext> Hotplug<T> for HotPlugHandler {
//     fn device_arrived(&mut self, device: Device<T>) {
//         println!("device arrived {:?}", device);
//     }

//     fn device_left(&mut self, device: Device<T>) {
//         println!("device left {:?}", device);
//     }
// }
