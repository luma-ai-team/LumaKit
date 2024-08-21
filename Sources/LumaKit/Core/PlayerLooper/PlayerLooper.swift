//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import AVFoundation

public final class PlayerLooper {

    public var url: URL {
        didSet {
            setup()
        }
    }

    public let player: SeekingPlayer = .init()
    private var playbackObserver: NSObjectProtocol?
    private(set) var isPlaying: Bool = false

    public init(url: URL) {
        self.url = url
        setup()
    }

    deinit {
        player.currentItem?.videoComposition = nil
        player.replaceCurrentItem(with: nil)
    }

    private func setup() {
        removeObservers()
        let item = AVPlayerItem(asset: .init(url: url))
        player.replaceCurrentItem(with: item)
        setupObservers()
    }

    public func play() {
        if player.currentItem == nil {
            setup()
        }

        player.play()
    }

    public func rewind() {
        player.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
        player.play()
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

        let notificationCenter = NotificationCenter.default
        playbackObserver = notificationCenter.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                          object: player.currentItem,
                                                          queue: .main) { [weak self] _ in
            self?.rewind()
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
            NotificationCenter.default.removeObserver(playbackObserver)
            self.playbackObserver = nil
        }

        NotificationCenter.default.removeObserver(self)
    }
}

