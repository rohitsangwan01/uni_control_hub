pub use crossbeam_channel::{
    self, Receiver, RecvError, SendError, Sender, TryRecvError, TrySendError,
};
use input_capture::Position;

#[derive(Clone)]
pub struct PositionVecU8Sender(pub(crate) Sender<(Position, Vec<u8>)>);

#[derive(Clone)]
pub struct PositionVecU8Receiver(pub(crate) Receiver<(Position, Vec<u8>)>);

impl PositionVecU8Sender {
    pub async fn send(
        &self,
        data: (Position, Vec<u8>),
    ) -> Result<(), SendError<(Position, Vec<u8>)>> {
        self.0.send(data)
    }

    pub fn try_send(
        &self,
        data: (Position, Vec<u8>),
    ) -> Result<(), TrySendError<(Position, Vec<u8>)>> {
        self.0.try_send(data)
    }
}

impl PositionVecU8Receiver {
    pub fn recv(&mut self) -> Result<(Position, Vec<u8>), RecvError> {
        self.0.recv()
    }

    pub fn try_recv(&mut self) -> Result<(Position, Vec<u8>), TryRecvError> {
        self.0.try_recv()
    }
}
