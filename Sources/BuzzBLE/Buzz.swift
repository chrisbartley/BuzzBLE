//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation
import os
import CoreBluetooth
import BirdbrainBLE

fileprivate extension OSLog {
   static let log = OSLog(category: "Buzz")
}

public class Buzz: ManageableUARTDevice {

   public enum Command: String, CaseIterable, CustomStringConvertible {
      fileprivate static let commandTerminator = "\n"

      case authAsDeveloper = "auth as developer\n"
      case accept = "accept\n"
      case batteryInfo = "device battery_soc\n"
      case deviceInfo = "device info\n"
      case enableMic = "audio start\n"
      case disableMic = "audio stop\n"
      case enableMotors = "motors start\n"
      case disableMotors = "motors stop\n"
      case clearMotorsQueue = "motors clear_queue\n"
      case vibrateMotors = "motors vibrate\n"

      public var description: String {
         self.rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
      }

      public var bytes: [UInt8] {
         Array(self.rawValue.utf8)
      }
   }

   static public let scanFilter: UARTDeviceScanFilter = AdvertisedNamePrefixScanFilter(prefix: "Buzz")

   //MARK: - Public Properties

   public var uuid: UUID {
      blePeripheral.uuid
   }

   /// Cached copy of device info, stored after calling requestDeviceInfo(), merely for convenience.
   public var deviceInfo: DeviceInfo?

   public weak var delegate: BuzzDelegate?

   //MARK: - Private Properties

   private let responseProcessor: BuzzResponseProcessor
   private let blePeripheral: BLEPeripheral

   private var mtu: Int {
      blePeripheral.maximumWriteWithoutResponseDataLength()
   }

   //MARK: - Initializers

   required public init(blePeripheral: BLEPeripheral) {
      responseProcessor = BuzzResponseProcessor()
      self.blePeripheral = blePeripheral

      // set self as delegate
      responseProcessor.delegate = self
      self.blePeripheral.delegate = self
   }

   //MARK: - Public Methods

   public func enableCommunication() {
      _ = blePeripheral.setNotifyEnabled(onCharacteristic: UARTDeviceServicesAndCharacteristics.rxUUID)
   }

   public func authorize() {
      sendCommand(Buzz.Command.authAsDeveloper)
   }

   public func requestBatteryInfo() {
      sendCommand(Buzz.Command.batteryInfo)
   }

   public func requestDeviceInfo() {
      sendCommand(Buzz.Command.deviceInfo)
   }

   public func enableMic() {
      setMicEnabled(true)
   }

   public func disableMic() {
      setMicEnabled(false)
   }

   public func enableMotors() {
      setMotorsEnabled(true)
   }

   public func disableMotors() {
      setMotorsEnabled(false)
   }

   public func clearMotorsQueue() {
      sendCommand(Buzz.Command.clearMotorsQueue)
   }

   /// Sets vibration to zero for all motors.
   public func stopMotors() {
      setMotorVibration(0, 0, 0, 0)
   }

   public func setMotorVibration(_ motor0: UInt8, _ motor1: UInt8, _ motor2: UInt8, _ motor3: UInt8) {
      sendMotorsCommand(data: [motor0, motor1, motor2, motor3])
   }

   // TODO: Make this not crap.  Add array size check, value bounds checks, etc.  Also other methods for sending
   // multiple frames at once (taking MTU into account so we don't send too many frames).
   public func sendMotorsCommand(data: [UInt8]) {
      let encodedMotorData = Data(data).base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
      let command = Buzz.Command.vibrateMotors.description + " " + encodedMotorData + Buzz.Command.commandTerminator
      writeWithoutResponse(bytes: Array(command.utf8))
   }

   @discardableResult
   public func sendCommand(_ command: Command) -> Bool {
      return writeWithoutResponse(bytes: command.bytes)
   }

   @discardableResult
   public func writeWithResponse(bytes: [UInt8]) -> Bool {
      blePeripheral.writeWithResponse(bytes: bytes, toCharacteristic: UARTDeviceServicesAndCharacteristics.txUUID)
   }

   @discardableResult
   public func writeWithResponse(data: Data) -> Bool {
      blePeripheral.writeWithResponse(data: data, toCharacteristic: UARTDeviceServicesAndCharacteristics.txUUID)
   }

   @discardableResult
   public func writeWithoutResponse(bytes: [UInt8]) -> Bool {
      blePeripheral.writeWithoutResponse(bytes: bytes, toCharacteristic: UARTDeviceServicesAndCharacteristics.txUUID)
   }

   @discardableResult
   public func writeWithoutResponse(data: Data) -> Bool {
      blePeripheral.writeWithoutResponse(data: data, toCharacteristic: UARTDeviceServicesAndCharacteristics.txUUID)
   }

   // MARK: - Private methods

