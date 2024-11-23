use super::{message::Message, message_type::MessageType};

pub struct KeepAliveMessage {}

impl KeepAliveMessage {
    pub fn new() -> Self {
        Self {}
    }
}

impl Message for KeepAliveMessage {
    fn message_type(&self) -> MessageType {
        MessageType::CKeepAlive
    }
}
