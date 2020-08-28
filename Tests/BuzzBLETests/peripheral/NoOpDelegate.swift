//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import XCTest
@testable import BuzzBLE

class NoOpDelegate: BuzzDelegate {
   let testCase: XCTestCase

   init(_ testCase: XCTestCase) {
      self.testCase = testCase
   }

   func buzz(_ device: Buzz, isCommunicationEnabled: Bool, error: Error?) {
      print("NoOpDelegate.isCommunicationEnabled: \(isCommunicationEnabled)")
   }

   func buzz(_ device: Buzz, isAuthorized: Bool, errorMessage: String?) {
      print("NoOpDelegate.isAuthorized: \(isAuthorized) errorMessage=\(String(describing: errorMessage))")
   }

   func buzz(_ device: Buzz, batteryInfo: Buzz.BatteryInfo) {
      print("NoOpDelegate.batteryInfo: \(batteryInfo)")
   }

   func buzz(_ device: Buzz, deviceInfo: Buzz.DeviceInfo) {
      print("NoOpDelegate.deviceInfo: \(deviceInfo)")
   }

   func buzz(_ device: Buzz, isMicEnabled: Bool) {
      print("NoOpDelegate.isMicEnabled: \(isMicEnabled)")
   }

   func buzz(_ device: Buzz, areMotorsEnabled: Bool) {
      print("NoOpDelegate.areMotorsEnabled: \(areMotorsEnabled)")
   }

   func buzz(_ device: Buzz, isMotorsQueueCleared: Bool) {
      print("NoOpDelegate.isMotorsQueueCleared: \(isMotorsQueueCleared)")
   }

   func buzz(_ device: Buzz, responseError error: Error) {
      print("NoOpDelegate.responseError: \(error)")
   }

   func buzz(_ device: Buzz, unknownCommand command: String) {
      print("NoOpDelegate.unknownCommand: \(command)")
   }

   func buzz(_ device: Buzz, badRequestFor command: Buzz.Command, errorMessage: String?) {
      print("NoOpDelegate.badRequestFor: \(command) error message = [\(String(describing: errorMessage))]")
   }

   func buzz(_ device: Buzz, failedToParse responseMessage: String, forCommand command: Buzz.Command) {
      print("NoOpDelegate.failedToParse: \(responseMessage) forCommand \(command)")
   }
}