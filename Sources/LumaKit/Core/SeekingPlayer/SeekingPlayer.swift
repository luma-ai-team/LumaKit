//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import AVFoundation

open class SeekingPlayer: AVPlayer {
    private var chaseTime: CMTime = .invalid

    public var isSeeking: Bool {
        return chaseTime.isValid
    }

    public var isPlaying: Bool {
        return rate != 0.0
    }

    public var isFinished: Bool {
        guard let item = currentItem else {
            return true
        }

        if item.forwardPlaybackEndTime.isValid {
            return currentTime() == item.forwardPlaybackEndTime
        }

        return item.duration == currentTime()
    }

    open override func seek(to time: CMTime) {
        chaseTime = time
        seekToChaseTime(completion: nil)
    }

    open func seek(to time: CMTime, completion: @escaping () -> Void) {
        chaseTime = time
        seekToChaseTime(completion: completion)
    }

    private func seekToChaseTime(completion: (() -> Void)?) {
        guard chaseTime.isValid else {
            DispatchQueue.main.async {
                self.redrawCurrentFrameIfNeeded()
                completion?()
            }
            return
        }

        guard status == .readyToPlay else {
            return
        }

        let playerTime = currentTime()
        let duration = currentItem?.duration ?? .zero
        guard playerTime != chaseTime else {
            chaseTime = .invalid
            DispatchQueue.main.async {
                self.redrawCurrentFrameIfNeeded()
                completion?()
            }
            return
        }

        if chaseTime == duration {
            chaseTime = chaseTime - .init(value: 1, timescale: 60)
        }

        let currentTime = chaseTime
        seek(to: chaseTime, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { [weak self] (_) in
            guard let self = self else {
                return
            }

            guard self.status == .readyToPlay else {
                DispatchQueue.main.asyncAfter(deadline: .now() + (1.0 / 30.0)) {
                    self.seekToChaseTime(completion: completion)
                }
                return
            }

            guard currentTime == self.chaseTime else {
                return self.seekToChaseTime(completion: completion)
            }

            self.chaseTime = .invalid
            DispatchQueue.main.async {
                self.redrawCurrentFrameIfNeeded()
                completion?()
            }
        })
    }

    open func redrawCurrentFrameIfNeeded() {
        guard let currentItem = currentItem,
              isSeeking == false,
              isPlaying == false else {
            return
        }

        currentItem.videoComposition = currentItem.videoComposition?.mutableCopy() as? AVVideoComposition
    }
}
