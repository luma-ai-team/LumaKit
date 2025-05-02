//
//  Copyright © 2025 . All rights reserved.
//

import LumaKit

final class FeedbackState {
    let colorScheme: ColorScheme
    let materialStyle: MaterialStyle
    let rating: Int

    var isSending: Bool = false
    var feedback: String?

    init(colorScheme: ColorScheme, materialStyle: MaterialStyle = .default, rating: Int) {
        self.colorScheme = colorScheme
        self.materialStyle = materialStyle
        self.rating = rating
    }
}
