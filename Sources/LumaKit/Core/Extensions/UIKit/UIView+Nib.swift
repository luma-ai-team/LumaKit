//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIView {
    class func fromNib<T: UIView>(bundle: Bundle = .main) -> T {
        let name = String(describing: T.self)
        guard let result = bundle.loadNibNamed(name, owner: nil, options: nil) else {
            return .init()
        }
        
        return (result.first as? T) ?? .init()
    }
}
