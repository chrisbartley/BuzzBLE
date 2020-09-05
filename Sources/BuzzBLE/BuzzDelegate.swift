//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation

public protocol BuzzDelegate: class {
   func buzz(_ buzz: Buzz, isCommunicationEnabled: Bool, error: Error?)

   func buzz(_ buzz: Buzz, isAuthorized: Bool, errorMessage: String?)

   func buzz(_ buzz: Buzz, batteryInfo: Buzz.BatteryInfo)
   func buzz(_ buzz: Buzz, deviceInfo: Buzz.DeviceInfo)
   func buzz(_ buzz: Buzz, isMicEnabled: Bool)
   func buzz(_ buzz: Buzz, areMotorsEnabled: Bool)
   func buzz(_ buzz: Buzz, isMotorsQueueCleared: Bool)

   func buzz(_ buzz: Buzz, responseError error: Error)
   func buzz(_ buzz: Buzz, unknownCommand command: String)
   func buzz(_ buzz: Buzz, badRequestFor command: Buzz.Command, errorMessage: String?)
   func buzz(_ buzz: Buzz, failedToParse responseMessage: String, forCommand command: Buzz.Command)
}

public extension BuzzDelegate {
   func buzz(_ buzz: Buzz, isCommunicationEnabled: Bool, error: Error?) {}

   func buzz(_ buzz: Buzz, isAuthorized: Bool, errorMessage: String?) {}

   func buzz(_ buzz: Buzz, batteryInfo: Buzz.BatteryInfo) {}

   func buzz(_ buzz: Buzz, deviceInfo: Buzz.DeviceInfo) {}

   func buzz(_ buzz: Buzz, isMicEnabled: Bool) {}

   func buzz(_ buzz: Buzz, areMotorsEnabled: Bool) {}

   func buzz(_ buzz: Buzz, isMotorsQueueCleared: Bool) {}

   func buzz(_ buzz: Buzz, responseError error: Error) {}

   func buzz(_ buzz: Buzz, unknownCommand command: String) {}

   func buzz(_ buzz: Buzz, badRequestFor command: Buzz.Command, errorMessage: String?) {}

   func buzz(_ buzz: Buzz, failedToParse responseMessage: String, forCommand command: Buzz.Command) {}
}
