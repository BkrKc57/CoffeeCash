//
//  CoreBManager.swift
//  CoffeeCash
//
//  Created by MacOS on 21.04.2022.
//

import Foundation
import CoreBluetooth

enum DataType {
    case amount
    case text
    
    var key: String {
        switch self {
        case .amount:
            return "amount"
        case .text:
            return "text"
        }
    }
}


class CoreBManager: NSObject {
    
    static let shared = CoreBManager()
    
    var didReceiveWrite: ((String) -> Void)?
    var didUpdateValue: ((String) -> Void)?
    var didConnect: ((Bool) -> Void)?
    
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!

    var peripheral: CBPeripheral?
    var connectedPeripheral: CBPeripheral!
    var characteristic: CBCharacteristic!
    var subscribeCentral: CBCentral!
    var subscribeCharacteristic: CBCharacteristic!
    
    let WR_UUID = CBUUID(string: "12345678-1234-1234-1234-123456789012")
    let WR_PROPERTIES: CBCharacteristicProperties = [.write, .notify]
    let WR_PERMISSIONS: CBAttributePermissions = .writeable
    var wrCharacteristics: CBMutableCharacteristic!
    
    
    
    override init() {
        super.init()
        if ApplicationData.shared.userType == .cashier {
            self.startScanning()
        } else {
            self.startAdvertising()
        }
    }
    
    func startScanning() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startAdvertising() {
           peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    func send(text: String) {
        let data = text.data(using: .utf8)!
        self.connectedPeripheral.writeValue(data, for: self.characteristic, type: .withResponse)
    }
    
    func updateValue(text: String) {
        let data = text.data(using: .utf8)!
//        let myCharacteristic = CBMutableCharacteristic(type: WR_UUID, properties: [CBCharacteristicProperties.read, CBCharacteristicProperties.notify], value: nil, permissions: CBAttributePermissions.readable)
        self.peripheralManager.updateValue(data, for: self.wrCharacteristics, onSubscribedCentrals: nil)
    }
    
}

// MARK: -- CBCentralManager Delegate

extension CoreBManager: CBCentralManagerDelegate {
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
      // Perform any error handling if one occurred
      if let error = error {
        print("Characteristic value update failed: \(error.localizedDescription)")
        return
      }

      // Retrieve the data from the characteristic
      guard let data = characteristic.value else { return }

      // Decode/Parse the data here
      let message = String(decoding: data, as: UTF8.self)
        print(message)
        self.didUpdateValue!(message)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
           case .poweredOn:
//             if central.isScanning {
//                central.stopScan()
//             }
            let uuid = CBUUID(string: ApplicationData.shared.qrUUID)
            self.centralManager.scanForPeripherals(withServices: [uuid], options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            print("didStartedScan")
            break
           case .poweredOff:
            // Bluetooth'u açması için kullanıcıyı uyar
                break
           case .resetting:
        // Bir sonraki durum güncellemesini bekleyin ve Bluetooth hizmetinin kesintiye uğramasını düşünün
            break
           case .unauthorized:
        // Uygulama Ayarlarında Bluetooth iznini etkinleştirmek için kullanıcıyı uyar
            break
           case .unsupported:
        // Kullanıcıya cihazının Bluetooth'u desteklemediğini ve uygulama beklendiği gibi çalışmayacağını bildir
            break
           case .unknown:
        // Bir sonraki durum güncellemesini bekle
            break
       }
                    
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("didDiscover")
        if peripheral.name == UserType.customer.uuidKey {
            self.peripheral = peripheral
            print(peripheral.name)
            if self.peripheral != nil {
                self.centralManager.connect(self.peripheral!, options: [
                    CBConnectPeripheralOptionNotifyOnConnectionKey: true,
                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: true,
                    CBConnectPeripheralOptionNotifyOnNotificationKey: true
                    ])
            }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Successfully connected. Store reference to peripheral if not already done.
        print("didConnect")
        self.connectedPeripheral = peripheral
        self.connectedPeripheral.delegate = self
        self.centralManager.stopScan()
        self.connectedPeripheral.discoverServices([CBUUID(string: ApplicationData.shared.qrUUID)])
        self.didConnect!(true)
    }
    
    
     
}

// MARK: -- CBPeripheralManager Delegate

extension CoreBManager: CBPeripheralManagerDelegate {
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("didSubscribe")
        self.subscribeCentral = central
        self.subscribeCharacteristic = characteristic
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("didUpdateState")
           if peripheral.state == .poweredOn {
               if peripheral.isAdvertising {
                   peripheral.stopAdvertising()
                    print("stopAdvertising")
               }
            let uuid = CBUUID(string: ApplicationData.shared.uuid)
            let serialService = CBMutableService(type: uuid, primary: true)
            let writeCharacteristics = CBMutableCharacteristic(type: WR_UUID,
                                                        properties: WR_PROPERTIES, value: nil,
                                                        permissions: WR_PERMISSIONS)
            self.wrCharacteristics = writeCharacteristics
           serialService.characteristics = [writeCharacteristics]
            self.peripheralManager.add(serialService)

                
               var advertisingData: [String : Any] = [
                   CBAdvertisementDataServiceUUIDsKey: [uuid],
                CBAdvertisementDataLocalNameKey: UserType.customer.uuidKey
               ]
               self.peripheralManager?.startAdvertising(advertisingData)
            print("startingAdvertising")
           } else {
               #warning("handle other states")
           }
       }
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("DidStartAdvertising")
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
           for request in requests {
               if let value = request.value {
                   
                let messageText = String(data: value, encoding: String.Encoding.utf8) as String?
                print(messageText)
                self.didReceiveWrite!(messageText!)
               }
               self.peripheralManager.respond(to: request, withResult: .success)
           }
       }
}

// MARK: -- CBPeripheral Delegate

extension CoreBManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        print("didDiscoverServices \(services)")
        for service in services {
            self.connectedPeripheral.discoverCharacteristics([WR_UUID], for: service)
        }
    }
     
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        self.characteristic = characteristics[0]
        print("didDiscoverCharacteristics \(characteristics)")
        self.connectedPeripheral.setNotifyValue(true, for: self.characteristic)
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        // Perform any error handling if one occurred
         if let error = error {
           print("Characteristic value update failed: \(error.localizedDescription)")
           return
         }

         // Retrieve the data from the characteristic
         guard let data = characteristic.value else { return }

         // Decode/Parse the data here
         let message = String(decoding: data, as: UTF8.self)
        print(message)
    }
    

}
