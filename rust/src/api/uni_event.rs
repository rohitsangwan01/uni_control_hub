#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum UniClientEvent {
    Ping,
    StartApp,
    StopApp,
    WatchUsb,
    WatchBle,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum UniServerEvent {
    Pong,
    Initialized,
}
