use std::vec;

use anyhow::Ok;
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
    Peripheral,
};
use tokio::sync::mpsc::channel;
use uuid::Uuid;

use crate::api::hid_report::COMBINED_REPORT;

pub struct BleClient {
    peripheral: Peripheral,
    device_name: &'static str,

    // Services
    service_ble_hid: Uuid,
    service_device_info: Uuid,
    service_battery: Uuid,

    // Characteristics
    characteristic_manufacturer_name: Uuid,
    characteristic_model_number: Uuid,
    characteristic_serial_number: Uuid,
    characteristic_battery_level: Uuid,
    characteristic_hid_information: Uuid,
    characteristic_report_map: Uuid,
    characteristic_hid_control_point: Uuid,
    characteristic_report: Uuid,
    characteristic_protocol_mode: Uuid,
    descriptor_report_reference: Uuid,
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

        tokio::spawn(async move {
            while let Some(event) = receiver_rx.recv().await {
                match event {
                    PeripheralEvent::CharacteristicSubscriptionUpdate {
                        request,
                        subscribed,
                    } => {
                        println!(
                            "CharacteristicSubscriptionUpdate: request: {:?}, subscribed: {:?}",
                            request, subscribed
                        )
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

                        println!(
                            "ReadRequest: request: {:?}, offset: {:?}, response: {:?}",
                            request, offset, response
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
                        println!(
                            "WriteRequest: request: {:?}, offset: {:?}, value: {:?}",
                            request, offset, value
                        );
                        let _ = responder.send(WriteRequestResponse {
                            response: RequestResponse::Success,
                        });
                    }
                    _ => {}
                }
            }
        });

        return Self {
            peripheral,
            device_name,
            service_ble_hid,
            service_device_info,
            service_battery,
            characteristic_manufacturer_name,
            characteristic_model_number,
            characteristic_serial_number,
            characteristic_battery_level,
            characteristic_hid_information,
            characteristic_report_map,
            characteristic_hid_control_point,
            characteristic_report,
            characteristic_protocol_mode,
            descriptor_report_reference,
        };
    }

    pub async fn send_hid_event(&mut self, event: Vec<u8>) -> Result<(), anyhow::Error> {
        self.peripheral
            .update_characteristic(self.characteristic_report, event)
            .await?;
        return Ok(());
    }

    pub async fn load_devices(&mut self) -> Result<(), anyhow::Error> {
        println!("Checking if powered on");
        while !self.peripheral.is_powered().await.unwrap() {}

        // Add all services
        self.peripheral
            .add_service(&&self.get_device_info_service())
            .await?;
        self.peripheral.add_service(&self.get_hid_service()).await?;
        self.peripheral
            .add_service(&&self.get_battery_service())
            .await?;

        println!("All services added");

        self.peripheral
            .start_advertising(&self.device_name, &[self.service_ble_hid])
            .await?;
        println!("Advertising started");

        return Ok(());
    }

    fn get_hid_service(&self) -> Service {
        return Service {
            uuid: self.service_ble_hid,
            primary: true,
            characteristics: vec![
                Characteristic {
                    uuid: self.characteristic_hid_information,
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
                    uuid: self.characteristic_report_map,
                    properties: vec![CharacteristicProperty::Read],
                    permissions: vec![AttributePermission::ReadEncryptionRequired],
                    ..Default::default()
                },
                Characteristic {
                    uuid: self.characteristic_protocol_mode,
                    properties: vec![CharacteristicProperty::Read, CharacteristicProperty::Write],
                    permissions: vec![
                        AttributePermission::ReadEncryptionRequired,
                        AttributePermission::WriteEncryptionRequired,
                    ],
                    ..Default::default()
                },
                Characteristic {
                    uuid: self.characteristic_hid_control_point,
                    properties: vec![CharacteristicProperty::Write],
                    permissions: vec![AttributePermission::WriteEncryptionRequired],
                    ..Default::default()
                },
                Characteristic {
                    uuid: self.characteristic_report,
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
                        uuid: self.descriptor_report_reference,
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
    }

    fn get_device_info_service(&self) -> Service {
        return Service {
            uuid: self.service_device_info,
            primary: true,
            characteristics: vec![
                Characteristic {
                    uuid: self.characteristic_manufacturer_name,
                    properties: vec![CharacteristicProperty::Read],
                    permissions: vec![AttributePermission::ReadEncryptionRequired],
                    ..Default::default()
                },
                Characteristic {
                    uuid: self.characteristic_model_number,
                    properties: vec![CharacteristicProperty::Read],
                    permissions: vec![AttributePermission::ReadEncryptionRequired],
                    ..Default::default()
                },
                Characteristic {
                    uuid: self.characteristic_serial_number,
                    properties: vec![CharacteristicProperty::Read],
                    permissions: vec![AttributePermission::ReadEncryptionRequired],
                    ..Default::default()
                },
            ],
        };
    }

    fn get_battery_service(&self) -> Service {
        return Service {
            uuid: self.service_battery,
            primary: true,
            characteristics: vec![Characteristic {
                uuid: self.characteristic_battery_level,
                properties: vec![CharacteristicProperty::Read, CharacteristicProperty::Notify],
                permissions: vec![AttributePermission::ReadEncryptionRequired],
                ..Default::default()
            }],
        };
    }
}
