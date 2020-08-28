//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import XCTest
import BirdbrainBLE
@testable import BuzzBLE

final class BuzzBLETests: XCTestCase {
   // See https://oleb.net/blog/2017/03/keeping-xctest-in-sync/
   func testLinuxTestSuiteIncludesAllTests() {
      #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
         let thisClass = type(of: self)
         let linuxCount = thisClass.allTests.count
         #if swift(>=4.0)
            let darwinCount = thisClass.defaultTestSuite.testCaseCount
         #else
            let darwinCount = Int(thisClass.defaultTestSuite().testCaseCount)
         #endif
         XCTAssertEqual(linuxCount, darwinCount, "\(darwinCount - linuxCount) tests are missing from allTests")
      #endif
   }

   private func runAdditionalTests(additionalTestsTimeout: TimeInterval = 5, _ additionalTests: (Buzz, XCTestExpectation) -> Void) {

      let delegate = ConnectDisconnectBuzzManagerDelegate(self)
      let buzzManager = BuzzManager(scanFilter: Buzz.scanFilter, delegate: delegate)

      // Wait for the enabled expectation to be fulfilled, or timeout after 5 seconds
      print("Waiting for the glow board manager to be enabled...")
      delegate.waitForEnabledExpectation()

      if delegate.state == .enabled {
         print("Scanning...")
         if buzzManager.startScanning() {
            delegate.waitForScanDiscoverSuccessExpectation()
            XCTAssertTrue(buzzManager.stopScanning())

            if let discoveredUUID = delegate.discoveredUUID {
               print("Try to connect to Buzz \(discoveredUUID) (waiting up to 20 seconds)")
               XCTAssertTrue(buzzManager.connectToBuzz(havingUUID: discoveredUUID))
               delegate.waitForConnectSuccessExpectation(timeout: 20)

               if let connectedUUID = delegate.connectedUUID {
                  if let buzz = buzzManager.getBuzz(uuid: connectedUUID) {
                     print("Connected to Buzz \(buzz.uuid)")
                     print("[\(Date().timeIntervalSince1970)]: Start running tests...")
                     let additionalTestsDoneExpectation = expectation(description: "Additional tests are done")
                     additionalTests(buzz, additionalTestsDoneExpectation)
                     print("[\(Date().timeIntervalSince1970)]: Waiting for additional tests to complete...")
                     wait(for: [additionalTestsDoneExpectation], timeout: additionalTestsTimeout)
                     print("[\(Date().timeIntervalSince1970)]: Done running additional tests!")

                     print("[\(Date().timeIntervalSince1970)]: Disconnecting from UART \(buzz.uuid)")
                     XCTAssertTrue(buzzManager.disconnectFromBuzz(havingUUID: buzz.uuid))
                     delegate.waitForDisconnectSuccessExpectation()
                     XCTAssertTrue(true)
                  }
                  else {
                     XCTFail("No connected UART!")
                  }
               }
               else {
                  XCTFail("No connected UUID!")
               }
            }
            else {
               XCTFail("No discovered UART!")
            }
         }
         else {
            XCTFail("Scanning should have started")
         }
      }
      else {
         XCTFail("BLE disabled!")
      }
   }

   func testDeviceDisappearanceSuccess() {
      let delegate = DisappearBuzzManagerDelegate(self)
      let buzzManager = BuzzManager(scanFilter: Buzz.scanFilter, delegate: delegate)

      // Wait for the enabled expectation to be fulfilled, or timeout after 5 seconds
      print("Waiting for BuzzManager to be enabled...")
      delegate.waitForEnabledExpectation()

      print("Scanning...")
      if buzzManager.startScanning() {
         delegate.waitForScanDiscoverSuccessExpectation()
         print("\nACTION REQUIRED: Now turn off the device to test device disappearance...\n")
         delegate.waitForDisappearExpectation(timeout: 60.0)
         XCTAssertTrue(buzzManager.stopScanning())
      }
      else {
         XCTFail("Scanning should have started")
      }
   }

   func testConnectDisconnectSuccess() {
      runAdditionalTests(additionalTestsTimeout: 5) { (buzz, testsDoneExpectation) in
         testsDoneExpectation.fulfill()
      }
   }

