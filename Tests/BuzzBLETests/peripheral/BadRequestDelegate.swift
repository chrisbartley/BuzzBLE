//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation
import XCTest
@testable import BuzzBLE

class BadRequestDelegate: NoOpDelegate {
   private let expectation: XCTestExpectation
   private let command: Buzz.Command

   var errorMessage: String?

   init(_ testCase: XCTestCase, command: Buzz.Command) {
      self.command = command
      self.expectation = testCase.expectation(description: "Response received")
      self.expectation.assertForOverFulfill = false
      super.init(testCase)
   }

   override func buzz(_ device: Buzz, badRequestFor command: Buzz.Command, errorMessage: String?) {
      if command == self.command {
         self.errorMessage = errorMessage
         expectation.fulfill()
      }
   }

   func waitForBadRequestExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [expectation], timeout: timeout)
   }
}