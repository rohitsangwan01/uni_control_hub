use std::io::Cursor;

use byteorder::{BigEndian, ReadBytesExt};
use tokio::sync::mpsc;

use crate::{
    messages::{keep_alive_message::KeepAliveMessage, message::Message, message_type::MessageType},
    server_update::ServerUpdate,
};

#[derive(Debug, Clone)]
pub struct ServerProxy {
    listener_tx: mpsc::Sender<ServerUpdate>,
    server_tx: mpsc::Sender<Vec<u8>>,
}

impl ServerProxy {
    pub fn new(listener_tx: mpsc::Sender<ServerUpdate>, server_tx: mpsc::Sender<Vec<u8>>) -> Self {
        Self {
            listener_tx,
            server_tx,
        }
    }

    pub async fn handle_data(&self, message_type: MessageType, body: Vec<u8>) {
        // Reply Ping
        match message_type {
            MessageType::CKeepAlive => {
                self.server_tx
                    .send(KeepAliveMessage::new().build())
                    .await
                    .unwrap();
                return;
            }
            _ => {}
        }

        // Parse Messages
        let mut cursor = Cursor::new(body);
        let server_update: Option<ServerUpdate> = match message_type {
            MessageType::QInfo => Some(ServerUpdate::ScreenInfoQuery),
            MessageType::CInfoAck => Some(ServerUpdate::InfoAck),
            MessageType::CResetOptions => Some(ServerUpdate::ResetOptions),
            MessageType::CEnter => Some(ServerUpdate::Enter {
                x: cursor.read_i16::<BigEndian>().unwrap_or(0),
                y: cursor.read_i16::<BigEndian>().unwrap_or(0),
                sequence_number: cursor.read_i32::<BigEndian>().unwrap_or(0),
                toggle_mask: cursor.read_i16::<BigEndian>().unwrap_or(0),
            }),
            MessageType::CLeave => Some(ServerUpdate::Leave),
            MessageType::CClipboard => {
                let id = cursor.read_u8().unwrap_or(0);
                println!("GrabClipboard: {}", id);
                None
            }
            MessageType::DMouseMove => Some(ServerUpdate::MousePositionUpdate {
                x: cursor.read_i16::<BigEndian>().unwrap_or(0),
                y: cursor.read_i16::<BigEndian>().unwrap_or(0),
            }),
            MessageType::DMouseRelMove => Some(ServerUpdate::MouseRelativeMove {
                x: cursor.read_i16::<BigEndian>().unwrap_or(0),
                y: cursor.read_i16::<BigEndian>().unwrap_or(0),
            }),
            MessageType::DMouseDown => Some(ServerUpdate::MouseButtonDown {
                button_id: cursor.read_u8().unwrap_or(0),
            }),
            MessageType::DMouseUp => Some(ServerUpdate::MouseButtonUp {
                button_id: cursor.read_u8().unwrap_or(0),
            }),
            MessageType::DMouseWheel => Some(ServerUpdate::MouseWheel {
                x: cursor.read_i16::<BigEndian>().unwrap_or(0),
                y: cursor.read_i16::<BigEndian>().unwrap_or(0),
            }),
            MessageType::DKeyDown => Some(ServerUpdate::KeyDown {
                key_event_id: cursor.read_u16::<BigEndian>().unwrap_or(0),
                mask: cursor.read_u16::<BigEndian>().unwrap_or(0),
                button: cursor.read_u16::<BigEndian>().unwrap_or(0),
            }),
            MessageType::DKeyDownLang => Some(ServerUpdate::KeyDown {
                key_event_id: cursor.read_u16::<BigEndian>().unwrap_or(0),
                mask: cursor.read_u16::<BigEndian>().unwrap_or(0),
                button: cursor.read_u16::<BigEndian>().unwrap_or(0),
            }),
            MessageType::DKeyUp => Some(ServerUpdate::KeyUp {
                key_event_id: cursor.read_u16::<BigEndian>().unwrap_or(0),
                mask: cursor.read_u16::<BigEndian>().unwrap_or(0),
                button: cursor.read_u16::<BigEndian>().unwrap_or(0),
            }),
            MessageType::DKeyRepeat => Some(ServerUpdate::KeyRepeat {
                key_event_id: cursor.read_u16::<BigEndian>().unwrap_or(0),
                mask: cursor.read_u16::<BigEndian>().unwrap_or(0),
                count: cursor.read_u16::<BigEndian>().unwrap_or(0),
                button: cursor.read_u16::<BigEndian>().unwrap_or(0),
            }),
            _ => {
                println!("Unhandled Message: {:?}", message_type);
                None
            }
        };
        if let Some(update) = server_update {
            if let Err(err) = self.listener_tx.send(update).await {
                println!("Error: {}", err);
            }
        }
    }
}
