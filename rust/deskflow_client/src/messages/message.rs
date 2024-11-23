use byteorder::{BigEndian, WriteBytesExt};

use super::message_type::MessageType;

pub trait Message {
    fn message_type(&self) -> MessageType;
    fn build_data_stream(&self) -> Vec<u8> {
        return Vec::new();
    }

    fn build(&self) -> Vec<u8> {
        let data_stream = self.build_data_stream();
        let message_type = self.message_type();
        let mut result = Vec::new();
        result
            .write_u32::<BigEndian>((data_stream.len() + message_type.to_str().len()) as u32)
            .unwrap();
        result.extend_from_slice(message_type.to_str().as_bytes());
        result.extend_from_slice(&data_stream);
        result
    }
}
