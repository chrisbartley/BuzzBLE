//
// Copyright (c) Chris Bartley 2020. Licensed under the MIT license. See LICENSE file.
//

import Foundation
import XCTest
@testable import BuzzBLE

class IsMotorsQueueClearedDelegate: NoOpDelegate {
   private let expectation: XCTestExpectation

   var isMotorsQueueCleared: Bool?

   override init(_ testCase: XCTestCase) {
      self.expectation = testCase.expectation(description: "Response received")
      self.expectation.assertForOverFulfill = false
      super.init(testCase)
   }

   override func buzz(_ device: Buzz, isMotorsQueueCleared: Bool) {
      super.buzz(device, isMotorsQueueCleared: isMotorsQueueCleared)
      self.isMotorsQueueCleared = isMotorsQueueCleared
      expectation.fulfill()
   }

   func waitForIsMotorsQueueClearedExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [expectation], timeout: timeout)
   }
}