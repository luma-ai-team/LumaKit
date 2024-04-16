//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

@available(visionOS, unavailable)
public enum Haptic {
    case impact(UIImpactFeedbackGenerator.FeedbackStyle)
    case notification(UINotificationFeedbackGenerator.FeedbackType)
    case selection

    public func generate() {
        DispatchQueue.main.async {
            switch self {
            case .impact(let style):
                UIImpactFeedbackGenerator(style: style).impactOccurred()
            case .notification(let type):
                UINotificationFeedbackGenerator().notificationOccurred(type)
            case .selection:
                UISelectionFeedbackGenerator().selectionChanged()
            }
        }
    }
}



