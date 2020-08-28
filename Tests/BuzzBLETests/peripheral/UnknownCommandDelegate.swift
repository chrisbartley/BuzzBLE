//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation
import XCTest
@testable import BuzzBLE

class UnknownCommandDelegate: IsCommunicationEnabledDelegate {
   private let expectation: XCTestExpectation

   var unknownCommand: String?

   override init(_ testCase: XCTestCase) {
      self.expectation = testCase.expectation(description: "Response received")
      self.expectation.assertForOverFulfill = false
      super.init(testCase)
   }

   override func buzz(_ device: Buzz, unknownCommand command: String) {
      super.buzz(device, unknownCommand: command)
      self.unknownCommand = command
      expectation.fulfill()
   }

   func waitForUnknownCommandExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [expectation], timeout: timeout)
   }
}