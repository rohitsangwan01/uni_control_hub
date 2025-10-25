use crate::api::clients::ClientHandler;
use crate::api::lan_mouse_capture::InputHandler;
use crate::api::uni_event;
use env_logger::Env;
use input_capture::Position;
use tokio::sync::mpsc::{self, Receiver, Sender};
use tokio::{runtime::Builder, task::LocalSet};
use uni_event::{UniClientEvent, UniServerEvent};

#[flutter_rust_bridge::frb(init)]
pub fn init_app() {
    // Default utilities - feel free to customize
    flutter_rust_bridge::setup_default_user_utils();
}

#[flutter_rust_bridge::frb(sync)] // Synchronous mode for simplicity of the demo
pub fn greet(name: String) -> String {
    format!("Hello, {name}!")
}

// Connect using event channels
pub async fn connect(mut rx: Receiver<UniClientEvent>, clients_tx: Sender<UniServerEvent>) {
    println!("Running Client");
    let (stream_tx, mut stream_rx) = mpsc::channel::<(Position, Vec<u8>)>(100);
    let mut input_handler = InputHandler::new();
    let mut client_handler = ClientHandler::new().await;

    loop {
        tokio::select! {
            Some((position, event)) = stream_rx.recv() => {
                client_handler.send_hid_event(event, position).await;
            }
            Some(data) = rx.recv() => {
                println!("Data From Client: {data:?}");
                match data {
                    UniClientEvent::Ping => {
                        clients_tx.send(UniServerEvent::Pong).await.unwrap();
                    }
                    UniClientEvent::StartApp => {
                        let control = input_handler.run(stream_tx.clone()).await.unwrap();
                        client_handler.run(control).await;
                    }
                    UniClientEvent::StopApp => {
                        // Handle Stop App
                        input_handler.stop();
                        client_handler.stop();
                    }
                    UniClientEvent::WatchUsb => {
                        // Handle Watch USB
                        client_handler.watch_usb_devices().await;
                    }
                    UniClientEvent::WatchBle => {
                        // Handle Watch BLE
                        client_handler.watch_ble_devices().await;
                    }
                }
            }
            else => break
        }
    }

    log::info!("Connection Closed");
}

pub async fn start_app() {
    // init logging
    let env = Env::default().filter_or("RUST_LOG", "error");
    env_logger::init_from_env(env);

    let (client_tx, client_rx) = tokio::sync::mpsc::channel(100);
    let (server_tx, mut server_rx) = tokio::sync::mpsc::channel(100);

    let runtime = Builder::new_current_thread().enable_all().build().unwrap();
    std::thread::spawn(move || {
        let local = LocalSet::new();
        local.spawn_local(async move {
            let _ = tokio::task::spawn_local(async move { connect(client_rx, server_tx).await });
        });
        runtime.block_on(local);
    });

    // start app
    let _ = client_tx.send(uni_event::UniClientEvent::StartApp).await;
    let _ = client_tx.send(uni_event::UniClientEvent::WatchUsb).await;
    // let _ = client_tx.send(uni_event::UniClientEvent::WatchBle).await;

    // stop app after 5 sec without block
    // tokio::spawn(async move {
    //     tokio::time::sleep(std::time::Duration::from_secs(10)).await;
    //     println!("Stopping app");
    //     let _ = client_tx.send(uni_event::UniClientEvent::StopApp).await;
    // });

    println!("Getting data");
    while let Some(event) = server_rx.recv().await {
        println!("Data From Server: {event:?}");
    }
}
