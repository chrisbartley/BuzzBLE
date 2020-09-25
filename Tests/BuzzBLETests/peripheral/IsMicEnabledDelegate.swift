//
// Copyright (c) Chris Bartley 2020. Licensed under the MIT license. See LICENSE file.
//

import Foundation
import XCTest
@testable import BuzzBLE

class IsMicEnabledDelegate: NoOpDelegate {
   private let expectation: XCTestExpectation

   var isMicEnabled: Bool?

   override init(_ testCase: XCTestCase) {
      self.expectation = testCase.expectation(description: "Response received")
      self.expectation.assertForOverFulfill = false
      super.init(testCase)
   }

   override func buzz(_ device: Buzz, isMicEnabled: Bool) {
      super.buzz(device, isMicEnabled: isMicEnabled)
      self.isMicEnabled = isMicEnabled
      expectation.fulfill()
   }

   func waitForIsMicEnabledExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [expectation], timeout: timeout)
   }
}