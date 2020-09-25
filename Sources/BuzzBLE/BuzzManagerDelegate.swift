//
// Copyright (c) Chris Bartley 2020. Licensed under the MIT license. See LICENSE file.
//

import Foundation

public protocol BuzzManagerDelegate: class {
   func didUpdateState(_ buzzManager: BuzzManager, to state: BuzzManagerState)
   func didScanTimeout(_ buzzManager: BuzzManager)
   func didDiscover(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber)
   func didRediscover(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber)

   /// Triggered for discovery or rediscovery of peripherals which don't pass the UARTDeviceScanFilter
   func didIgnoreDiscovery(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber, wasRediscovery: Bool)

   func didDisappear(_ buzzManager: BuzzManager, uuid: UUID)
   func didConnectTo(_ buzzManager: BuzzManager, uuid: UUID)
   func didDisconnectFrom(_ buzzManager: BuzzManager, uuid: UUID, error: Error?)
   func didFailToConnectTo(_ buzzManager: BuzzManager, uuid: UUID, error: Error?)
}

public extension BuzzManagerDelegate {
   func didUpdateState(_ buzzManager: BuzzManager, to state: BuzzManagerState) {}

   func didScanTimeout(_ buzzManager: BuzzManager) {}

   func didDiscover(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {}

   func didRediscover(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {}

   func didIgnoreDiscovery(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber, wasRediscovery: Bool) {}

   func didDisappear(_ buzzManager: BuzzManager, uuid: UUID) {}

   func didConnectTo(_ buzzManager: BuzzManager, uuid: UUID) {}

   func didDisconnectFrom(_ buzzManager: BuzzManager, uuid: UUID, error: Error?) {}

   func didFailToConnectTo(_ buzzManager: BuzzManager, uuid: UUID, error: Error?) {}
}