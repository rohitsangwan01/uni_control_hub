use super::client_handler::run_client;
use deskflow_client::{deskflow_client::DeskflowClient, server_update::ServerUpdate};
use tokio::sync::mpsc::{channel, Receiver, Sender};

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    flutter_rust_bridge::setup_default_user_utils();
}

pub async fn run_app(client_name: String, server_host: String, server_port: u16) {
    let (sender_tx, listener_rx) = connect_client(client_name, server_host, server_port).await;
    run_client(sender_tx, listener_rx).await;
}

async fn connect_client(
    client_name: String,
    server_host: String,
    server_port: u16,
) -> (Sender<Vec<u8>>, Receiver<ServerUpdate>) {
    println!("Starting Client..");
    let (server_tx, server_rx) = channel::<Vec<u8>>(32);
    let (listener_tx, listener_rx) = channel::<ServerUpdate>(32);
    let mut client = DeskflowClient::new(client_name, server_host, server_port, listener_tx);
    let server_tx_clone = server_tx.clone();
    tokio::spawn(async move {
        println!("Connecting Server..");
        if let Err(err) = client.connect(server_tx_clone, server_rx).await {
            println!("Error: {}", err);
        }
    });
    (server_tx, listener_rx)
}