   private func setMicEnabled(_ willEnable: Bool) {
      sendCommand(willEnable ? Buzz.Command.enableMic : Buzz.Command.disableMic)
   }

   private func setMotorsEnabled(_ willEnable: Bool) {
      sendCommand(willEnable ? Buzz.Command.enableMotors : Buzz.Command.disableMotors)
   }
}

extension Buzz: BLEPeripheralDelegate {
   public func blePeripheral(_ peripheral: BLEPeripheral, didUpdateNotificationStateFor characteristicUUID: CBUUID, isNotifying: Bool, error: Error?) {
      delegate?.buzz(self, isCommunicationEnabled: isNotifying, error: error)
   }

   public func blePeripheral(_ peripheral: BLEPeripheral, didUpdateValueFor characteristicUUID: CBUUID, value: Data?, error: Error?) {
      if let error = error {
         os_log("BLEPeripheralDelegate.didUpdateValueFor uuid=%s, error=%s", log: OSLog.log, type: .error, characteristicUUID.uuidString, String(describing: error))
         delegate?.buzz(self, responseError: error)
      }
      else {
         // make sure the correct characteristic is the one doing the notifying
         guard characteristicUUID == UARTDeviceServicesAndCharacteristics.rxUUID else {
            fatalError("Received didUpdateValueFor unexpected characteristic \(characteristicUUID)")
         }

         // ignore empty response
         guard let responseData = value, !responseData.isEmpty else {
            os_log("BLEPeripheralDelegate.didUpdateValueFor ignoring empty response for uuid=%s", log: OSLog.log, type: .debug, characteristicUUID.uuidString)
            return
         }

         // os_log("BLEPeripheralDelegate.didUpdateValueFor uuid=%s, value=%s", log: OSLog.log, type: .debug, characteristicUUID.uuidString, String(describing: value))

         // convert the response data to a string, then hand it off to the response processor
         let responseStr = String(decoding: responseData, as: UTF8.self)
         responseProcessor.process(response: responseStr)
      }
   }

   public func blePeripheral(_ peripheral: BLEPeripheral, didWriteValueFor characteristicUUID: CBUUID, error: Error?) {
      if let error = error {
         os_log("BLEPeripheralDelegate.didWriteValueFor: uuid=%s|error=%s", log: OSLog.log, type: .error, characteristicUUID.uuidString, String(describing: error))
      }
      else {
         os_log("BLEPeripheralDelegate.didWriteValueFor: uuid=%s", log: OSLog.log, type: .debug, characteristicUUID.uuidString)
      }
   }
}

extension Buzz: BuzzResponseProcessorDelegate {
   func handleUnknown(command: String) {
      delegate?.buzz(self, unknownCommand: command)
   }

   // response = command + message
   func handleResponseMessage(message: String, forCommand command: Command) {
      let jsonData = Data(message.utf8)
      let decoder = JSONDecoder()

      do {
         let responseMessage = try decoder.decode(Buzz.ResponseMessage.self, from: jsonData)

         // handle bad request for commands other than the two which deal with authorization
         if responseMessage.isBadRequest && command != .authAsDeveloper && command != .accept {
            delegate?.buzz(self, badRequestFor: command, errorMessage: responseMessage.message)
            return
         }

         switch command {
            case .authAsDeveloper:
               if responseMessage.isOK {
                  writeWithoutResponse(bytes: Buzz.Command.accept.bytes)
               }
               else {
                  delegate?.buzz(self, isAuthorized: false, errorMessage: responseMessage.message)
               }

            case .accept:
               delegate?.buzz(self, isAuthorized: responseMessage.isOK, errorMessage: responseMessage.isOK ? nil : responseMessage.message)

            case .batteryInfo:
               do {
                  let battery = try decoder.decode(Buzz.BatteryInfo.self, from: jsonData)
                  delegate?.buzz(self, batteryInfo: battery)
               }
               catch {
                  delegate?.buzz(self, failedToParse: message, forCommand: command)
               }
            case .deviceInfo:
               do {
                  let deviceInfo = try decoder.decode(Buzz.DeviceInfo.self, from: jsonData)

                  // cache the device info since it's unlikely to change, then notify the delegate
                  self.deviceInfo = deviceInfo
                  delegate?.buzz(self, deviceInfo: deviceInfo)
               }
               catch {
                  delegate?.buzz(self, failedToParse: message, forCommand: command)
               }

            case .enableMic:
               delegate?.buzz(self, isMicEnabled: true)
            case .disableMic:
               delegate?.buzz(self, isMicEnabled: false)
            case .enableMotors:
               delegate?.buzz(self, areMotorsEnabled: true)
            case .disableMotors:
               delegate?.buzz(self, areMotorsEnabled: false)
            case .clearMotorsQueue:
               delegate?.buzz(self, isMotorsQueueCleared: true)
            case .vibrateMotors:
               fatalError("Unsupported command \(command)")
         }
      }
      catch {
         delegate?.buzz(self, failedToParse: message, forCommand: command)
      }
   }
}

