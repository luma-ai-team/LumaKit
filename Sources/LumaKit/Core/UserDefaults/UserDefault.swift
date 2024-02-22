//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

@propertyWrapper
public struct UserDefault<Value> {
    
    public var wrappedValue: Value {
        get {
            container.object(forKey: key) as? Value ?? defaultValue
        } set {
            container.set(newValue, forKey: key)
        }
    }

    let key: String
    let defaultValue: Value
    let container: UserDefaults

    public init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
    }
}