   func testUnknownCommand() {
      runAdditionalTests(additionalTestsTimeout: 5) { (buzz, testsDoneExpectation) in

         let delegate = UnknownCommandDelegate(self)
         buzz.delegate = delegate

         buzz.enableCommuication()
         delegate.waitForIsCommunicationEnabledExpectation()

         XCTAssertTrue(buzz.writeWithoutResponse(bytes: Array("bogus command\n".utf8)))

         delegate.waitForUnknownCommandExpectation()

         XCTAssertNotNil(delegate.unknownCommand)

         DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            print("[\(Date().timeIntervalSince1970)]: Calling testsDoneExpectation.fulfill()")
            testsDoneExpectation.fulfill()
         })
      }
   }

   func testBatteryInfo() {
      runAdditionalTests(additionalTestsTimeout: 5) { (buzz, testsDoneExpectation) in

         let delegate = BatteryInfoDelegate(self)
         buzz.delegate = delegate

         buzz.enableCommuication()
         delegate.waitForIsCommunicationEnabledExpectation()

         buzz.requestBatteryInfo()

         delegate.waitForExpectation()

         XCTAssertNotNil(delegate.batteryInfo)
         if let batteryInfo = delegate.batteryInfo {
            print(batteryInfo)
         }

         DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            print("[\(Date().timeIntervalSince1970)]: Calling testsDoneExpectation.fulfill()")
            testsDoneExpectation.fulfill()
         })
      }
   }

   func testDeviceInfo() {
      runAdditionalTests(additionalTestsTimeout: 5) { (buzz, testsDoneExpectation) in

         let delegate = DeviceInfoDelegate(self)
         buzz.delegate = delegate

         buzz.enableCommuication()
         delegate.waitForIsCommunicationEnabledExpectation()

         buzz.requestDeviceInfo()

         delegate.waitForExpectation()

         XCTAssertNotNil(delegate.deviceInfo)
         if let deviceInfo = delegate.deviceInfo {
            print(deviceInfo)
         }

         DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            print("[\(Date().timeIntervalSince1970)]: Calling testsDoneExpectation.fulfill()")
            testsDoneExpectation.fulfill()
         })
      }
   }

   func testAuthorize() {
      runAdditionalTests(additionalTestsTimeout: 5) { (buzz, testsDoneExpectation) in

         // enable communication
         let commEnabledDelegate = IsCommunicationEnabledDelegate(self)
         buzz.delegate = commEnabledDelegate
         buzz.enableCommuication()
         commEnabledDelegate.waitForIsCommunicationEnabledExpectation()

         let delegate = IsAuthorizedDelegate(self)
         buzz.delegate = delegate

         buzz.authorize()

         delegate.waitForIsAuthorizedExpectation()

         XCTAssertTrue(delegate.isAuthorized)

         DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            print("[\(Date().timeIntervalSince1970)]: Calling testsDoneExpectation.fulfill()")
            testsDoneExpectation.fulfill()
         })
      }
   }

   func testEnableDisableMic() {
      runAdditionalTests(additionalTestsTimeout: 5) { (buzz, testsDoneExpectation) in

         // enable communication
         let commEnabledDelegate = IsCommunicationEnabledDelegate(self)
         buzz.delegate = commEnabledDelegate
         buzz.enableCommuication()
         commEnabledDelegate.waitForIsCommunicationEnabledExpectation()

         // now try to enable the mic before authorizing
         print("Attempting to enable mic without authorization")
         let badRequestDelegate1 = BadRequestDelegate(self, command: .enableMic)
         buzz.delegate = badRequestDelegate1
         buzz.enableMic()
         badRequestDelegate1.waitForBadRequestExpectation()
         XCTAssertNotNil(badRequestDelegate1.errorMessage)
         print("As expected, we failed to enable mic without authorization [\(badRequestDelegate1.errorMessage!)]")

         // now try to disable the mic before authorizing
         print("Attempting to disable mic without authorization")
         let badRequestDelegate2 = BadRequestDelegate(self, command: .disableMic)
         buzz.delegate = badRequestDelegate2
         buzz.disableMic()
         badRequestDelegate2.waitForBadRequestExpectation()
         XCTAssertNotNil(badRequestDelegate2.errorMessage)
         print("As expected, we failed to disable mic without authorization [\(badRequestDelegate2.errorMessage!)]")

         // now authorize and try again
         print("Now authorize...")
         let authDelegate = IsAuthorizedDelegate(self)
         buzz.delegate = authDelegate
         buzz.authorize()
         authDelegate.waitForIsAuthorizedExpectation()
         XCTAssertTrue(authDelegate.isAuthorized)
         print("Authorization successful!")

         print("Try enabling the mic now that we're authorized")
         let micDelegate1 = IsMicEnabledDelegate(self)
         buzz.delegate = micDelegate1
         buzz.enableMic()
         micDelegate1.waitForIsMicEnabledExpectation()
         XCTAssertNotNil(micDelegate1.isMicEnabled)
         XCTAssertTrue(micDelegate1.isMicEnabled!)

         print("Try disabling the mic now that we're authorized")
         let micDelegate2 = IsMicEnabledDelegate(self)
         buzz.delegate = micDelegate2
         buzz.disableMic()
         micDelegate2.waitForIsMicEnabledExpectation()
         XCTAssertNotNil(micDelegate2.isMicEnabled)
         XCTAssertFalse(micDelegate2.isMicEnabled!)

         DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            print("[\(Date().timeIntervalSince1970)]: Calling testsDoneExpectation.fulfill()")
            testsDoneExpectation.fulfill()
         })
      }
   }

   func testEnableDisableMotors() {
      runAdditionalTests(additionalTestsTimeout: 5) { (buzz, testsDoneExpectation) in

         // enable communication
         let commEnabledDelegate = IsCommunicationEnabledDelegate(self)
         buzz.delegate = commEnabledDelegate
         buzz.enableCommuication()
         commEnabledDelegate.waitForIsCommunicationEnabledExpectation()

         // now try to enable the motors before authorizing
         print("Attempting to enable motors without authorization")
         let badRequestDelegate1 = BadRequestDelegate(self, command: .enableMotors)
         buzz.delegate = badRequestDelegate1
         buzz.enableMotors()
         badRequestDelegate1.waitForBadRequestExpectation()
         XCTAssertNotNil(badRequestDelegate1.errorMessage)
         print("As expected, we failed to enable motors without authorization [\(badRequestDelegate1.errorMessage!)]")

         // now try to disable the motors before authorizing
         print("Attempting to disable motors without authorization")
         let badRequestDelegate2 = BadRequestDelegate(self, command: .disableMotors)
         buzz.delegate = badRequestDelegate2
         buzz.disableMotors()
         badRequestDelegate2.waitForBadRequestExpectation()
         XCTAssertNotNil(badRequestDelegate2.errorMessage)
         print("As expected, we failed to disable motors without authorization [\(badRequestDelegate2.errorMessage!)]")

         // now authorize and try again
         print("Now authorize...")
         let authDelegate = IsAuthorizedDelegate(self)
         buzz.delegate = authDelegate
         buzz.authorize()
         authDelegate.waitForIsAuthorizedExpectation()
         XCTAssertTrue(authDelegate.isAuthorized)
         print("Authorization successful!")

         print("Try enabling the motors now that we're authorized")
         let motorsDelegate1 = AreMotorsEnabledDelegate(self)
         buzz.delegate = motorsDelegate1
         buzz.enableMotors()
         motorsDelegate1.waitForAreMotorsEnabledExpectation()
         XCTAssertNotNil(motorsDelegate1.areMotorsEnabled)
         XCTAssertTrue(motorsDelegate1.areMotorsEnabled!)

         print("Try disabling the motors now that we're authorized")
         let motorsDelegate2 = AreMotorsEnabledDelegate(self)
         buzz.delegate = motorsDelegate2
         buzz.disableMotors()
         motorsDelegate2.waitForAreMotorsEnabledExpectation()
         XCTAssertNotNil(motorsDelegate2.areMotorsEnabled)
         XCTAssertFalse(motorsDelegate2.areMotorsEnabled!)

         DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            print("[\(Date().timeIntervalSince1970)]: Calling testsDoneExpectation.fulfill()")
            testsDoneExpectation.fulfill()
         })
      }
   }

   func testClearMotorsQueue() {
      runAdditionalTests(additionalTestsTimeout: 5) { (buzz, testsDoneExpectation) in

         // enable communication
         let commEnabledDelegate = IsCommunicationEnabledDelegate(self)
         buzz.delegate = commEnabledDelegate
         buzz.enableCommuication()
         commEnabledDelegate.waitForIsCommunicationEnabledExpectation()

         // now try to clear the motors queue before authorizing
         print("Attempting to clear the motors queue without authorization")
         let badRequestDelegate = BadRequestDelegate(self, command: .clearMotorsQueue)
         buzz.delegate = badRequestDelegate
         buzz.clearMotorsQueue()
         badRequestDelegate.waitForBadRequestExpectation()
         XCTAssertNotNil(badRequestDelegate.errorMessage)
         print("As expected, we failed to clear the motors queue without authorization [\(badRequestDelegate.errorMessage!)]")

         // now authorize and try again
         print("Now authorize...")
         let authDelegate = IsAuthorizedDelegate(self)
         buzz.delegate = authDelegate
         buzz.authorize()
         authDelegate.waitForIsAuthorizedExpectation()
         XCTAssertTrue(authDelegate.isAuthorized)
         print("Authorization successful!")

         print("Try clearing the motors queue now that we're authorized")
         let motorsQueueClearedDelegate = IsMotorsQueueClearedDelegate(self)
         buzz.delegate = motorsQueueClearedDelegate
         buzz.clearMotorsQueue()
         motorsQueueClearedDelegate.waitForIsMotorsQueueClearedExpectation()
         XCTAssertNotNil(motorsQueueClearedDelegate.isMotorsQueueCleared)
         XCTAssertTrue(motorsQueueClearedDelegate.isMotorsQueueCleared!)

         DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            print("[\(Date().timeIntervalSince1970)]: Calling testsDoneExpectation.fulfill()")
            testsDoneExpectation.fulfill()
         })
      }
   }

   static var allTests = [
      ("testLinuxTestSuiteIncludesAllTests", testLinuxTestSuiteIncludesAllTests),
      ("testDeviceDisappearanceSuccess", testDeviceDisappearanceSuccess),
      ("testConnectDisconnectSuccess", testConnectDisconnectSuccess),
      ("testUnknownCommand", testUnknownCommand),
      ("testBatteryInfo", testBatteryInfo),
      ("testDeviceInfo", testDeviceInfo),
      ("testAuthorize", testAuthorize),
      ("testEnableDisableMic", testEnableDisableMic),
      ("testEnableDisableMotors", testEnableDisableMotors),
      ("testClearMotorsQueue", testClearMotorsQueue),
   ]
}
