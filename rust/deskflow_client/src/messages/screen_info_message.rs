use byteorder::{BigEndian, WriteBytesExt};

use super::message::Message;
use super::message_type::MessageType;

pub struct ScreenInfoMessage {
    pub screen_x: i16,
    pub screen_y: i16,
    pub screen_width: i16,
    pub screen_height: i16,
    pub cursor_x: i16,
    pub cursor_y: i16,
}

impl Message for ScreenInfoMessage {
    fn message_type(&self) -> MessageType {
        MessageType::DInfo
    }

    fn build_data_stream(&self) -> Vec<u8> {
        let mut buffer: Vec<u8> = Vec::new();
        buffer.write_i16::<BigEndian>(self.screen_x).unwrap();
        buffer.write_i16::<BigEndian>(self.screen_y).unwrap();
        buffer.write_i16::<BigEndian>(self.screen_width).unwrap();
        buffer.write_i16::<BigEndian>(self.screen_height).unwrap();
        buffer.write_i16::<BigEndian>(0).unwrap(); // unknown
        buffer.write_i16::<BigEndian>(self.cursor_x).unwrap();
        buffer.write_i16::<BigEndian>(self.cursor_y).unwrap();
        return buffer;
    }
}
