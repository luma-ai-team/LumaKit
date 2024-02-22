//
//  Copyright © 2020 Rosberry. All rights reserved.
//

public protocol ServiceInitializable: AnyObject {
    associatedtype Dependencies
    init(dependencies: Dependencies)
}
