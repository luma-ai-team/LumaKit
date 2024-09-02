//
//  PlayersExampleViewController.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 02.09.2024.
//

import UIKit
import LumaKit

final class PlayersExampleViewController: UIViewController {

    private lazy var firstPlayerView: PlayerView = {
        let view = PlayerView()
        let url = Bundle.main.url(forResource: "video.mov", withExtension: nil) ?? .root
        view.player = SeekingPlayer(url: url)
        return view
    }()

    private lazy var secondPlayerView: PlayerView = {
        let view = PlayerView()
        let url = Bundle.main.url(forResource: "video-short.mov", withExtension: nil) ?? .root
        view.player = SeekingPlayer(url: url)
        return view
    }()

    private lazy var synchronizer: PlayerSynchronizer = .init()

    deinit {
        print("PlayersExampleViewController deinit")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        view.addSubview(firstPlayerView)
        view.addSubview(secondPlayerView)

        synchronizer.startTracking(with: [
            firstPlayerView.player!,
            secondPlayerView.player!
        ], rule: .any)
        synchronizer.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        firstPlayerView.frame = .init(x: 15.0,
                                      y: view.safeAreaInsets.top + 15.0,
                                      width: view.bounds.width - 30.0,
                                      height: 120.0)

        secondPlayerView.frame = .init(x: 15.0,
                                       y: firstPlayerView.frame.maxY + 15.0,
                                       width: view.bounds.width - 30.0,
                                       height: 120.0)
    }
}
