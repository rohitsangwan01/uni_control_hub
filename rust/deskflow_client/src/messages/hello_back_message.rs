use byteorder::{BigEndian, WriteBytesExt};
use std::io::Write;

use super::{message::Message, message_type::MessageType, server_type::ServerType};

pub struct HelloBackMessage {
    pub major_version: i16,
    pub minor_version: i16,
    pub name: String,
    pub server_type: ServerType,
}

impl Message for HelloBackMessage {
    fn message_type(&self) -> MessageType {
        self.server_type.hello_back_message()
    }

    fn build_data_stream(&self) -> Vec<u8> {
        let mut buffer: Vec<u8> = Vec::new();
        buffer.write_i16::<BigEndian>(self.major_version).unwrap();
        buffer.write_i16::<BigEndian>(self.minor_version).unwrap();

        buffer
            .write_u32::<BigEndian>(self.name.as_bytes().len() as u32)
            .unwrap();
        buffer.write_all(self.name.as_bytes()).unwrap();
        return buffer;
    }
}
