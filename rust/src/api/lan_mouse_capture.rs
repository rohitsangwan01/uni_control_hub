#![allow(unused)]

use anyhow::Ok;
use futures::StreamExt;
use input_capture::{self, CaptureEvent, CaptureHandle, InputCapture, Position};
use input_event::{Event, KeyboardEvent, PointerEvent};
use std::collections::{HashMap, HashSet};
use tokio::sync::mpsc::{self, Receiver, Sender};
use tokio_util::sync::CancellationToken;

#[derive(Clone, Copy, Debug)]
pub(crate) enum CaptureRequest {
    Release,
    Create(Position),
    Destroy(Position),
}

#[derive(Clone)]
pub struct InputHandler {
    capture_tx: Option<Sender<CaptureRequest>>,
    cancel: Option<CancellationToken>,
}

impl InputHandler {
    pub fn new() -> Self {
        Self {
            capture_tx: None,
            cancel: None,
        }
    }

    pub async fn run(
        &mut self,
        stream: Sender<(Position, Vec<u8>)>,
    ) -> anyhow::Result<Sender<CaptureRequest>> {
        let (capture_tx, mut capture_rx) = mpsc::channel::<CaptureRequest>(100);
        let cancel = CancellationToken::new();
        self.cancel = Some(cancel.clone());
        tokio::task::spawn_local(capture_task(cancel, stream, capture_rx));
        return Ok(capture_tx);
    }

    pub fn stop(&mut self) {
        if let Some(token) = self.cancel.clone() {
            token.cancel();
        }
        self.cancel = None;
    }
}

/// Start capture task and all communication with Input
async fn capture_task(
    cancel: CancellationToken,
    stream: Sender<(Position, Vec<u8>)>,
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
                                log::info!("Release Mouse");
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

                            if let Err(err) = stream.send((position.clone(), input_bytes.unwrap())).await {
                                log::error!("Error {err}");
                            }
                        },
                    }
                },
                None => return Ok(()),
            },
            request = notify_rx.recv() => {
                log::info!("Input capture notify rx: {request:?}");
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
                                log::info!("Creating Client {h} {p}");
                                clients_map.insert(h, p);
                                capture.create(h, p).await?
                            }
                        },
                        CaptureRequest::Destroy(p) => {
                            if let Some(h) = clients_map.iter().filter(|(_, pos)| **pos == p).map(|(handle, _)| *handle).next() {
                                log::info!("Destroying Client {h} {p}");
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
