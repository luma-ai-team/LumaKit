//
//  Copyright © 2025 . All rights reserved.
//

import LumaKit

final class FeedbackState {
    let colorScheme: ColorScheme
    var isSending: Bool = false
    var feedback: String?

    init(colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
}
