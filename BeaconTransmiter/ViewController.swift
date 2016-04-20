//
//  ViewController.swift
//  BeaconTransmiter
//
//  Created by Ryan Jones on 4/15/16.
//  Copyright © 2016 Ryan Jones. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    
    @IBOutlet var uuid: UILabel!
    @IBOutlet var major: UILabel!
    @IBOutlet var minor: UILabel!
    @IBOutlet var identity: UILabel!
    @IBOutlet var beaconStatus: UILabel!
    
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    var beaconTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initLocalBeacon(minorNum : Int) {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let localBeaconUUID = "66dae67d-22e2-466b-b7d6-7093d52ceeb7"
        let localBeaconMajor: CLBeaconMajorValue = 8127
        let localBeaconMinor: CLBeaconMinorValue = UInt16(minorNum)
        
        let uuid = NSUUID(UUIDString: localBeaconUUID)!
        localBeacon = CLBeaconRegion(proximityUUID: uuid, major: localBeaconMajor, minor: localBeaconMinor, identifier: "MySmartDoor")
        
        beaconPeripheralData = localBeacon.peripheralDataWithMeasuredPower(nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if peripheral.state == .PoweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
            beaconStatus.text = "Transmitting!"
        } else if peripheral.state == .PoweredOff {
            peripheralManager.stopAdvertising()
            self.beaconStatus.text = "Power Off"
        }
    }
    
    func updateInterface(minorNum: Int){
        
        let localBeaconUUID = "66dae67d-22e2-466b-b7d6-7093d52ceeb7"
        let localBeaconMajor: CLBeaconMajorValue = 8127
        let localBeaconMinor: CLBeaconMinorValue = UInt16(minorNum)
        
        self.uuid.text = "\(localBeaconUUID)"
        self.major.text = "\(localBeaconMajor)"
        self.minor.text = "\(localBeaconMinor)"
        self.identity.text = "MySmartDoor"
    }
    
    func runThroughCycle(minorNum : Int) {
        stopLocalBeacon()
        initLocalBeacon(minorNum)
        isBroadcasting = true
        updateInterface(minorNum)
    }
    
    func resetBeacon(){
        runThroughCycle(1)
    }
    
    @IBAction func transmitBeacon(sender: AnyObject) {
        if !isBroadcasting {
            initLocalBeacon(1)
            isBroadcasting = true
            updateInterface(1)
        }
        else {
            stopLocalBeacon()
            isBroadcasting = false
        }
    }
    
    @IBAction func StopTransmit(sender: AnyObject) {
        stopLocalBeacon()
        isBroadcasting = false
        updateInterface(5)
        
    }
    
    @IBAction func unlockDoor(sender: AnyObject) {
        runThroughCycle(2)
        beaconTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.resetBeacon), userInfo: nil, repeats: false)
    }

    @IBAction func lockDoor(sender: AnyObject) {
        runThroughCycle(3)
        beaconTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(ViewController.resetBeacon), userInfo: nil, repeats: false)
    }
}

