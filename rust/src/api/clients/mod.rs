pub mod ble;
pub mod uni_client;
pub mod usb;

use crate::api::lan_mouse_capture::CaptureRequest;
use ble::BleClient;
use input_capture::Position;
use std::{collections::HashMap, sync::Arc};
use tokio::sync::{
    mpsc::{self, Sender},
    Mutex,
};
use uni_client::{ClientEvent, ClientType};
use usb::UsbClient;

pub struct ClientHandler {
    clients_map: Arc<Mutex<HashMap<Position, ClientType>>>,
    usb_client: UsbClient,
    ble_client: BleClient,
    sender_tx: Option<Sender<ClientEvent>>,
}

impl ClientHandler {
    pub async fn new() -> Self {
        let usb_client = usb::UsbClient::new();
        let ble_client = BleClient::new().await;
        Self {
            clients_map: Arc::new(Mutex::new(HashMap::new())),
            usb_client,
            ble_client,
            sender_tx: None,
        }
    }

    pub async fn run(&mut self, capture_tx: Sender<CaptureRequest>) {
        let clients_map_clone = self.clients_map.clone();
        let (client_tx, mut client_rx) = mpsc::channel(100);
        self.sender_tx = Some(client_tx);
        tokio::spawn(async move {
            while let Some(event) = client_rx.recv().await {
                match event {
                    ClientEvent::Added(client) => {
                        let mut map = clients_map_clone.lock().await;
                        // TODO: Decide
                        let pos = Position::Left;
                        map.insert(pos, client.clone());
                        println!("ClientAdded {:?}", client);
                        let _ = capture_tx.send(CaptureRequest::Create(pos)).await;
                    }
                    ClientEvent::Removed(client) => {
                        let mut map = clients_map_clone.lock().await;
                        // TODO: remove this client from map, detect its position
                        let pos: Position = Position::Left;
                        map.remove(&pos);
                        println!("ClientRemoved {client:?}");
                        let _ = capture_tx.send(CaptureRequest::Destroy(pos)).await;
                    }
                }
            }
        });
    }

    pub fn stop(&mut self) {
        // Stop listeners
    }

    pub async fn watch_ble_devices(&mut self) {
        if let Some(sender_tx) = self.sender_tx.clone() {
            self.ble_client.watch_devices(sender_tx).await;
        } else {
            println!("sender_tx is none")
        }
    }

    pub async fn watch_usb_devices(&mut self) {
        if let Some(sender_tx) = self.sender_tx.clone() {
            println!("Start watch");
            self.usb_client.watch_devices(sender_tx).await;
        } else {
            println!("sender_tx is none")
        }
    }

    pub async fn send_hid_event(&mut self, event: Vec<u8>, position: Position) {
        let map = self.clients_map.lock().await;
        let client = map.get(&position);
        if client.is_none() {
            return;
        }
        match client.unwrap() {
            ClientType::Usb(id) => self.usb_client.send_hid_event(event, id.clone()).await,
            ClientType::Ble(id) => self.ble_client.send_hid_event(event, id.clone()).await,
        }
    }
}
