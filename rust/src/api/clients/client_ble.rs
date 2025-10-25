use crate::{
    api::{
        events::{ClientEvent, COMBINED_REPORT},
        rx_handlers::PositionVecU8Receiver,
    },
    frb_generated::StreamSink,
};
use ble_peripheral_rust::{
    gatt::{
        characteristic::Characteristic,
        descriptor::Descriptor,
        peripheral_event::{
            PeripheralEvent, ReadRequestResponse, RequestResponse, WriteRequestResponse,
        },
        properties::{AttributePermission, CharacteristicProperty},
        service::Service,
    },
    uuid::ShortUuid,
    Peripheral, PeripheralImpl,
};
use std::sync::Arc;
use tokio::sync::{mpsc::channel, Mutex};
use uuid::Uuid;

#[flutter_rust_bridge::frb(opaque)]
pub struct BleClient {
    peripheral: Peripheral,
    hid_service: Service,
    device_info_service: Service,
    battery_service: Service,
    characteristic_report: Uuid,
    service_ble_hid: Uuid,
    device_name: String,
    sender_tx_arc: Arc<Mutex<Option<StreamSink<ClientEvent>>>>,
}

impl BleClient {
    pub async fn new() -> Self {
        let (sender_tx, mut receiver_rx) = channel::<PeripheralEvent>(256);
        let peripheral = Peripheral::new(sender_tx).await.unwrap();

        let device_name = "UniHub";
        let manufacturer = "uni-hub";
        let serial_number = "12345678";
        let response_hid_information = vec![0x11, 0x01, 0x00, 0x03];

        let service_ble_hid = Uuid::from_short(0x1812);
        let service_device_info = Uuid::from_short(0x180A);
        let service_battery = Uuid::from_short(0x180F);

        let characteristic_manufacturer_name = Uuid::from_short(0x2A29);
        let characteristic_model_number = Uuid::from_short(0x2A24);
        let characteristic_serial_number = Uuid::from_short(0x2A25);
        let characteristic_battery_level = Uuid::from_short(0x2A19);
        let characteristic_hid_information = Uuid::from_short(0x2A4A);
        let characteristic_report_map = Uuid::from_short(0x2A4B);
        let characteristic_hid_control_point = Uuid::from_short(0x2A4C);
        let characteristic_report = Uuid::from_short(0x2A4D);
        let characteristic_protocol_mode = Uuid::from_short(0x2A4E);
        let descriptor_report_reference = Uuid::from_short(0x2908);

        let hid_service = Service {
            uuid: service_ble_hid,
            primary: true,
            characteristics: vec![
                Characteristic {
                    uuid: characteristic_hid_information,
                    properties: vec![
                        CharacteristicProperty::Read,
                        CharacteristicProperty::Write,
                        CharacteristicProperty::Notify,
                    ],
                    permissions: vec![
                        AttributePermission::ReadEncryptionRequired,
                        AttributePermission::WriteEncryptionRequired,
                    ],
                    ..Default::default()
                },
                Characteristic {
                    uuid: characteristic_report_map,
                    properties: vec![CharacteristicProperty::Read],
                    permissions: vec![AttributePermission::ReadEncryptionRequired],
                    ..Default::default()
                },
                Characteristic {
                    uuid: characteristic_protocol_mode,
                    properties: vec![CharacteristicProperty::Read, CharacteristicProperty::Write],
                    permissions: vec![
                        AttributePermission::ReadEncryptionRequired,
                        AttributePermission::WriteEncryptionRequired,
                    ],
                    ..Default::default()
                },
                Characteristic {
                    uuid: characteristic_hid_control_point,
                    properties: vec![CharacteristicProperty::Write],
                    permissions: vec![AttributePermission::WriteEncryptionRequired],
                    ..Default::default()
                },
                Characteristic {
                    uuid: characteristic_report,
                    properties: vec![
                        CharacteristicProperty::Read,
                        CharacteristicProperty::Write,
                        CharacteristicProperty::Notify,
                    ],
                    permissions: vec![
                        AttributePermission::ReadEncryptionRequired,
                        AttributePermission::WriteEncryptionRequired,
                    ],
                    descriptors: vec![Descriptor {
                        uuid: descriptor_report_reference,
                        permissions: vec![
                            AttributePermission::ReadEncryptionRequired,
                            AttributePermission::WriteEncryptionRequired,
                        ],
                        value: Some(vec![0, 1]),
                        ..Default::default()
                    }],
                    ..Default::default()
                },
            ],
        };

        let device_info_service = Service {
            uuid: service_device_info,
            primary: true,
            characteristics: vec![
                Characteristic {
                    uuid: characteristic_manufacturer_name,
                    properties: vec![CharacteristicProperty::Read],
                    permissions: vec![AttributePermission::ReadEncryptionRequired],
                    ..Default::default()
                },
                Characteristic {
                    uuid: characteristic_model_number,
                    properties: vec![CharacteristicProperty::Read],
                    permissions: vec![AttributePermission::ReadEncryptionRequired],
                    ..Default::default()
                },
                Characteristic {
                    uuid: characteristic_serial_number,
                    properties: vec![CharacteristicProperty::Read],
                    permissions: vec![AttributePermission::ReadEncryptionRequired],
                    ..Default::default()
                },
            ],
        };

        let battery_service = Service {
            uuid: service_battery,
            primary: true,
            characteristics: vec![Characteristic {
                uuid: characteristic_battery_level,
                properties: vec![CharacteristicProperty::Read, CharacteristicProperty::Notify],
                permissions: vec![AttributePermission::ReadEncryptionRequired],
                ..Default::default()
            }],
        };

        let sender_tx_arc: Arc<Mutex<Option<StreamSink<ClientEvent>>>> = Arc::new(Mutex::new(None));
        let sender_tx_arc_clone = sender_tx_arc.clone();
        tokio::spawn(async move {
            // Manage Subscribed clients cache
            let mut ble_devices: Vec<String> = vec![];
            while let Some(event) = receiver_rx.recv().await {
                match event {
                    PeripheralEvent::CharacteristicSubscriptionUpdate {
                        request,
                        subscribed,
                    } => {
                        println!(
                            "CharacteristicSubscriptionUpdate: request: {:?}, subscribed: {:?}",
                            request, subscribed
                        );
                        let client = request.client;
                        // Check for only characteristic_report
                        if request.characteristic != characteristic_report {
                            continue;
                        }

                        if subscribed {
                            // Check if already present
                            if !ble_devices.contains(&client) {
                                ble_devices.push(client.clone());
                                if let Some(client_tx_clone) =
                                    sender_tx_arc_clone.lock().await.clone()
                                {
                                    tokio::spawn(async move {
                                        let _ =
                                            client_tx_clone.add(ClientEvent::Added(client.clone()));
                                    });
                                }
                            };
                        } else {
                            // Client Removed
                            if ble_devices.contains(&client) {
                                ble_devices.retain(|x| x == &client);
                                if let Some(client_tx_clone) =
                                    sender_tx_arc_clone.lock().await.clone()
                                {
                                    tokio::spawn(async move {
                                        let _ = client_tx_clone
                                            .add(ClientEvent::Removed(client.clone()));
                                    });
                                }
                            };
                        }
                    }
                    PeripheralEvent::ReadRequest {
                        request,
                        offset,
                        responder,
                    } => {
                        let mut response: Vec<u8> = vec![];
                        if characteristic_hid_information == request.characteristic {
                            response = response_hid_information.clone();
                        } else if characteristic_hid_control_point == request.characteristic {
                            response = vec![0x00];
                        } else if characteristic_report == request.characteristic {
                            response = vec![];
                        } else if characteristic_serial_number == request.characteristic {
                            response = serial_number.into();
                        } else if characteristic_model_number == request.characteristic {
                            response = device_name.into();
                        } else if characteristic_battery_level == request.characteristic {
                            response = vec![0x64];
                        } else if characteristic_manufacturer_name == request.characteristic {
                            response = manufacturer.into();
                        } else if characteristic_report_map == request.characteristic {
                            response = COMBINED_REPORT.into();
                        }

                        let offset = offset as usize;
                        let response = if offset < response.len() {
                            response[offset..].to_vec()
                        } else {
                            vec![]
                        };

                        log::info!(
                            "ReadRequest: request: {:?}, offset: {:?}, response: {:?}",
                            request,
                            offset,
                            response
                        );

                        let _ = responder.send(ReadRequestResponse {
                            value: response,
                            response: RequestResponse::Success,
                        });
                    }
                    PeripheralEvent::WriteRequest {
                        request,
                        offset,
                        value,
                        responder,
                    } => {
                        log::info!(
                            "WriteRequest: request: {:?}, offset: {:?}, value: {:?}",
                            request,
                            offset,
                            value
                        );
                        let _ = responder.send(WriteRequestResponse {
                            response: RequestResponse::Success,
                        });
                    }
                    PeripheralEvent::StateUpdate { is_powered } => {
                        log::info!("StateUpdate: is_powered: {:?}", is_powered);
                    }
                }
            }
        });

        Self {
            peripheral,
            hid_service,
            device_info_service,
            battery_service,
            characteristic_report,
            service_ble_hid,
            device_name: device_name.to_string(),
            sender_tx_arc,
        }
    }

