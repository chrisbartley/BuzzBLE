//
// Copyright (c) Chris Bartley 2020. Licensed under the MIT license. See LICENSE file.
//

import Foundation
import XCTest
@testable import BuzzBLE

class DeviceInfoDelegate: IsCommunicationEnabledDelegate {
   private let expectation: XCTestExpectation

   var deviceInfo: Buzz.DeviceInfo?

   override init(_ testCase: XCTestCase) {
      self.expectation = testCase.expectation(description: "Response received")
      self.expectation.assertForOverFulfill = false
      super.init(testCase)
   }

   override func buzz(_ device: Buzz, deviceInfo: Buzz.DeviceInfo) {
      self.deviceInfo = deviceInfo
      expectation.fulfill()
   }

   func waitForExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [expectation], timeout: timeout)
   }
}
