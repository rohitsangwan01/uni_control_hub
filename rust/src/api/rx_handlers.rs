use input_capture::Position;
pub use tokio::sync::mpsc::{
    self,
    error::{SendError, TryRecvError, TrySendError},
    Receiver, Sender,
};

#[derive(Clone)]
pub struct PositionVecU8Sender(pub(crate) Sender<(Position, Vec<u8>)>);

pub struct PositionVecU8Receiver(pub(crate) Receiver<(Position, Vec<u8>)>);

impl PositionVecU8Sender {
    pub async fn send(
        &self,
        data: (Position, Vec<u8>),
    ) -> Result<(), mpsc::error::SendError<(Position, Vec<u8>)>> {
        self.0.send(data).await
    }

    pub fn try_send(
        &self,
        data: (Position, Vec<u8>),
    ) -> Result<(), mpsc::error::TrySendError<(Position, Vec<u8>)>> {
        self.0.try_send(data)
    }

    pub fn is_closed(&self) -> bool {
        self.0.is_closed()
    }
}

impl PositionVecU8Receiver {
    pub async fn recv(&mut self) -> Option<(Position, Vec<u8>)> {
        self.0.recv().await
    }

    pub fn try_recv(&mut self) -> Result<(Position, Vec<u8>), mpsc::error::TryRecvError> {
        self.0.try_recv()
    }

    pub fn close(&mut self) {
        self.0.close();
    }
}
