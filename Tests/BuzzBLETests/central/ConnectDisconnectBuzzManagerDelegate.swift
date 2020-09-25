//
// Copyright (c) Chris Bartley 2020. Licensed under the MIT license. See LICENSE file.
//

import XCTest
import BirdbrainBLE
@testable import BuzzBLE

class ConnectDisconnectBuzzManagerDelegate: BuzzManagerDelegate {
   private let testCase: XCTestCase
   private let enabledExpectation: XCTestExpectation
   private let scanDiscoverSuccessExpectation: XCTestExpectation
   private let connectSuccessExpectation: XCTestExpectation
   private let disconnectSuccessExpectation: XCTestExpectation

   var state: BuzzManagerState?
   var discoveredUUID: UUID?
   var connectedUUID: UUID?

   init(_ testCase: XCTestCase) {
      self.testCase = testCase
      self.enabledExpectation = testCase.expectation(description: "Buzz Manager enabled")
      self.scanDiscoverSuccessExpectation = testCase.expectation(description: "Buzz Manager scan succeeded")
      self.connectSuccessExpectation = testCase.expectation(description: "Buzz Manager connect succeeded")
      self.disconnectSuccessExpectation = testCase.expectation(description: "Buzz Manager disconnect succeeded")

      self.enabledExpectation.assertForOverFulfill = false
   }

   func didUpdateState(_ buzzManager: BuzzManager, to state: BuzzManagerState) {
      print("ConnectDisconnectBuzzManagerDelegate received didUpdateState(\(state))")
      self.state = state
      if state == .enabled {
         enabledExpectation.fulfill()
      }
   }

   func didScanTimeout(_ buzzManager: BuzzManager) {
      XCTFail("ConnectDisconnectBuzzManagerDelegate received didScanTimeout()!")
   }

   func didDiscover(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {
      print("ConnectDisconnectBuzzManagerDelegate received didDiscover(uuid=\(uuid))")
      discoveredUUID = uuid
      scanDiscoverSuccessExpectation.fulfill()
   }

   func didRediscover(_ buzzManager: BuzzManager, uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {
      print("ConnectDisconnectBuzzManagerDelegate received didRediscover(uuid=\(uuid))")
   }

   func didConnectTo(_ buzzManager: BuzzManager, uuid: UUID) {
      print("ConnectDisconnectBuzzManagerDelegate received didConnectTo(\(uuid)))")
      connectedUUID = uuid
      connectSuccessExpectation.fulfill()
   }

   func didDisconnectFrom(_ buzzManager: BuzzManager, uuid: UUID, error: Error?) {
      print("ConnectDisconnectBuzzManagerDelegate received didDisconnectFrom(\(uuid)))")
      disconnectSuccessExpectation.fulfill()
   }

   func didFailToConnectTo(_ buzzManager: BuzzManager, uuid: UUID, error: Error?) {
      print("ConnectDisconnectBuzzManagerDelegate received didFailToConnectTo for uuid \(uuid), error = \(String(describing: error))")
      XCTFail("ConnectDisconnectBuzzManagerDelegate received didFailToConnectTo(\(uuid)))")
   }

   func didIgnoreDiscovery(_ buzzManager: BuzzManager, uuid: Foundation.UUID, advertisementData: [String : Any], rssi: Foundation.NSNumber, wasRediscovery: Bool) {
      print("ConnectDisconnectBuzzManagerDelegate received didIgnoreDiscovery(\(uuid))) [wasRediscovery=\(wasRediscovery)]")
   }

   func didDisappear(_ buzzManager: BuzzManager, uuid: Foundation.UUID) {
      print("ConnectDisconnectBuzzManagerDelegate received didDisappear(\(uuid)))")
   }

   func waitForEnabledExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [enabledExpectation], timeout: timeout)
   }

   func waitForScanDiscoverSuccessExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [scanDiscoverSuccessExpectation], timeout: timeout)
   }

   func waitForConnectSuccessExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [connectSuccessExpectation], timeout: timeout)
   }

   func waitForDisconnectSuccessExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [disconnectSuccessExpectation], timeout: timeout)
   }
}