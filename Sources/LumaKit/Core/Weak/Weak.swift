//
//  Copyright © 2024 Luma AI. All rights reserved.
//

public protocol Weak: AnyObject {
    // swiftlint:disable:next type_name
    associatedtype T: AnyObject
    var object: T? { get }
}

public final class WeakRef<T: AnyObject>: Weak {
    private(set) public weak var object: T?
    public init(object: T) {
        self.object = object
    }
}
