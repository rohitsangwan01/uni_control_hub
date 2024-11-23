use crate::messages::message_type::MessageType;

#[derive(Debug, Clone, Copy)]
pub enum ServerType {
    Synergy,
    Barrier,
}

impl ServerType {
    pub fn hello_back_message(&self) -> MessageType {
        match self {
            ServerType::Synergy => MessageType::HelloBackSynergy,
            ServerType::Barrier => MessageType::HelloBackBarrier,
        }
    }

    pub fn values() -> [ServerType; 2] {
        [ServerType::Synergy, ServerType::Barrier]
    }
}
