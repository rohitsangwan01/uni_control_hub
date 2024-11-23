use deskflow_client::deskflow_client::DeskflowClient;
use deskflow_client::server_update::ServerUpdate;
use std::io::{BufRead, BufReader};
use std::process::{Child, Command, Stdio};
use std::time::Duration;
use tokio::sync::mpsc::{channel, Receiver, Sender};
use tokio::time::sleep;

const CLIENT_NAME: &str = "rust_client";
const SERVER_HOST: &str = "127.0.0.1";
const SERVER_PORT: u16 = 24800;

pub struct DeskflowServer {
    command: Option<Child>,
}

impl DeskflowServer {
    pub fn new() -> Self {
        Self { command: None }
    }

    pub async fn connect_client(&mut self) -> (Sender<Vec<u8>>, Receiver<ServerUpdate>) {
        println!("Starting Server..");

        self.start_server().await;
        sleep(Duration::from_secs(1)).await;
        println!("Starting Client..");

        let (server_tx, server_rx) = channel::<Vec<u8>>(32);
        let (listener_tx, listener_rx) = channel::<ServerUpdate>(32);

        let mut client = DeskflowClient::new(
            CLIENT_NAME.to_string(),
            SERVER_HOST.to_string(),
            SERVER_PORT,
            listener_tx,
        );

        let server_tx_clone = server_tx.clone();
        tokio::spawn(async move {
            println!("Connecting Server..");
            if let Err(err) = client.connect(server_tx_clone, server_rx).await {
                println!("Error: {}", err);
            }
        });
        (server_tx, listener_rx)
    }

    async fn start_server(&mut self) {
        let base_path = "deskflow";
        let address = format!("{}:{}", SERVER_HOST, SERVER_PORT);
        let config = format!("{base_path}/deskflow-server.conf");
        let args = vec![
            "-f",
            "--no-tray",
            "--debug",
            "INFO",
            "--name",
            "macbook",
            "--address",
            address.as_str(),
            "-c",
            config.as_str(),
        ];
        let mut command = Command::new(format!("{base_path}/deskflow-server"))
            .args(args)
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .expect("Failed to execute command");

        let stdout = command.stdout.take().unwrap();
        let stderr = command.stderr.take().unwrap();

        tokio::spawn(async move {
            let reader = BufReader::new(stdout);
            for line in reader.lines() {
                if let Ok(line) = line {
                    println!("stdout: {}", line);
                };
            }
        });

        tokio::spawn(async move {
            let reader = BufReader::new(stderr);
            for line in reader.lines() {
                println!("stderr: {}", line.unwrap());
            }
        });

        self.command = Some(command);
    }

    async fn stop_server(&mut self) {
        if let Some(mut command) = self.command.take() {
            command.kill().unwrap();
            self.command = None;
        }
    }
}
