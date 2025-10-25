use crate::api::rx_handlers::{PositionVecU8Receiver, PositionVecU8Sender};
use anyhow::Ok;
use futures::StreamExt;
pub use input_capture::Position;
use input_capture::{self, CaptureEvent, CaptureHandle, InputCapture};
use input_event::{Event, KeyboardEvent, PointerEvent};
use std::collections::HashMap;
pub use tokio::sync::mpsc::{self, Receiver, Sender};
use tokio::{runtime::Builder, task::LocalSet};
use tokio_util::sync::CancellationToken;

// Mirror of position
#[flutter_rust_bridge::frb(mirror(Position))]
pub enum _Position {
    Left,
    Right,
    Top,
    Bottom,
}

#[derive(Clone, Copy, Debug)]
pub enum CaptureRequest {
    Release,
    Create(Position),
    Destroy(Position),
}

#[derive(Clone)]
#[flutter_rust_bridge::frb(opaque)]
pub struct InputHandler {
    capture_tx: Option<Sender<CaptureRequest>>,
    cancel: Option<CancellationToken>,
}

impl InputHandler {
    #[flutter_rust_bridge::frb(sync)]
    pub fn new() -> Self {
        Self {
            capture_tx: None,
            cancel: None,
        }
    }

    pub async fn send_capture_request(&self, request: CaptureRequest) {
        if let Some(capture_tx) = self.capture_tx.clone() {
            let _ = capture_tx.send(request).await;
        }
    }

    pub async fn create_position_stream(&self) -> (PositionVecU8Sender, PositionVecU8Receiver) {
        let (sender, receiver) = mpsc::channel::<(Position, Vec<u8>)>(100);
        (PositionVecU8Sender(sender), PositionVecU8Receiver(receiver))
    }

    pub async fn run(&mut self, position_stream: PositionVecU8Sender) {
        println!("Running Capture Task print");
        let (capture_tx, capture_rx) = mpsc::channel::<CaptureRequest>(100);
        let cancel = CancellationToken::new();
        self.cancel = Some(cancel.clone());
        self.capture_tx = Some(capture_tx);
        let runtime = Builder::new_current_thread().enable_all().build().unwrap();
        std::thread::spawn(move || {
            let local = LocalSet::new();
            local.spawn_local(async move {
                if let Err(err) = capture_task(cancel, position_stream.clone(), capture_rx).await {
                    println!("Error {err}");
                }
            });
            runtime.block_on(local);
        });
    }

    pub fn stop(&mut self) {
        if let Some(token) = self.cancel.clone() {
            token.cancel();
        }
        self.capture_tx = None;
        self.cancel = None;
    }
}

/// Start capture task and all communication with Input
async fn capture_task(
    cancel: CancellationToken,
    position_stream: PositionVecU8Sender,
    mut notify_rx: Receiver<CaptureRequest>,
) -> anyhow::Result<()> {
    let mut capture = InputCapture::new(None).await?;
    let mut clients_map: HashMap<CaptureHandle, Position> = HashMap::new();
    let mut client_dx: f64 = 0.0;
    let mut client_dy: f64 = 0.0;
    let mut button_pressed: u8 = 0;

    loop {
        tokio::select! {
            event = capture.next() => match event {
                Some(event) => {
                    let (handle, capture_event) =  event?;

                    match capture_event {
                        CaptureEvent::Begin => {
                            client_dx = 0.0;
                            client_dy = 0.0;
                        },
                        CaptureEvent::Input(capture_input) => {
                            if let Event::Pointer(PointerEvent::Motion { time: _, dx, dy })  = capture_input {
                               // println!("Motion {dx} {dy}");
                                client_dx = dx + client_dx;
                                client_dy = dy + client_dy;
                            }

                            let position: &Position = match clients_map.get(&handle) {
                                Some(v) => v,
                                None => return Ok(()),
                            };

                            let should_release: bool =   match capture_input {
                                // Auto exit from client if mouse came close to the border
                                Event::Pointer(PointerEvent::Motion { dx: _, dy: _, .. }) =>
                                    match position {
                                        Position::Left => client_dx > 0.0,
                                        Position::Right => client_dx < 0.0,
                                        Position::Top => client_dy > 0.0,
                                        Position::Bottom => client_dy < 0.0,
                                    }
                                // Release on pressing Escape
                                Event::Keyboard(KeyboardEvent::Key { key: 1, .. }) => true,
                                _ => false,
                            };

                            if should_release {
                                println!("Release Mouse");
                                capture.release().await?;
                                client_dx = 0.0;
                                client_dy = 0.0;
                                continue;
                            }

                            let input_bytes: Option<Vec<u8>> = match capture_input {
                                input_event::Event::Pointer(pointer_event) => match pointer_event {
                                    PointerEvent::Motion { time: _, dx, dy } => {
                                        let relative_x_movement = dx as i16;
                                        let relative_y_movement = dy as i16;
                                        let event: Vec<u8> = vec![
                                            0x02,
                                            button_pressed,
                                            relative_x_movement as u8,
                                            relative_y_movement as u8,
                                            0,
                                        ];
                                        Some(event)
                                    }
                                    PointerEvent::Button {
                                        time: _,
                                        button,
                                        state,
                                    } => {
                                        button_pressed = match state {
                                            1 => match button {
                                                input_event::BTN_LEFT => 1,
                                                input_event::BTN_MIDDLE => 2,
                                                input_event::BTN_RIGHT => 3,
                                                input_event::BTN_BACK => 4,
                                                input_event::BTN_FORWARD => 5,
                                                _ => 0,
                                            },
                                            _ => 0,
                                        };
                                        let event = vec![0x02, button_pressed, 0, 0, 0];
                                         Some(event)
                                    }
                                    PointerEvent::Axis {
                                        time: _,
                                        axis: _,
                                        value: _,
                                    } => None,
                                    PointerEvent::AxisDiscrete120 { axis: _, value: _ } => None,
                                },
                                input_event::Event::Keyboard(event) => match event {
                                    input_event::KeyboardEvent::Key {
                                        time: _,
                                        key: _,
                                        state: _,
                                    } => None,
                                    input_event::KeyboardEvent::Modifiers {
                                        depressed: _,
                                        latched: _,
                                        locked: _,
                                        group: _,
                                    } => None,
                                },
                            };

                            if input_bytes.is_none() {
                                continue;
                            }

                            if let Err(err) = position_stream.send((position.clone(), input_bytes.unwrap())).await {
                                log::error!("Error {err}");
                            }
                        },
                    }
                },
                None => return Ok(()),
            },
            request = notify_rx.recv() => {
                println!("Input capture notify rx: {request:?}");
                match request {
                    Some(e) => match e {
                        CaptureRequest::Release => {
                            client_dx = 0.0;
                            client_dy = 0.0;
                            capture.release().await?
                        },
                        CaptureRequest::Create(p) => {
                            if !clients_map.values().any(|e| e == &p) {
                                let h = (clients_map.keys().len() as u64) + 1;
                                println!("Creating Client {h} {p}");
                                clients_map.insert(h, p);
                                capture.create(h, p).await?
                            }
                        },
                        CaptureRequest::Destroy(p) => {
                            if let Some(h) = clients_map.iter().filter(|(_, pos)| **pos == p).map(|(handle, _)| *handle).next() {
                                println!("Destroying Client {h} {p}");
                                clients_map.remove(&h);
                                capture.destroy(h).await?;
                            }
                        }
                    },
                    None => break,
                }
            }
            _ = cancel.cancelled() => break,
        }
    }

    capture.terminate().await?;
    Ok(())
}
