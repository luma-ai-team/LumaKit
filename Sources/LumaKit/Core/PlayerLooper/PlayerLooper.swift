//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import AVFoundation

public final class PlayerLooper {

    public var asset: AVAsset {
        didSet {
            setup()
        }
    }

    public let player: SeekingPlayer = .init()
    private var playbackObserver: NSKeyValueObservation?
    public private(set) var isPlaying: Bool = false

    public init(url: URL) {
        self.asset = AVURLAsset(url: url)
        setup()
    }

    public init(asset: AVAsset) {
        self.asset = asset
        setup()
    }

    deinit {
        player.currentItem?.videoComposition = nil
        player.replaceCurrentItem(with: nil)
    }

    private func setup() {
        removeObservers()
        let item = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: item)
        setupObservers()
    }

    public func play() {
        isPlaying = true
        if player.currentItem == nil {
            setup()
        }

        player.play()
    }

    public func rewind() {
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        if isPlaying {
            player.play()
        }
    }

    public func stop() {
        isPlaying = false
        player.pause()
    }

    public func reset() {
        removeObservers()
        isPlaying = false

        player.pause()
        player.replaceCurrentItem(with: nil)
    }

    public func refresh() {
        player.currentItem?.videoComposition = player.currentItem?.videoComposition?.mutableCopy() as? AVVideoComposition
    }

    private func setupObservers() {
        removeObservers()

        playbackObserver = player.observe(\.rate, options: [.new]) { [weak self] (player: SeekingPlayer,
                                                                                  change: NSKeyValueObservedChange<Float>) in
            guard let self = self,
                  self.isPlaying,
                  change.newValue == 0.0 else {
                return
            }

            self.rewind()
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    @objc private func didEnterBackground() {
        stop()
    }

    @objc private func willEnterForeground() {
        guard player.currentItem != nil else {
            return
        }

        play()
    }

    private func removeObservers() {
        if let playbackObserver = playbackObserver {
            playbackObserver.invalidate()
            self.playbackObserver = nil
        }

        NotificationCenter.default.removeObserver(self)
    }
}

