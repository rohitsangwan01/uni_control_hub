#[derive(Debug)]
pub enum ServerUpdate {
    /// Represents a screen configuration update.
    ScreenInfoQuery,

    /// Acknowledged ScreenConfig
    InfoAck,

    /// Reset options
    ResetOptions,

    /// Represents a mouse position update.
    MousePositionUpdate { x: i16, y: i16 },

    /// Represents a mouse button down event.
    MouseButtonDown { button_id: u8 },

    /// Represents a mouse button up event.
    MouseButtonUp { button_id: u8 },

    /// Represents a relative mouse move event.
    MouseRelativeMove { x: i16, y: i16 },

    /// Represents a mouse wheel event.
    MouseWheel { x: i16, y: i16 },

    /// Represents a keyboard key down event.
    KeyDown {
        key_event_id: u16,
        mask: u16,
        button: u16,
    },

    /// Represents a keyboard key up event.
    KeyUp {
        key_event_id: u16,
        mask: u16,
        button: u16,
    },

    /// Represents a keyboard key repeat event.
    KeyRepeat {
        key_event_id: u16,
        mask: u16,
        count: u16,
        button: u16,
    },

    /// Represents a screen enter event.
    Enter {
        x: i16,
        y: i16,
        sequence_number: i32,
        toggle_mask: i16,
    },

    /// Represents a screen leave event.
    Leave,
}
