//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation
import XCTest
@testable import BuzzBLE

class DisappearBuzzManagerDelegate: BuzzManagerDelegate {
   private let testCase: XCTestCase
   private let enabledExpectation: XCTestExpectation
   private let scanDiscoverSuccessExpectation: XCTestExpectation
   private let disappearExpectation: XCTestExpectation

   init(_ testCase: XCTestCase) {
      self.testCase = testCase
      self.enabledExpectation = testCase.expectation(description: "Buzz Manager enabled")
      self.scanDiscoverSuccessExpectation = testCase.expectation(description: "Buzz Manager scan succeeded")
      self.disappearExpectation = testCase.expectation(description: "Device disappeared")
   }

   func didUpdateState(to state: BuzzManagerState) {
      print("DisappearBuzzManagerDelegate: Delegate received didUpdateState(\(state))")
      if state == .enabled {
         enabledExpectation.fulfill()
      }
   }

   func didDiscover(uuid: UUID, advertisementData: [String : Any], rssi: NSNumber) {
      print("DisappearBuzzManagerDelegate: Delegate received didDiscover(uuid=\(uuid),advertisementData=\(advertisementData)")
      scanDiscoverSuccessExpectation.fulfill()
   }

   func didDisappear(uuid: UUID) {
      print("DisappearBuzzManagerDelegate: Delegate received didDisappear(uuid=\(uuid))")
      disappearExpectation.fulfill()
   }

   func waitForEnabledExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [enabledExpectation], timeout: timeout)
   }

   func waitForScanDiscoverSuccessExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [scanDiscoverSuccessExpectation], timeout: timeout)
   }

   func waitForDisappearExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [disappearExpectation], timeout: timeout)
   }
}