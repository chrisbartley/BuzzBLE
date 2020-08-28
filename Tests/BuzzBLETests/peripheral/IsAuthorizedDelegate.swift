//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation
import XCTest
@testable import BuzzBLE

class IsAuthorizedDelegate: NoOpDelegate {
   private let expectation: XCTestExpectation

   var isAuthorized: Bool = false
   var errorMessage: String?

   override init(_ testCase: XCTestCase) {
      self.expectation = testCase.expectation(description: "Response received")
      self.expectation.assertForOverFulfill = false
      super.init(testCase)
   }

   override func buzz(_ device: Buzz, isAuthorized: Bool, errorMessage: String?) {
      self.isAuthorized = isAuthorized
      self.errorMessage = errorMessage
      expectation.fulfill()
   }

   func waitForIsAuthorizedExpectation(timeout: TimeInterval = 5) {
      testCase.wait(for: [expectation], timeout: timeout)
   }
}
