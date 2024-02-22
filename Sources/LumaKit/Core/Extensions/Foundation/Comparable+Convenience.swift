//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

extension Comparable {

    public func clamped(min: Self, max: Self) -> Self {
        if self < min {
            return min
        }

        if self > max {
            return max
        }

        return self
    }

    public func clamped(in range: ClosedRange<Self>) -> Self {
        return clamped(min: range.lowerBound, max: range.upperBound)
    }
}

extension Comparable where Self: Numeric {

    private func wrapped(min: Self, max: Self, maxComparator: (Self, Self) -> Bool) -> Self {
        var interval = max - min
        guard interval != 0 else {
            return min
        }

        if interval < 0 {
            interval *= -1
        }

        var result = self
        while result < min {
            result += interval
        }

        while maxComparator(result, max) {
            result -= interval
        }

        return result
    }

    public func wrapped(from: Self, to: Self) -> Self {
        return wrapped(min: from, max: to, maxComparator: >=)
    }

    public func wrapped(from: Self, through: Self) -> Self {
        return wrapped(min: from, max: through, maxComparator: >)
    }

    public func wrapped(in range: ClosedRange<Self>) -> Self {
        return wrapped(min: range.lowerBound, max: range.upperBound, maxComparator: >)
    }
}

extension Comparable where Self == Int {
    public func wrappedIndex<T: Collection>(in collection: T) -> Self {
        return wrapped(from: 0, to: collection.count)
    }
}
