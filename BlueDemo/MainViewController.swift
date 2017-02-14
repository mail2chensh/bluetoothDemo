//
//  MainViewController.swift
//  BlueDemo
//
//  Created by Chensh on 2017/2/14.
//  Copyright © 2017年 Chensh. All rights reserved.
//

import UIKit
import CoreBluetooth


class MainViewController: UIViewController, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier: String = "PeripheralTableViewCell"
    var dataArray: [CBPeripheral] = []
    
    var centralManager: CBCentralManager!
    var aPeripheral: CBPeripheral!
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.title = "蓝牙搜索"
        
        //
        self.tableView.register(UINib.init(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        //
        self.centralManager = CBCentralManager.init(delegate: self, queue: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // =======================================================
    // =======================================================
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PeripheralTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! PeripheralTableViewCell
        
        let peripheral: CBPeripheral = self.dataArray[indexPath.row]
        cell.nameLabel.text = peripheral.name
        cell.identifierLabel.text = peripheral.identifier.uuidString
        cell.stateLabel.text = CBPeripheralStateString(state: peripheral.state)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    

    func CBPeripheralStateString(state: CBPeripheralState) -> String {
        switch state {
        case .disconnected:
            return "disconnected"
        case .connecting:
            return "connecting"
        case .connected:
            return "connected"
        default:
            return "disconnecting"
        }
    }
    
    
    // =======================================================
    // =======================================================
    
    
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
        
        // 判断是否已经存在列表里
        var exist: Bool = false
        for pItem in self.dataArray {
            if pItem.identifier.uuidString == peripheral.identifier.uuidString {
                exist = true
                let index: Int = self.dataArray.index(of: pItem)!
                self.dataArray.replaceSubrange(index...index, with: [peripheral])
            }
        }
        if !exist {
            self.dataArray.append(peripheral)
        }
        self.tableView.reloadData()
        
    }
    
    
    

}
