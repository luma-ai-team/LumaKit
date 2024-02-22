//
//  Copyright © 2024 Luma AI. All rights reserved.
//

extension FloatingPoint {

    public func denormalized(from: Self, through: Self) -> Self {
        return from + (through - from) * self
    }

    public func denormalized(in range: ClosedRange<Self>) -> Self {
        return range.lowerBound + (range.upperBound - range.lowerBound) * self
    }

    public func normalized(from: Self, through: Self) -> Self {
        return (self - from) / (through - from)
    }

    public func normalized(in range: ClosedRange<Self>) -> Self {
        return (self - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    public func mirrored(around value: Self) -> Self {
        return self + 2 * (value - self)
    }
}
