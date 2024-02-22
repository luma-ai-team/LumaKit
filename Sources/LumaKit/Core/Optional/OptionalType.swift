//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

protocol OptionalType {
    associatedtype T
    var optional: T? { get }
}

extension Optional: OptionalType {
    typealias T = Wrapped

    var optional: T? {
        return self
    }
}
