//
//  BluetoothManager.swift
//  BlueDemo
//
//  Created by dev on 2017/2/15.
//  Copyright © 2017年 Chensh. All rights reserved.
//

import UIKit
import CoreBluetooth

// 发现外设
let K_CENTRAL_MANAGER_DID_DISCOVER_PERIPHERAL = "K_CENTRAL_MANAGER_DID_DISCOVER_PERIPHERAL"
// 连接外设成功
let K_CENTRAL_MANAGER_DID_CONNECT_PERIPHERAL = "K_CENTRAL_MANAGER_DID_CONNECT_PERIPHERAL"




class BluetoothTools: NSObject, CBCentralManagerDelegate {

    private static var _instance: BluetoothTools? = nil
    static var shared: BluetoothTools {
        if _instance == nil {
            _instance = BluetoothTools.init()
        }
        return _instance!
    }
    
    var centralManager: CBCentralManager!
    var peripheralDataArray: NSMutableArray = NSMutableArray.init()
    var characteristicPropertiesDict: [[String : Any]] = []

    override init() {
        super.init()
        centralManager = CBCentralManager.init(delegate: self, queue: nil)
        
        characteristicPropertiesDict = [["key" : CBCharacteristicProperties.broadcast, "name" : "广播"],
                                        ["key" : CBCharacteristicProperties.read, "name" : "可读"],
                                        ["key" : CBCharacteristicProperties.writeWithoutResponse, "name" : "无响应写"],
                                        ["key" : CBCharacteristicProperties.write, "name" : "可写"],
                                        ["key" : CBCharacteristicProperties.notify, "name" : "通知"],
                                        ["key" : CBCharacteristicProperties.indicate, "name" : "指示"],
                                        ["key" : CBCharacteristicProperties.authenticatedSignedWrites, "name" : "授权写"],
                                        ["key" : CBCharacteristicProperties.extendedProperties, "name" : "扩展"],
                                        ["key" : CBCharacteristicProperties.notifyEncryptionRequired, "name" : "通知加密"],
                                        ["key" : CBCharacteristicProperties.indicateEncryptionRequired, "name" : "指示加密"]]
    }
    
    
    
    
    // 初始化后回调
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("CBCentralManager state:", "unknown")
            break
        case .resetting:
            print("CBCentralManager state:", "resetting")
            break
        case .unsupported:
            print("CBCentralManager state:", "unsupported")
            break
        case .unauthorized:
            print("CBCentralManager state:", "unauthorized")
            break
        case .poweredOff:
            print("CBCentralManager state:", "poweredOff")
            break
        case .poweredOn:
            print("CBCentralManager state:", "poweredOn")
            
            // 蓝牙开启扫描
            // services： 通过服务筛选
            // dict: 通过条件筛选
            centralManager.scanForPeripherals(withServices: nil, options: nil)
            
            break
        }
    }
    
    // 搜索外围设备
    // advertisementData： 外设携带的数据
    // rssi: 外设的蓝牙信号强度
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(#function, #line)
        print(central)
        print(peripheral)
        print(advertisementData)
        print(RSSI)
        
        /*
         
         * peripheral:
         <CBPeripheral: 0x15fd951b0, identifier = 2DE9CDCF-64B7-C7CA-302F-13EF73A61CDB, name = Chensh的MacBook Pro, state = disconnected>
         
         * advertisementData:
         ["kCBAdvDataIsConnectable": 1, "kCBAdvDataLocalName": MI, "kCBAdvDataManufacturerData": <5701002c 9b349956 7afbaf5a 21000655 07c61200 880f107e c4c4>, "kCBAdvDataServiceUUIDs": <__NSArrayM 0x14f542de0>(
         FEE0,
         FEE7
         )
         , "kCBAdvDataServiceData": {
         FEE0 = <0b000000>;
         }]
         
         */
        
        let uuidString = peripheral.identifier.uuidString
        let aDict: [String : Any] = ["peripheral" : peripheral,
                                     "advertisementData" : advertisementData,
                                     "rssi" : RSSI]
        
        // 判断是否已经存在列表里
        var exist: Bool = false
        for index in 0..<self.peripheralDataArray.count {
            let dict: [String : Any] = self.peripheralDataArray.object(at: index) as! [String : Any]
            let pItem: CBPeripheral = dict["peripheral"] as! CBPeripheral
            if pItem.identifier.uuidString == uuidString {
                exist = true
                self.peripheralDataArray.replaceObject(at: index, with: aDict)
                break
            }
        }
        if !exist {
            self.peripheralDataArray.add(aDict)
        }
        
        // 通知发现外设
        NotificationCenter.default.post(name: NSNotification.Name.init(K_CENTRAL_MANAGER_DID_DISCOVER_PERIPHERAL), object: nil)
    }
    
    
    // 连接外设成功
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("========== 连接外设成功： \(peripheral.name)")
        NotificationCenter.default.post(name: NSNotification.Name.init(K_CENTRAL_MANAGER_DID_CONNECT_PERIPHERAL), object: peripheral)
    }
    
    // 连接外设失败
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("========== 连接外设失败： \(peripheral.name), \(error)")
    }
    
    // 丢失连接
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("========== 丢失连接： \(peripheral.name), \(error)")
    }

    

    
    // 返回属性值对应的名称
    func characteristicPropertyString(_ properties: CBCharacteristicProperties) -> String {
        
        let array : NSMutableArray = NSMutableArray.init()
        
        for dict in self.characteristicPropertiesDict {
            let property = dict["key"] as! CBCharacteristicProperties
            if (properties.rawValue & property.rawValue) != 0 {
                array.add(dict["name"] as! String)
            }
        }
        
        let str = array.componentsJoined(by: ",")
        return str
    }
    
}
