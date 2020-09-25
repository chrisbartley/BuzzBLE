//
// Copyright (c) Chris Bartley 2020. Licensed under the MIT license. See LICENSE file.
//

import Foundation
import XCTest
@testable import BuzzBLE

class AreMotorsEnabledDelegate: NoOpDelegate {
   private let expectation: XCTestExpectation

   var areMotorsEnabled: Bool?

   override init(_ testCase: XCTestCase) {
      self.expectation = testCase.expectation(description: "Response received")
      self.expectation.assertForOverFulfill = false
      super.init(testCase)
   }

   override func buzz(_ device: Buzz, areMotorsEnabled: Bool) {
      super.buzz(device, areMotorsEnabled: areMotorsEnabled)
      self.areMotorsEnabled = areMotorsEnabled
      expectation.fulfill()
   }

   func waitForAreMotorsEnabledExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [expectation], timeout: timeout)
   }
}