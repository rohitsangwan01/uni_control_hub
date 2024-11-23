use byteorder::{BigEndian, ReadBytesExt};

use super::server_type::ServerType;

#[derive(Debug)]
pub struct HelloMessage {
    pub major_version: i16,
    pub minor_version: i16,
    pub server_name: String,
    pub server_type: ServerType,
}

impl HelloMessage {
    pub fn new(data: &[u8]) -> Result<Self, String> {
        let server_name = String::from_utf8_lossy(&data[4..11]).to_string();

        let server_type = ServerType::values()
            .iter()
            .find(|&server| {
                server.hello_back_message().to_str().to_lowercase() == server_name.to_lowercase()
            })
            .cloned()
            .ok_or_else(|| format!("Unsupported server: {}", server_name))?;

        let mut cursor = std::io::Cursor::new(&data[11..]);
        let major_version = cursor.read_i16::<BigEndian>().unwrap();
        let minor_version = cursor.read_i16::<BigEndian>().unwrap();

        Ok(Self {
            major_version,
            minor_version,
            server_name,
            server_type,
        })
    }
}

impl std::fmt::Display for HelloMessage {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{} - HelloMessage: V {}.{}",
            self.server_name, self.major_version, self.minor_version
        )
    }
}
