use crate::messages::hello_back_message::HelloBackMessage;
use crate::messages::message::Message;
use crate::messages::{hello_message::HelloMessage, message_type::MessageType};
use crate::server_proxy::{self, ServerProxy};
use crate::server_update::ServerUpdate;
use byteorder::BigEndian;
use std::io::{self, Cursor};
use tokio::sync::mpsc;

use tokio::{
    io::{AsyncReadExt, AsyncWriteExt},
    net::{
        tcp::{OwnedReadHalf, OwnedWriteHalf},
        TcpStream,
    },
};

const _HELLO_MESSAGE_SIZE: usize = 11;
const _HEADER_MESSAGE_SIZE: usize = 4;

#[derive(Debug, Clone)]
pub struct DeskflowClient {
    name: String,
    host: String,
    port: u16,
    listener: mpsc::Sender<ServerUpdate>,
}

impl DeskflowClient {
    pub fn new(
        name: String,
        host: String,
        port: u16,
        listener: mpsc::Sender<ServerUpdate>,
    ) -> Self {
        Self {
            name,
            host,
            port,
            listener,
        }
    }

    pub async fn connect(
        &mut self,
        server_tx: mpsc::Sender<Vec<u8>>,
        mut server_rx: mpsc::Receiver<Vec<u8>>,
    ) -> io::Result<()> {
        let addr = format!("{}:{}", self.host.clone(), self.port);
        let stream = TcpStream::connect(&addr).await?;
        let mut split_stream: (OwnedReadHalf, OwnedWriteHalf) = stream.into_split();

        let mut buf = [0; 1024];
        let server_proxy: ServerProxy = ServerProxy::new(self.listener.clone(), server_tx.clone());

        // Write back to socket
        tokio::spawn(async move {
            while let Some(update) = server_rx.recv().await {
                split_stream.1.write_all(&update).await.unwrap();
            }
        });

        // Listen to sockets
        loop {
            let result = split_stream.0.read(&mut buf).await;
            if let Err(e) = result {
                println!("Error reading from stream: {}", e);
                break;
            }
            let n = result.unwrap();
            if n == 0 {
                println!("Connection closed");
                break;
            }

            let server_tx_clone = server_tx.clone();
            let mut server_proxy_clone = server_proxy.clone();
            let name = self.name.clone();
            tokio::spawn(async move {
                _handle_socket(name, &buf[..n], server_tx_clone, &mut server_proxy_clone).await;
            });
        }
        Ok(())
    }
}

async fn _handle_socket(
    name: String,
    mut data: &[u8],
    server_tx: mpsc::Sender<Vec<u8>>,
    server_proxy: &mut server_proxy::ServerProxy,
) {
    while !data.is_empty() {
        let mut din = Cursor::new(data);
        let message_size =
            byteorder::ReadBytesExt::read_u32::<BigEndian>(&mut din).unwrap() as usize;

        if data.len() < message_size {
            println!(
                "Unhandled Data: ExpectedSize: {} AvailableSize: {}",
                message_size,
                data.len()
            );
            return;
        }

        // Handle Hello Message
        if message_size == _HELLO_MESSAGE_SIZE {
            let hello_message = HelloMessage::new(data).unwrap();
            println!("{:?}", hello_message);
            server_tx
                .send(
                    HelloBackMessage {
                        major_version: 1,
                        minor_version: 6,
                        name: name.to_string(),
                        server_type: hello_message.server_type,
                    }
                    .build(),
                )
                .await
                .unwrap();
            return;
        }

        if data.len() < _HEADER_MESSAGE_SIZE * 2 {
            println!("InvalidData: {:?}", data);
            return;
        }

        let message_type_str =
            std::str::from_utf8(&data[_HEADER_MESSAGE_SIZE.._HEADER_MESSAGE_SIZE * 2]).unwrap();

        let message_type_result = MessageType::from_str(message_type_str);

        if message_type_result.is_err() {
            println!("Failed to identify message type: ${message_type_str}");
            return;
        }

        let message_type = message_type_result.unwrap();
        let total_size = message_size + _HEADER_MESSAGE_SIZE;
        let body_bytes: &[u8] = &data[_HEADER_MESSAGE_SIZE * 2..total_size];

        server_proxy
            .handle_data(message_type, body_bytes.to_vec())
            .await;

        let total_size = message_size + _HEADER_MESSAGE_SIZE;
        // Update data for the next iteration
        if data.len() > total_size {
            data = &data[total_size..];
        } else {
            data = &[];
        }
    }
}
