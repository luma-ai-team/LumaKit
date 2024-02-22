//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

extension Collection {
    func containsReference<T: AnyObject>(to object: T?, at keyPath: KeyPath<Element, T?>) -> Bool {
        return contains { (element: Element) in
            return element[keyPath: keyPath] === object
        }
    }

    func first<T>(with reference: T?, at keyPath: KeyPath<Element, T?>) -> Element? {
        return first { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === reference as AnyObject
        }
    }

    func first<T>(with reference: T, at keyPath: KeyPath<Element, T>) -> Element? {
        return first { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === reference as AnyObject
        }
    }

    func first<T: Equatable>(with reference: T, at keyPath: KeyPath<Element, T>) -> Element? {
        return first { (element: Element) in
            return element[keyPath: keyPath] == reference
        }
    }

    func firstIndex<T: Equatable>(with reference: T, at keyPath: KeyPath<Element, T>) -> Index? {
        return firstIndex { (element: Element) in
            return element[keyPath: keyPath] == reference
        }
    }

    func firstIndex<T>(with reference: T?, at keyPath: KeyPath<Element, T>) -> Index? {
        return firstIndex { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === reference as AnyObject
        }
    }

    func filter<T>(with reference: T?, at keyPath: KeyPath<Element, T?>) -> [Element] {
        return filter { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === reference as AnyObject
        }
    }

    func filter<T>(with reference: T, at keyPath: KeyPath<Element, T>) -> [Element] {
        return filter { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === reference as AnyObject
        }
    }

    func contains<T>(with reference: T?, at keyPath: KeyPath<Element, T?>) -> Bool {
        return contains { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === reference as AnyObject
        }
    }

    func contains<T>(with reference: T, at keyPath: KeyPath<Element, T>) -> Bool {
        return contains { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === reference as AnyObject
        }
    }
}

// MARK: - Optional

extension Collection where Element: OptionalType {
    func compact() -> [Element.T] {
        return compactMap { (element: Element) -> Element.T? in
            return element.optional
        }
    }
}
