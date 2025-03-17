//
//  Copyright © 2025 . All rights reserved.
//

import LumaKit

final class FeedbackState {
    let colorScheme: ColorScheme
    let rating: Int

    var isSending: Bool = false
    var feedback: String?

    init(colorScheme: ColorScheme, rating: Int) {
        self.colorScheme = colorScheme
        self.rating = rating
    }
}
