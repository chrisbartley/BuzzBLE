//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation
import os

fileprivate extension OSLog {
   static let log = OSLog(category: "BuzzResponseProcessor")
}

protocol BuzzResponseProcessorDelegate: AnyObject {
   func handleUnknown(command: String)
   func handleResponseMessage(message: String, forCommand command: Buzz.Command)
}

class BuzzResponseProcessor {
   static private let startDelimiter: String = "{"
   static private let endDelimiter: String = "\r\nble_cli:~$ "

   weak var delegate: BuzzResponseProcessorDelegate?

   private var remainingResponse = ""

   func process(response newResponse: String) {
      // append the new to what we already have acquired but didn't consume
      remainingResponse += newResponse

      // Start by splitting on the ending delimiter, resuling in N pieces.  This should yield N-1 complete responses.
      let responses = remainingResponse.components(separatedBy: BuzzResponseProcessor.endDelimiter)

      // loop over all the pieces, but we skip the last one because it's guaranteed to not contain a complete response
      for (i, response) in responses.enumerated() {
         if i < (responses.count - 1) {
            // we've found a complete response (i.e. command + message) so find the index of the first occurrence of
            // the startDelimiter and treat everything before it as the command and everything after as the message body
            if let startRange = response.range(of: BuzzResponseProcessor.startDelimiter) {
               // pick out the command string
               let commandStr = String(response[..<startRange.lowerBound])

               // make sure this is a known command
               if let command = Buzz.Command(rawValue: commandStr) {
                  // pick out the message
                  let message = String(response[startRange.lowerBound...])

                  // notify the delegate that we have a valid command and message
                  delegate?.handleResponseMessage(message: message, forCommand: command)
               }
               else {
                  delegate?.handleUnknown(command: commandStr)
               }
            }
            else {
               os_log("BuzzResponseProcessor.process failed to find start delimiter in response=%s", log: OSLog.log, type: .debug, response)
            }
         }
         else {
            // this last bit becomes our new remainingResponse, to get consumed next time around
            remainingResponse = response
         }
      }
   }
}