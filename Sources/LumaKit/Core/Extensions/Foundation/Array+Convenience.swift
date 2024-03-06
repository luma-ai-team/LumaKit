//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

public extension Array where Element: Equatable {
    mutating func removeAll(matching value: Element) {
        removeAll { element in
            element == value
        }
    }
}

public extension Array {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Self {
        return sorted { (lhs: Element, rhs: Element) in
            return lhs[keyPath: keyPath] <= rhs[keyPath: keyPath]
        }
    }
}

public extension Array where Element: AnyObject {
    func containsReference<T: AnyObject>(to object: T) -> Bool {
        return contains { (element: Element) in
            return element === object
        }
    }

    func firstIndexWithReference<T>(to object: T) -> Int? {
        return firstIndex { (element: Element) in
            return element as AnyObject === object as AnyObject
        }
    }

    mutating func removeFirstReference<T>(to object: T) {
        guard let index = firstIndexWithReference(to: object) else {
            return
        }

        remove(at: index)
    }
}

public extension Array where Element: Collection, Element.Index == Int {
    func firstIndexPath<T: Equatable>(with reference: T, at keyPath: KeyPath<Element.Element, T>) -> IndexPath? {
        for (sectionIndex, section) in self.enumerated() {
            guard let itemIndex = section.firstIndex(with: reference, at: keyPath) else {
                continue
            }

            return IndexPath(item: itemIndex, section: sectionIndex)
        }

        return nil
    }
}

public extension Array {
    mutating func shiftLeft() {
        guard isEmpty == false else {
            return
        }

        let element = removeFirst()
        append(element)
    }

    mutating func shiftRight() {
        guard isEmpty == false else {
            return
        }

        let element = removeLast()
        insert(element, at: 0)
    }
}

// MARK: - Weak

public extension Array where Element: Weak {

    var strongReferences: [Element.T] {
        return compactMap({ (element: Element) -> Element.T? in
            return element.object
        })
    }

    mutating func append(weak: Element.T) {
        guard let object: Element = WeakRef(object: weak) as? Element else {
            return
        }

        append(object)
    }

    mutating func remove(_ weak: Element.T) {
        for (index, element) in enumerated() where element.object === weak {
            remove(at: index)
            break
        }
    }

    mutating func compact() -> Array {
        self = filter { (element: Element) -> Bool in
            return element.object != nil
        }

        return self
    }
}