    pub async fn watch_devices(&mut self, sender_tx: StreamSink<ClientEvent>) {
        self.sender_tx_arc.lock().await.replace(sender_tx);

        log::info!("Checking if powered on");
        while !self.peripheral.is_powered().await.unwrap() {}

        // We cant add deviceInfo service on Windows
        #[cfg(any(target_os = "linux", target_os = "macos"))]
        {
            self.peripheral
                .add_service(&self.device_info_service)
                .await
                .unwrap();
        }

        self.peripheral
            .add_service(&self.hid_service)
            .await
            .unwrap();
        self.peripheral
            .add_service(&self.battery_service)
            .await
            .unwrap();
        log::info!("All services added");

        self.peripheral
            .start_advertising(&self.device_name, &[self.service_ble_hid])
            .await
            .unwrap();
        log::info!("Advertising started");
    }

    pub fn setup_client_listener(&mut self, receiver: PositionVecU8Receiver) {
        let mut receiver_clone = receiver.clone();
        tokio::spawn(async move {
            while let Ok(event) = receiver_clone.recv() {
                println!("Client Event: {:?}", event);
            }
        });
    }

    pub async fn send_hid_event(&mut self, event: Vec<u8>) {
        if let Err(err) = self
            .peripheral
            .update_characteristic(self.characteristic_report, event)
            .await
        {
            log::info!("Error: {:?}", err);
        }
    }
}
