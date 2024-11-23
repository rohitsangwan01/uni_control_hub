mod clients;
mod deskflow_server;
mod hid_report;

use clients::{ble::BleClient, usb::UsbClient};
// use clients::usb::UsbClient;
use deskflow_client::{
    messages::{message::Message, screen_info_message::ScreenInfoMessage},
    server_update::ServerUpdate,
};
use deskflow_server::DeskflowServer;
use tokio::sync::mpsc;

pub async fn run_client() {
    let mut client: BleClient = BleClient::new().await;
   // let mut client: UsbClient = UsbClient::new();

    let mut relative_x: i16 = 0;
    let mut relative_y: i16 = 0;
    let mut button_pressed: u8 = 0;

    if let Err(err) = client.load_devices().await {
        println!("Error loading devices: {}", err);
        return;
    }
    let (server_tx, mut listener_rx) = DeskflowServer::new().connect_client().await;

    println!("Starting loop");
    while let Some(update) = listener_rx.recv().await {
        match update {
            ServerUpdate::ScreenInfoQuery => update_display_info(&server_tx).await,
            ServerUpdate::MousePositionUpdate { x, y } => {
                let relative_x_movement = x - relative_x;
                let relative_y_movement = y - relative_y;
                let event: Vec<u8> = vec![
                    0x02,
                    button_pressed,
                    relative_x_movement as u8,
                    relative_y_movement as u8,
                    0,
                ];
                if let Err(err) = client.send_hid_event(event).await {
                    println!("Error: {}", err);
                }
                relative_x = x;
                relative_y = y;
            }
            ServerUpdate::MouseButtonDown { button_id } => {
                let event: Vec<u8> = vec![0x02, button_id, 0, 0, 0];
                if let Err(err) = client.send_hid_event(event).await {
                    println!("Error: {}", err);
                }
                button_pressed = button_id
            }
            ServerUpdate::MouseButtonUp { button_id } => {
                let event: Vec<u8> = vec![0x02, 0, 0, 0, 0];
                if let Err(err) = client.send_hid_event(event).await {
                    println!("Error: {} {button_id}", err);
                }
                button_pressed = 0;
            }
            _ => {
                println!("Update: {:?}", update);
            }
        }
    }
}

async fn update_display_info(server_tx: &mpsc::Sender<Vec<u8>>) {
    let screen_info = ScreenInfoMessage {
        screen_x: 0,
        screen_y: 0,
        screen_width: 1920 as i16,
        screen_height: 1080 as i16,
        cursor_x: 0,
        cursor_y: 0,
    };
    server_tx.send(screen_info.build()).await.unwrap();
}
