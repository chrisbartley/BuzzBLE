//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation

public protocol BuzzManagerDelegate: class {
   func didUpdateState(to state: BuzzManagerState)
   func didDiscover(uuid: UUID, advertisementData: [String : Any], rssi: NSNumber)
   func didRediscover(uuid: UUID, advertisementData: [String : Any], rssi: NSNumber)

   /// Triggered for discovery or rediscovery of peripherals which don't pass the UARTDeviceScanFilter
   func didIgnoreDiscovery(uuid: UUID, advertisementData: [String : Any], rssi: NSNumber, wasRediscovery: Bool)

   func didDisappear(uuid: UUID)
   func didConnectTo(uuid: UUID)
   func didDisconnectFrom(uuid: UUID, error: Error?)
   func didFailToConnectTo(uuid: UUID, error: Error?)
}

public extension BuzzManagerDelegate {
   func didUpdateState(to state: BuzzManagerState) {}

   func didDiscover(uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {}

   func didRediscover(uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {}

   func didIgnoreDiscovery(uuid: UUID, advertisementData: [String : Any], rssi: NSNumber, wasRediscovery: Bool) {}

   func didDisappear(uuid: UUID) {}

   func didConnectTo(uuid: UUID) {}

   func didDisconnectFrom(uuid: UUID, error: Error?) {}

   func didFailToConnectTo(uuid: UUID, error: Error?) {}
}