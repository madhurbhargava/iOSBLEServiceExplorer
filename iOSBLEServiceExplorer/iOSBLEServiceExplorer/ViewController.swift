//
//  ViewController.swift
//  iOSBLEServiceExplorer
//
//  Copyright © 2017 Packt. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBOutlet weak var textView: UITextView!
    var manager:CBCentralManager!
    var devicePeripherals = [CBPeripheral]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        manager = CBCentralManager(delegate: self, queue: nil)
        manager.delegate = self
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil, options: nil)
        } else {
            print("Bluetooth not available.")
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary)
            .object(forKey: CBAdvertisementDataLocalNameKey)
            as? NSString
        
        if device != nil && !devicePeripherals.contains(peripheral) {
            devicePeripherals.append(peripheral)
            textView.text.append("===Device Name:\(device) \n")
            manager.connect(peripheral, options: nil)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if(devicePeripherals.contains(peripheral)) {
            let index = devicePeripherals.index(of: peripheral)
            if let index = index {
                let discoveredPeripheral = devicePeripherals[index]
                discoveredPeripheral.delegate = self
                discoveredPeripheral.discoverServices(nil)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if(devicePeripherals.contains(peripheral)) {
            let index = devicePeripherals.index(of: peripheral)
            if let index = index {
                let discoveredPeripheral = devicePeripherals[index]
                if let services = discoveredPeripheral.services {
                    for service in services {
                        print("Service:: \(service)")
                        textView.text.append("Service found:\(service.uuid.uuidString) for device \(discoveredPeripheral.name) \n")
                        textView.text.append("\n")
                        peripheral.discoverCharacteristics(nil, for: service)
                    }
                }
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if(devicePeripherals.contains(peripheral)) {
            let index = devicePeripherals.index(of: peripheral)
            if let index = index {
                let discoveredPeripheral = devicePeripherals[index]
                if let characteristics = service.characteristics {
                    for characteristic in characteristics {
                        textView.text.append("Characteristic found:\(characteristic.uuid.uuidString) for Service:\(service.uuid.uuidString) for device \(discoveredPeripheral.name) \n")
                        textView.text.append("\n")
                        print(characteristic.uuid.uuidString)
                    }
                    
                }
            }
        }
    }
}

