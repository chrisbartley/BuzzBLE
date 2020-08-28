//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation
import XCTest
@testable import BuzzBLE

class BatteryInfoDelegate: IsCommunicationEnabledDelegate {
   private let expectation: XCTestExpectation

   var batteryInfo: Buzz.BatteryInfo?

   override init(_ testCase: XCTestCase) {
      self.expectation = testCase.expectation(description: "Response received")
      self.expectation.assertForOverFulfill = false
      super.init(testCase)
   }

   override func buzz(_ device: Buzz, batteryInfo: Buzz.BatteryInfo) {
      self.batteryInfo = batteryInfo
      expectation.fulfill()
   }

   func waitForExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [expectation], timeout: timeout)
   }
}
