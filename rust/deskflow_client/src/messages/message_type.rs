#[derive(Debug, Clone, Copy)]
pub enum MessageType {
    // HelloBack messages
    HelloBackSynergy,
    HelloBackBarrier,
    // Commands
    CNoop,
    CClose,
    CEnter,
    CLeave,
    CClipboard,
    CScreenSaver,
    CResetOptions,
    CInfoAck,
    CKeepAlive,
    // Data
    DKeyDownLang,
    DKeyDown,
    DKeyRepeat,
    DKeyUp,
    DMouseDown,
    DMouseUp,
    DMouseMove,
    DMouseRelMove,
    DMouseWheel,
    DClipboard,
    DInfo,
    DSetOptions,
    DFileTransfer,
    DDragInfo,
    DSecureInputNotification,
    DLanguageSynchronization,
    QInfo,
    // Errors
    EIncompatible,
    EBusy,
    EUnknown,
    EBad,
}

impl MessageType {
    // Constructor-like function to return specific variants
    pub fn from_str(value: &str) -> Result<Self, String> {
        match value {
            "Synergy" => Ok(MessageType::HelloBackSynergy),
            "Barrier" => Ok(MessageType::HelloBackBarrier),
            "CNOP" => Ok(MessageType::CNoop),
            "CBYE" => Ok(MessageType::CClose),
            "CINN" => Ok(MessageType::CEnter),
            "COUT" => Ok(MessageType::CLeave),
            "CCLP" => Ok(MessageType::CClipboard),
            "CSEC" => Ok(MessageType::CScreenSaver),
            "CROP" => Ok(MessageType::CResetOptions),
            "CIAK" => Ok(MessageType::CInfoAck),
            "CALV" => Ok(MessageType::CKeepAlive),
            "DKDL" => Ok(MessageType::DKeyDownLang),
            "DKDN" => Ok(MessageType::DKeyDown),
            "DKRP" => Ok(MessageType::DKeyRepeat),
            "DKUP" => Ok(MessageType::DKeyUp),
            "DMDN" => Ok(MessageType::DMouseDown),
            "DMUP" => Ok(MessageType::DMouseUp),
            "DMMV" => Ok(MessageType::DMouseMove),
            "DMRM" => Ok(MessageType::DMouseRelMove),
            "DMWM" => Ok(MessageType::DMouseWheel),
            "DCLP" => Ok(MessageType::DClipboard),
            "DINF" => Ok(MessageType::DInfo),
            "DSOP" => Ok(MessageType::DSetOptions),
            "DFTR" => Ok(MessageType::DFileTransfer),
            "DDRG" => Ok(MessageType::DDragInfo),
            "SECN" => Ok(MessageType::DSecureInputNotification),
            "LSYN" => Ok(MessageType::DLanguageSynchronization),
            "QINF" => Ok(MessageType::QInfo),
            "EICV" => Ok(MessageType::EIncompatible),
            "EBSY" => Ok(MessageType::EBusy),
            "EUNK" => Ok(MessageType::EUnknown),
            "EBAD" => Ok(MessageType::EBad),
            _ => Err(format!("No MessageType with value {}", value)),
        }
    }

    pub fn to_str(self) -> &'static str {
        match self {
            MessageType::HelloBackSynergy => "Synergy",
            MessageType::HelloBackBarrier => "Barrier",
            MessageType::CNoop => "CNOP",
            MessageType::CClose => "CBYE",
            MessageType::CEnter => "CINN",
            MessageType::CLeave => "COUT",
            MessageType::CClipboard => "CCLP",
            MessageType::CScreenSaver => "CSEC",
            MessageType::CResetOptions => "CROP",
            MessageType::CInfoAck => "CIAK",
            MessageType::CKeepAlive => "CALV",
            MessageType::DKeyDownLang => "DKDL",
            MessageType::DKeyDown => "DKDN",
            MessageType::DKeyRepeat => "DKRP",
            MessageType::DKeyUp => "DKUP",
            MessageType::DMouseDown => "DMDN",
            MessageType::DMouseUp => "DMUP",
            MessageType::DMouseMove => "DMMV",
            MessageType::DMouseRelMove => "DMRM",
            MessageType::DMouseWheel => "DMWM",
            MessageType::DClipboard => "DCLP",
            MessageType::DInfo => "DINF",
            MessageType::DSetOptions => "DSOP",
            MessageType::DFileTransfer => "DFTR",
            MessageType::DDragInfo => "DDRG",
            MessageType::DSecureInputNotification => "SECN",
            MessageType::DLanguageSynchronization => "LSYN",
            MessageType::QInfo => "QINF",
            MessageType::EIncompatible => "EICV",
            MessageType::EBusy => "EBSY",
            MessageType::EUnknown => "EUNK",
            MessageType::EBad => "EBAD",
        }
    }
}

impl std::fmt::Display for MessageType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self)
    }
}
