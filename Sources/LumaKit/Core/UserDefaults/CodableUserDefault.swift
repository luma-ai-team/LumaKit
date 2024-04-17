//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

@propertyWrapper
public struct CodableUserDefault<Value: Codable> {

    public var wrappedValue: Value {
        get {
            guard let data = container.data(forKey: key),
                  let value = try? JSONDecoder().decode(Value.self, from: data) else {
                return defaultValue
            }

            return value
        } set {
            let data = try? JSONEncoder().encode(newValue)
            container.set(data, forKey: key)
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


