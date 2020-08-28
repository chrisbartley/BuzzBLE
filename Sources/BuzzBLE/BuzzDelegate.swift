//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation

public protocol BuzzDelegate: class {
   func buzz(_ device: Buzz, isCommunicationEnabled: Bool, error: Error?)

   func buzz(_ device: Buzz, isAuthorized: Bool, errorMessage: String?)

   func buzz(_ device: Buzz, batteryInfo: Buzz.BatteryInfo)
   func buzz(_ device: Buzz, deviceInfo: Buzz.DeviceInfo)
   func buzz(_ device: Buzz, isMicEnabled: Bool)
   func buzz(_ device: Buzz, areMotorsEnabled: Bool)
   func buzz(_ device: Buzz, isMotorsQueueCleared: Bool)

   func buzz(_ device: Buzz, responseError error: Error)
   func buzz(_ device: Buzz, unknownCommand command: String)
   func buzz(_ device: Buzz, badRequestFor command: Buzz.Command, errorMessage: String?)
   func buzz(_ device: Buzz, failedToParse responseMessage: String, forCommand command: Buzz.Command)
}

public extension BuzzDelegate {
}
