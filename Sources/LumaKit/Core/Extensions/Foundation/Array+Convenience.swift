//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeAll(matching reference: Element) {
        removeAll { element in
            element == reference
        }
    }
}

extension Array {
    func sorted<T: Comparable>(by keyPath: KeyPath<Element, T>) -> Self {
        return sorted { (lhs: Element, rhs: Element) in
            return lhs[keyPath: keyPath] <= rhs[keyPath: keyPath]
        }
    }
}

extension Array where Element: AnyObject {
    func containsReference<T: AnyObject>(to object: T) -> Bool {
        return contains { (element: Element) in
            return element === object
        }
    }

    func firstIndex<T>(of reference: T) -> Int? {
        return firstIndex { (element: Element) in
            return element as AnyObject === reference as AnyObject
        }
    }

    mutating func removeFirst<T>(_ reference: T) {
        guard let index = firstIndex(of: reference) else {
            return
        }

        remove(at: index)
    }
}

extension Array where Element: Collection, Element.Index == Int {
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