extension Buzz {
   struct ResponseMessage: Decodable {
      enum StatusCode: Int, Decodable {
         case ok = 200
         case badRequest = 400
      }

      private enum CodingKeys: String, CodingKey {
         case code = "status_code"
         case message
      }

      let code: StatusCode
      let message: String?
      var isOK: Bool {
         code == .ok
      }
      var isBadRequest: Bool {
         code == .badRequest
      }
   }

   public struct BatteryInfo: Decodable {
      public typealias Percentage = Int

      private enum RootKeys: String, CodingKey {
         case data
      }

      private enum BatteryKeys: String, CodingKey {
         case level = "battery_soc"
      }

      public let level: Percentage

      public init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: RootKeys.self)
         let dataContainer = try container.nestedContainer(keyedBy: BatteryKeys.self, forKey: .data)
         level = try dataContainer.decode(Percentage.self, forKey: .level)
      }
   }

   public struct DeviceInfo: Decodable {
      public struct Version: CustomStringConvertible {
         public let major: Int
         public let minor: Int
         public let name: String?
         public let build: String?
         public var description: String {
            let s = "\(major).\(minor)"
            var extras = [String]()
            if let name = name {
               extras.append(name)
            }
            if let build = build {
               extras.append(build)
            }

            return s + (extras.isEmpty ? "" : " (\(extras.joined(separator: ", ")))")
         }

         public init(major: Int, minor: Int, name: String? = nil, build: String? = nil) {
            self.major = major
            self.minor = minor
            self.name = name
            self.build = build
         }
      }

      private enum RootKeys: String, CodingKey {
         case data
      }

      private enum DeviceInfoKeys: String, CodingKey {
         case deviceId = "device_id"
         case serialNumber = "serial_number"
         case major
         case minor
         case build
         case friendly
         case softDeviceMajor = "softdevice_version"
         case softDeviceMinor = "softdevice_subversion"
         case factoryImageMajor = "factory_image_major"
         case factoryImageMinor = "factory_image_minor"
         case userImageMajor = "user_image_major"
         case userImageMinor = "user_image_minor"
         case productLine = "product_line"
         case boardRevision = "board_rev"
         case bootloaderVersion = "bootloader_version"
         case bootloaderAppVersion = "bootloader_app_version"
         case nrfBootloaderVersion = "nrf_bootloader_version"
         case nrfBootloaderAppVersion = "nrf_bootloader_app_version"
      }

      public let id: String
      public let serialNumber: String
      public let productLine: Int
      public let boardRevision: Int
      public let version: Version
      public let softDeviceVersion: Version
      public let factoryImageVersion: Version
      public let userImageVersion: Version
      public let bootloaderVersion: Version
      public let nrfBootloaderVersion: Version

      public init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: RootKeys.self)
         let dataContainer = try container.nestedContainer(keyedBy: DeviceInfoKeys.self, forKey: .data)
         id = try dataContainer.decode(String.self, forKey: .deviceId)
         serialNumber = try dataContainer.decode(String.self, forKey: .serialNumber)

         productLine = try dataContainer.decode(Int.self, forKey: .productLine)
         boardRevision = try dataContainer.decode(Int.self, forKey: .boardRevision)

         version = Version(major: try dataContainer.decode(Int.self, forKey: .major),
                           minor: try dataContainer.decode(Int.self, forKey: .minor),
                           name: try? dataContainer.decode(String.self, forKey: .friendly),
                           build: try? dataContainer.decode(String.self, forKey: .build))

         softDeviceVersion = Version(major: try dataContainer.decode(Int.self, forKey: .softDeviceMajor),
                                     minor: try dataContainer.decode(Int.self, forKey: .softDeviceMinor))

         factoryImageVersion = Version(major: try dataContainer.decode(Int.self, forKey: .factoryImageMajor),
                                       minor: try dataContainer.decode(Int.self, forKey: .factoryImageMinor))

         userImageVersion = Version(major: try dataContainer.decode(Int.self, forKey: .userImageMajor),
                                    minor: try dataContainer.decode(Int.self, forKey: .userImageMinor))

         bootloaderVersion = Version(major: try dataContainer.decode(Int.self, forKey: .bootloaderVersion),
                                     minor: try dataContainer.decode(Int.self, forKey: .bootloaderAppVersion))

         nrfBootloaderVersion = Version(major: try dataContainer.decode(Int.self, forKey: .nrfBootloaderVersion),
                                        minor: try dataContainer.decode(Int.self, forKey: .nrfBootloaderAppVersion))

         // For now, I'm opting to not include the ux_log_rand, git_branch, or git_commit
      }
   }
}
