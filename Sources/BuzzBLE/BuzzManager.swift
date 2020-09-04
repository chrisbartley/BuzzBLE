//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation
import os
import CoreBluetooth
import BirdbrainBLE

fileprivate extension OSLog {
   static let log = OSLog(category: "BuzzManager")
}

public class BuzzManager {

   //MARK: - Public Properties

   public weak var delegate: BuzzManagerDelegate?

   /// Returns the number of connected Buzz devices
   public var connectedDeviceCount: Int {
      connectedDevices.count
   }

   //MARK: - Private Properties

   private let bleCentralManager: StandardBLECentralManager

   private var connectedDevices = [UUID : Buzz]()

   private let scanFilter: UARTDeviceScanFilter

   //MARK: - Initializers

   convenience public init(delegate: BuzzManagerDelegate, scanFilter: UARTDeviceScanFilter = Buzz.scanFilter) {
      self.init(scanFilter: scanFilter)
      self.delegate = delegate
   }

   public init(scanFilter: UARTDeviceScanFilter = Buzz.scanFilter) {
      self.scanFilter = scanFilter
      bleCentralManager = StandardBLECentralManager(servicesAndCharacteristics: UARTDeviceServicesAndCharacteristics.instance)
      bleCentralManager.delegate = self
   }

   //MARK: - Public Methods

   @discardableResult
   public func startScanning(timeoutSecs: TimeInterval = -1,
                             assumeDisappearanceAfter: TimeInterval = StandardBLECentralManager.defaultAssumeDisappearanceTimeInterval) -> Bool {
      return bleCentralManager.startScanning(timeoutSecs: timeoutSecs, assumeDisappearanceAfter: assumeDisappearanceAfter)
   }

   @discardableResult
   public func stopScanning() -> Bool {
      return bleCentralManager.stopScanning()
   }

   @discardableResult
   public func connectToBuzz(havingUUID uuid: UUID) -> Bool {
      return bleCentralManager.connectToPeripheral(havingUUID: uuid)
   }

   @discardableResult
   public func disconnectFromBuzz(havingUUID uuid: UUID) -> Bool {
      return bleCentralManager.disconnectFromPeripheral(havingUUID: uuid)
   }

   public func getBuzz(uuid: UUID) -> Buzz? {
      return connectedDevices[uuid]
   }
}

extension BuzzManager: BLECentralManagerDelegate {
   public func didUpdateState(to state: CBManagerState) {
      os_log("didUpdateState(%{public}s)", log: OSLog.log, type: .debug, String(describing: state))
      switch state {
         case .poweredOn:
            delegate?.didUpdateState(to: .enabled)
         case .poweredOff:
            delegate?.didUpdateState(to: .disabled)
         case .unauthorized, .unknown, .resetting, .unsupported:
            delegate?.didUpdateState(to: .error)
         @unknown default:
            os_log("A previously unknown central manager state occurred. CBManagerState '%{public}s' not yet handled", log: OSLog.log, type: .error, String(describing: state))
            delegate?.didUpdateState(to: .error)
      }
   }

   public func didPowerOn() {
      // nothing to do, handled by didUpdateState()
   }

   public func didPowerOff() {
      // nothing to do, handled by didUpdateState()
   }

   public func didScanTimeout() {
      os_log("BLECentralManagerDelegate: Scan should never timeout", log: OSLog.log, type: .error)
   }

   public func didDiscoverPeripheral(uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {
      if scanFilter.isOfType(uuid: uuid, advertisementData: advertisementData, rssi: rssi) {
         delegate?.didDiscover(uuid: uuid,
                               advertisementData: advertisementData,
                               rssi: rssi)
      }
      else {
         delegate?.didIgnoreDiscovery(uuid: uuid,
                                      advertisementData: advertisementData,
                                      rssi: rssi,
                                      wasRediscovery: false)
      }
   }

   public func didRediscoverPeripheral(uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {
      if scanFilter.isOfType(uuid: uuid, advertisementData: advertisementData, rssi: rssi) {
         delegate?.didRediscover(uuid: uuid,
                                 advertisementData: advertisementData,
                                 rssi: rssi)
      }
      else {
         delegate?.didIgnoreDiscovery(uuid: uuid,
                                      advertisementData: advertisementData,
                                      rssi: rssi,
                                      wasRediscovery: true)
      }
   }

   public func didPeripheralDisappear(uuid: UUID) {
      delegate?.didDisappear(uuid: uuid)
   }

   public func didConnectToPeripheral(peripheral: BLEPeripheral) {
      connectedDevices[peripheral.uuid] = Buzz(blePeripheral: peripheral)
      delegate?.didConnectTo(uuid: peripheral.uuid)
   }

   public func didDisconnectFromPeripheral(uuid: UUID, error: Error?) {
      if let _ = connectedDevices.removeValue(forKey: uuid) {
         delegate?.didDisconnectFrom(uuid: uuid, error: error)
      }
   }

   public func didFailToConnectToPeripheral(uuid: UUID, error: Error?) {
      delegate?.didFailToConnectTo(uuid: uuid, error: error)
   }
}