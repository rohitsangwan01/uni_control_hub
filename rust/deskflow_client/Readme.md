## Deskflow Client

An unofficial, community-driven [Deskflow](https://github.com/deskflow/deskflow) Client implementation in Rust

## Get started

Disable SSL in server ( Encryption not supported yet )

Connect to Deskflow server using host and port

```rust
#[tokio::main]
async fn main() {
    let (listener_tx, mut listener_rx) = mpsc::channel::<ServerUpdate>(32);
    let (server_tx, server_rx) = mpsc::channel::<Vec<u8>>(32);

    // Setup Client
    let mut client = DeskflowClient::new(
        "rust_client".to_string(),
        "192.168.1.34".to_string(),
        24800,
        listener_tx,
    );

    // Listen server updates
    let server_tx_clone = server_tx.clone();
    tokio::spawn(async move {
        while let Some(update) = listener_rx.recv().await {
            handle_updates(update, &server_tx_clone).await;
        }
    });

    // Connect to client
    if let Err(err) = client.connect(server_tx, server_rx).await {
        println!("Error: {}", err);
    }
}
```

Handle Server Updates

```rust
pub async fn handle_updates(update: ServerUpdate, server_tx: &mpsc::Sender<Vec<u8>>) {
    match update {
        // Respond to screen info query
        ServerUpdate::ScreenInfoQuery => {
            let screen_info = ScreenInfoMessage {
                screen_x: 0,
                screen_y: 0,
                screen_width: 1920,
                screen_height: 1080,
                cursor_x: 0,
                cursor_y: 0,
            };
            server_tx.send(screen_info.build()).await.unwrap();
        }
        // Handle other events
        ServerUpdate::MouseButtonDown { button_id } => println!("MouseDown: {button_id}"),
        ServerUpdate::MouseButtonUp { button_id } => println!("MouseUp: {button_id}"),
        _ => {}
    }
}
```

## Run example

```
cargo run --example client
```

## Note

- Make sure client is added in Deskflow
- Client and Server are under same network
