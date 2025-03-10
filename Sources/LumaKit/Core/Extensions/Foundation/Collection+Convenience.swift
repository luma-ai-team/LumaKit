//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

public extension Collection where Index == Int {

    subscript(safe index: Index) -> Element? {
        guard indices.contains(index) else {
            return nil
        }

        return self[index]
    }

    subscript(indices: [Index]) -> [Element] {
        var result: [Element] = []
        for index in indices where indices.contains(index) {
            let element = self[index]
            result.append(element)
        }

        return result
    }
}

public extension Collection {

    // MARK: - First

    func firstWithReference<T>(to object: T?, at keyPath: KeyPath<Element, T?>) -> Element? {
        return first { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === object as AnyObject
        }
    }

    func firstWithReference<T>(to object: T, at keyPath: KeyPath<Element, T>) -> Element? {
        return first { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === object as AnyObject
        }
    }

    func first<T: Equatable>(with value: T, at keyPath: KeyPath<Element, T>) -> Element? {
        return first { (element: Element) in
            return element[keyPath: keyPath] == value
        }
    }

    func first<T: Equatable>(with value: T?, at keyPath: KeyPath<Element, T?>) -> Element? {
        return first { (element: Element) in
            return element[keyPath: keyPath] == value
        }
    }

    func firstAs<T>() -> T? {
        return first { (element: Element) in
            return element is T
        } as? T
    }

    // MARK: - Index

    func firstIndexWithReference<T>(to object: T, at keyPath: KeyPath<Element, T>) -> Index? {
        return firstIndex { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === object as AnyObject
        }
    }

    func firstIndexWithReference<T>(to object: T?, at keyPath: KeyPath<Element, T?>) -> Index? {
        return firstIndex { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === object as AnyObject
        }
    }

    func firstIndex<T: Equatable>(with value: T, at keyPath: KeyPath<Element, T>) -> Index? {
        return firstIndex { (element: Element) in
            return element[keyPath: keyPath] == value
        }
    }

    func firstIndex<T: Equatable>(with value: T?, at keyPath: KeyPath<Element, T?>) -> Index? {
        return firstIndex { (element: Element) in
            return element[keyPath: keyPath] == value
        }
    }

    func firstIndexAs<T>() -> T? {
        return firstIndex { (element: Element) in
            return element is T
        } as? T
    }

    // MARK: - Filter

    func filterWithReference<T>(to object: T?, at keyPath: KeyPath<Element, T?>) -> [Element] {
        return filter { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === object as AnyObject
        }
    }

    func filterWithReference<T>(with object: T, at keyPath: KeyPath<Element, T>) -> [Element] {
        return filter { (element: Element) in
            return element[keyPath: keyPath] as AnyObject === object as AnyObject
        }
    }

    func filter<T: Equatable>(with value: T, at keyPath: KeyPath<Element, T>) -> [Element] {
        return filter { (element: Element) in
            return element[keyPath: keyPath] == value
        }
    }

    func filter<T: Equatable>(with value: T?, at keyPath: KeyPath<Element, T?>) -> [Element] {
        return filter { (element: Element) in
            return element[keyPath: keyPath] == value
        }
    }

    // MARK: - Contains

    func containsWithReference<T: AnyObject>(to object: T?, at keyPath: KeyPath<Element, T?>) -> Bool {
        return contains { (element: Element) in
            return element[keyPath: keyPath] === object
        }
    }

    func contains<T: Equatable>(with value: T, at keyPath: KeyPath<Element, T>) -> Bool {
        return contains { (element: Element) in
            return element[keyPath: keyPath] == value
        }
    }

    func contains<T: Equatable>(with value: T?, at keyPath: KeyPath<Element, T?>) -> Bool {
        return contains { (element: Element) in
            return element[keyPath: keyPath] == value
        }
    }
}

// MARK: - Optional

public extension Collection where Element: OptionalType {
    func compact() -> [Element.T] {
        return compactMap { (element: Element) -> Element.T? in
            return element.optional
        }
    }
}
