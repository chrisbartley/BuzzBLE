//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import XCTest
@testable import BuzzBLE

class IsCommunicationEnabledDelegate: NoOpDelegate {
   private let expectation: XCTestExpectation

   override init(_ testCase: XCTestCase) {
      self.expectation = testCase.expectation(description: "Response received")
      self.expectation.assertForOverFulfill = false
      super.init(testCase)
   }

   override func buzz(_ device: Buzz, isCommunicationEnabled: Bool, error: Error?) {
      super.buzz(device, isCommunicationEnabled: isCommunicationEnabled, error: error)
      if isCommunicationEnabled {
         expectation.fulfill()
      }
   }

   func waitForIsCommunicationEnabledExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [expectation], timeout: timeout)
   }
}
