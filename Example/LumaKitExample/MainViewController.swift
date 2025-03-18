//
//  ViewController.swift
//  PurchaseKitExample
//
//  Created by Anton Kormakov on 18.10.2023.
//

import UIKit
import LumaKit
import LumaKitShare
import AVFoundation

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Example"
    }

    // MARK: - Actions

    @IBAction func moduleExampleButtonPressed(_ sender: UIButton) {
        let coordinator = ExampleCoordinator(rootViewController: self)
        _ = coordinator.start(with: .init(), dependencies: [])
    }
    
    @IBAction func elementExampleButtonPressed(_ sender: UIButton) {
        let controller = UIElementsViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func collectionViewExampleButtonPressed(_ sender: Any) {
        let controller = CollectionViewManagerExampleViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func mediaPickerExampleButtonPressed(_ sender: Any) {
        let coordinator = MediaPickerCoordinator(rootViewController: self, colorScheme: .init())
        coordinator.sources = [.library, .camera, .files]
        coordinator.selectionStyle = .ordered(4)
        coordinator.output = self
        coordinator.start()
    }

    @IBAction func playerExampleButtonPressed(_ sender: Any) {
        let controller = PlayersExampleViewController()
        navigationController?.pushViewController(controller, animated: true)
    }

    @IBAction func shareExampleButtonPressed(_ sender: Any) {
        let coordinator = ShareCoordinator(rootViewController: self)
        let destinations: [ShareDestination] = [
            InstagramShareDestination(clientId: "1326236122110662"),
            TikTokShareDestination(clientId: "sbawmcogj9ff6e2hrx"),
            FacebookShareDestination(clientId: "1326236122110662"),
            SnapchatShareDestination(clientId: "ea9ab239-dff7-4d36-9026-cd0812f3d59d"),
            WhatsAppShareDestination(),
            SystemShareDestination()
        ]
        let variants: [ShareContentFetchVariant] = [
            .init(title: "Video", icon: .add, provider: .init(fetchHandler: { (sink: AsyncPipe<Float>) async throws in
                await sink.send(0.25)
                try await Task.sleep(for: .seconds(1.0))
                await sink.send(0.5)
                try await Task.sleep(for: .seconds(1.0))
                let url = try Bundle.main.url(forResource: "video", withExtension: "mov").unwrap()
                return [.url(url)]
            })),
            .init(title: "Audio", icon: .checkmark, provider: .init(isPhotoLibraryAutosaveEnabled: false,
                                                                    fetchHandler: { (sink: AsyncPipe<Float>) async throws in
                await sink.send(0.25)
                try await Task.sleep(for: .seconds(1.0))
                await sink.send(0.5)
                try await Task.sleep(for: .seconds(1.0))
                return [.text("test")]
            })),
            .init(title: "Fail", icon: .remove, provider: .init(isPhotoLibraryAutosaveEnabled: false,
                                                                fetchHandler: { (sink: AsyncPipe<Float>) async throws in
                await sink.send(0.25)
                try await Task.sleep(for: .seconds(1.0))
                await sink.send(0.5)
                try await Task.sleep(for: .seconds(1.0))
                await sink.send(0.75)
                try await Task.sleep(for: .seconds(1.0))
                throw NSError(domain: "hello, I'm an error", code: 0)
            }))
        ]

        let state = ShareState(colorScheme: .init(),
                               destinations: destinations,
                               contentFetchConfiguration: .variants(variants))
        state.feedbackConfiguration.shouldResetRequestOnAppUpdate = true
        state.feedbackConfiguration.handler = { _, _ in
            try? await Task.sleep(for: .seconds(1.0))
        }
        state.contentFetchHandlersOverrides = [
            .init(destination: WhatsAppShareDestination(), handler: { (content: [ShareContent]) in
                return [
                    .text("https://cdn.klingai.com/bs2/upload-kling-api/0218355724/image2video/CmJbG2fK_3wAAAAAABtpPw-0_raw_video_2.mp4")
                ]
            })
        ]
        coordinator.start(with: state)
    }
}

// MARK: - MediaPickerCoordinatorOutput

extension MainViewController: MediaPickerCoordinatorOutput {
    func mediaPickerCoordinatorDidSelect(_ coordinator: MediaPickerCoordinator, items: [MediaFetchService.Item]) {
        print(items)

        coordinator.show(image: nil, title: "hello", subtitle: "world") {
            coordinator.dismiss()
        }
    }
    
    func mediaPickerCoordinatorDidCancel(_ coordinator: MediaPickerCoordinator) {
        coordinator.dismiss()
    }
}
