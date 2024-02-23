//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

public extension String {

    func matches(_ pattern: String, options: NSRegularExpression.Options = []) throws -> Bool {
        let expression = try NSRegularExpression(pattern: pattern, options: options)
        return expression.matches(in: self, options: [], range: NSRange(location: 0, length: count)).count != 0
    }

}
