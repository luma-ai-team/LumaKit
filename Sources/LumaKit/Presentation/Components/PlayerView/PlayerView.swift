//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import AVFoundation
import UIKit

open class PlayerView: UIView {

    override public static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }

    public var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
            if let item = newValue?.currentItem {
                synchronizationLayer = .init(playerItem: item)
                setNeedsLayout()
            }
        }
    }

    public var videoGravity: AVLayerVideoGravity {
        get {
            return playerLayer.videoGravity
        }
        set {
            playerLayer.videoGravity = newValue
        }
    }

    public var isReadyForDisplay: Bool {
        return playerLayer.isReadyForDisplay == true
    }

    public var playerLayer: AVPlayerLayer! {
        return layer as? AVPlayerLayer
    }

    public var synchronizationLayer: AVSynchronizedLayer = .init() {
        didSet {
            oldValue.removeFromSuperlayer()
            layer.addSublayer(synchronizationLayer)
            setNeedsLayout()
            layoutIfNeeded()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        videoGravity = .resizeAspectFill
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        synchronizationLayer.frame = bounds
        CATransaction.commit()
    }

    public func waitForReadyState(on queue: DispatchQueue = .global(qos: .background),
                                  completion: @escaping (PlayerView) -> Void) {
        guard playerLayer.isReadyForDisplay == false else {
            completion(self)
            return
        }

        let tick: UInt32 = 1000
        let timeout: UInt32 = 100000
        var waitingTime: UInt32 = 0
        queue.async {
            while self.playerLayer.isReadyForDisplay == false {
                usleep(tick) // per Apple docs, `isReadyForDisplay` should be key-value observable, but it's not. Whoops
                waitingTime += tick

                if waitingTime >= timeout {
                    break
                }
            }

            DispatchQueue.main.async {
                completion(self)
            }
        }
    }
}

