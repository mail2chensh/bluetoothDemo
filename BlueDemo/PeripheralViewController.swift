//
//  PeripheralViewController.swift
//  BlueDemo
//
//  Created by dev on 2017/2/15.
//  Copyright © 2017年 Chensh. All rights reserved.
//

import UIKit
import CoreBluetooth


class PeripheralViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBPeripheralDelegate {

    @IBOutlet var headerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var rssiLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let cellIdentifier: String = "CharacteristicTableViewCell"
    var paramDict: [String: Any]? = nil
    var aPeripheral: CBPeripheral? = nil
    
    var serviceArray: NSMutableArray = NSMutableArray.init()
    var characteristicArray: NSMutableArray = NSMutableArray.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "外设详情"
        
        self.tableView.tableHeaderView = self.headerView
        self.tableView.estimatedRowHeight = 90
        self.tableView.register(UINib.init(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        //
        NotificationCenter.default.addObserver(self, selector: #selector(centralManagerDidConnectPeripheral(_:)), name: NSNotification.Name.init(K_CENTRAL_MANAGER_DID_CONNECT_PERIPHERAL), object: nil)
        
        //
        if paramDict != nil {
            if let peripheral = paramDict?["peripheral"] as? CBPeripheral {
                self.aPeripheral = peripheral
                BluetoothTools.shared.centralManager.connect(aPeripheral!, options: nil)
                
                if let name: String = peripheral.name {
                    self.nameLabel.text = name
                } else {
                    self.nameLabel.text = "未知设备"
                }
                self.uuidLabel.text = peripheral.identifier.uuidString
            }
            if let rssi : NSNumber = paramDict?["rssi"] as? NSNumber {
                self.rssiLabel.text = NSString.init(format: "[%@]", rssi) as String
            }
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        if self.aPeripheral != nil {
            self.aPeripheral?.delegate = nil
        }
    }
    
    
    // =======================================================
    // =======================================================
    
    func centralManagerDidConnectPeripheral(_ noti: Notification) {
        if self.aPeripheral != nil {
            self.aPeripheral?.delegate = self
            self.aPeripheral?.discoverServices(nil)
        }
    }
    

    // =======================================================
    // =======================================================
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let service: CBService = self.serviceArray.object(at: section) as! CBService
        return "Service: " + service.uuid.uuidString
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.serviceArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.characteristicArray.count == 0 {
            return 0
        }
        let array: NSArray = self.characteristicArray.object(at: section) as! NSArray
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CharacteristicTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CharacteristicTableViewCell
        
        let array: NSArray = self.characteristicArray.object(at: indexPath.section) as! NSArray
        let charac: CBCharacteristic = array.object(at: indexPath.row) as! CBCharacteristic
        
        cell.nameLabel.text = charac.uuid.uuidString
        cell.propertyLabel.text = BluetoothTools.shared.characteristicPropertyString(charac.properties)
        cell.valueLabel.text = "\(charac.value)"
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

    }
    
    
    // =======================================================
    // =======================================================
    
    // 扫描到的服务
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            print("\(peripheral.name) DiscoverServices error: \(error)")
            return
        }
        
        //
        self.serviceArray.removeAllObjects()
        self.characteristicArray.removeAllObjects()
        
        //
        for service in peripheral.services! {
            print(service)
            // 扫描每个服务的characteristics
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    // 扫描到的characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil {
            print("error Discovered characteristics for \(service.uuid) with error: \(error)")
            return
        }
        
        //
        self.serviceArray.add(service)
        let characArray: NSMutableArray = NSMutableArray.init()
        
        
        for characteristic in service.characteristics! {
            print("service:\(service.uuid) 的 Characteristic: \(characteristic.uuid)")
            print(characteristic.properties)
            // 读取每个characteristic 的值
            peripheral.readValue(for: characteristic)
            //
            characArray.add(characteristic)
        }
        
        //
        self.characteristicArray.add(characArray)
        self.tableView.reloadData()
        
//        for characteristic in service.characteristics! {
//            // 扫描每个characteristic 的 descriptor
//            peripheral.discoverDescriptors(for: characteristic)
//        }
    }
    
    // 读取到的每个characteristic 的值
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            print("error UpdateValueFor characteristics for \(characteristic.uuid) with error: \(error)")
            return
        }
        
        print("characteristic uuid: \(characteristic.uuid), value: \(characteristic.value)")
        
    }
    
    // 搜索到每个Characteristic的 Descriptor
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("error Discovered Descriptors for characteristics \(characteristic.uuid) with error: \(error)")
            return
        }
        
        for descriptor in characteristic.descriptors! {
            print("characteristic: \(characteristic.uuid), descriptor: \(descriptor.uuid)")
            //
            
        }
    }
    
    // 获取到descriptor 的值
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        
        if error != nil {
            print("error UpdateValueFor Descriptors \(descriptor.uuid) with error: \(error)")
            return
        }
        
        print("descriptor uuid: \(descriptor.uuid), value: \(descriptor.value)")
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        self.rssiLabel.text = NSString.init(format: "[%@]", RSSI) as String
    }
//
//    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
//        
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
//        
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
//        
//    }
//    
//    
//    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        
//    }
//    
//    
//    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
//        
//    }
//    
//    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
//        
//    }
    
    

}
