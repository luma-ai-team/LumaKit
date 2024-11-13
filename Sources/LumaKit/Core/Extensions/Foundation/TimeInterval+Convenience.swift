//
//  TimeInterval+Convenience.swift
//  LumaKit
//
//  Created by Anton Kormakov on 13.11.2024.
//

import Foundation

public extension TimeInterval {

    func toShortTimecodeString(fallback: String = "--:--") -> String {
        guard isNaN == false,
              isSignalingNaN == false,
              isInfinite == false else {
            return fallback
        }

        let rounded = self.rounded()
        let seconds = String(format: "%02d", Int(rounded) % 60)
        let minutes = String(format: "%02d", (Int(rounded) / 60) % 60)

        let hoursAmount = Int(self) / 3600
        if hoursAmount > 0 {
            let hours = String(format: "%02d", hoursAmount)
            return "\(hours):\(minutes):\(seconds)"
        }

        return "\(minutes):\(seconds)"
    }
}
