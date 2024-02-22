//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import CoreMedia

infix operator ~+ : AdditionPrecedence
infix operator ~- : AdditionPrecedence

extension CMTime {
    public typealias DictionaryRepresentation = [String: Int64]

    public static func * (lhs: CMTime, rhs: TimeInterval) -> CMTime {
        return CMTime(seconds: lhs.seconds * rhs, preferredTimescale: lhs.timescale)
    }

    public static func / (lhs: CMTime, rhs: TimeInterval) -> CMTime {
        return CMTime(seconds: lhs.seconds / rhs, preferredTimescale: lhs.timescale)
    }

    @discardableResult
    public static func += (lhs: inout CMTime, rhs: CMTime) -> CMTime {
        lhs = lhs + rhs
        return lhs
    }

    @discardableResult
    public static func -= (lhs: inout CMTime, rhs: CMTime) -> CMTime {
        lhs = lhs - rhs
        return lhs
    }

    public static func + (lhs: CMTime, rhs: TimeInterval) -> CMTime {
        return lhs + CMTime(seconds: rhs, preferredTimescale: lhs.timescale)
    }

    public static func - (lhs: CMTime, rhs: TimeInterval) -> CMTime {
        return lhs - CMTime(seconds: rhs, preferredTimescale: lhs.timescale)
    }

    public static func ~+ (lhs: CMTime, rhs: TimeInterval) -> CMTime {
        return lhs + CMTime(seconds: rhs, preferredTimescale: .init(NSEC_PER_SEC))
    }

    public static func ~- (lhs: CMTime, rhs: TimeInterval) -> CMTime {
        return lhs - CMTime(seconds: rhs, preferredTimescale: .init(NSEC_PER_SEC))
    }

    public func dictionaryRepresentation() -> DictionaryRepresentation {
        return [
            "value": value,
            "timescale": Int64(timescale)
        ]
    }

    public init?(dictionaryRepresentation: DictionaryRepresentation) {
        guard let value = dictionaryRepresentation["value"],
              let timescale = dictionaryRepresentation["timescale"] else {
            return nil
        }

        self.init()
        self.value = value
        self.timescale = Int32(clamping: timescale)
        self.flags = [.valid]
    }
}

extension CMTimeRange {
    public typealias DictionaryRepresentation = [String: CMTime.DictionaryRepresentation]

    public var mid: CMTime {
        return CMTimeAdd(start, CMTimeMultiplyByFloat64(duration, multiplier: 0.5))
    }

    public static func + (lhs: CMTimeRange, rhs: CMTime) -> CMTimeRange {
        return CMTimeRange(start: lhs.start + rhs, duration: lhs.duration)
    }

    public static func * (lhs: CMTimeRange, rhs: TimeInterval) -> CMTimeRange {
        let duration = CMTime(seconds: lhs.duration.seconds * rhs, preferredTimescale: lhs.duration.timescale)
        return CMTimeRange(start: lhs.start, duration: duration)
    }

    public static func / (lhs: CMTimeRange, rhs: TimeInterval) -> CMTimeRange {
        let duration = CMTime(seconds: lhs.duration.seconds / rhs, preferredTimescale: lhs.duration.timescale)
        return CMTimeRange(start: lhs.start, duration: duration)
    }

    public func inset(by timeInterval: TimeInterval) -> CMTimeRange {
        return CMTimeRange(start: start + timeInterval, end: end - timeInterval)
    }

    public func increasingDuration(by timeInterval: TimeInterval) -> CMTimeRange {
        return CMTimeRange(start: start, duration: duration + timeInterval)
    }

    public func dictionaryRepresentation() -> DictionaryRepresentation {
        return [
            "start": start.dictionaryRepresentation(),
            "end": end.dictionaryRepresentation()
        ]
    }

    public init?(dictionaryRepresentation: DictionaryRepresentation) {
        guard let startDictionary = dictionaryRepresentation["start"], 
              let start = CMTime(dictionaryRepresentation: startDictionary),
              let endDictionary = dictionaryRepresentation["end"],
              let end = CMTime(dictionaryRepresentation: endDictionary) else {
            return nil
        }

        self.init(start: start, end: end)
    }
}
