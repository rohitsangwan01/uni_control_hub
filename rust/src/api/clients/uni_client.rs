use nusb::DeviceId;

#[derive(Debug, Clone)]
pub enum ClientEvent {
    Added(ClientType),
    Removed(ClientType),
}

#[derive(Debug, Clone)]
pub enum ClientType {
    Usb(DeviceId),
    Ble(String),
}
