//
// Created by Chris Bartley <chris@chrisbartley.com>
//

import Foundation
import os

extension OSLog {
   static private let DEFAULT_BUNDLE_IDENTIFIER = "com.chrisbartley.buzzble"

   convenience init(category: String) {
      self.init(subsystem: Bundle.main.bundleIdentifier ?? OSLog.DEFAULT_BUNDLE_IDENTIFIER, category: category)
   }
}