//
//  MainViewController.swift
//  BlueDemo
//
//  Created by Chensh on 2017/2/14.
//  Copyright © 2017年 Chensh. All rights reserved.
//

import UIKit
import CoreBluetooth


class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier: String = "PeripheralTableViewCell"
    @IBOutlet weak var tableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        self.navigationItem.title = "蓝牙搜索"
        
        //
        self.tableView.register(UINib.init(nibName: cellIdentifier, bundle: nil), forCellReuseIdentifier: cellIdentifier)
        
        //
        NotificationCenter.default.addObserver(self.tableView, selector: #selector(self.tableView.reloadData), name: NSNotification.Name(rawValue: K_CENTRAL_MANAGER_DID_DISCOVER_PERIPHERAL), object: nil)
        
        //
        let _ = BluetoothTools.shared
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        BluetoothTools.shared.centralManager.stopScan()
    }
    
    
    // =======================================================
    // =======================================================
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BluetoothTools.shared.peripheralDataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PeripheralTableViewCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! PeripheralTableViewCell
        
        let dict = BluetoothTools.shared.peripheralDataArray.object(at: indexPath.row) as! [String : Any]
        let peripheral: CBPeripheral = dict["peripheral"] as! CBPeripheral
        //
        if let name = peripheral.name {
            cell.nameLabel.text = name
        } else {
            cell.nameLabel.text = "未知设备名"
        }
        //
        cell.identifierLabel.text = peripheral.identifier.uuidString
        //
        let rssi = dict["rssi"]
        let advertisementData = dict["advertisementData"] as! [String : Any]
        var count = 0
        if let serviceArr: NSArray = advertisementData["kCBAdvDataServiceUUIDs"] as? NSArray {
            count = serviceArr.count
        }
        var connectableStr = "不可连接"
        if let connectable: NSNumber = advertisementData["kCBAdvDataIsConnectable"] as? NSNumber {
            if connectable.intValue == 1 {
                connectableStr = "可连接"
            }
        }
        cell.stateLabel.text = String.init(format: "[%@], 共%d服务, %@", rssi as! CVarArg, count, connectableStr)
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let dict = BluetoothTools.shared.peripheralDataArray.object(at: indexPath.row) as! [String : Any]
        let pVC: PeripheralViewController = PeripheralViewController()
        pVC.paramDict = dict
        self.navigationController?.pushViewController(pVC, animated: true)

//        self.centralManager.connect(peripheral, options: nil)
//        print("开始连接外设： \(peripheral.name), \(peripheral.identifier.uuidString)")
    }
    
    
    
    

}
