//
//  ViewController.swift
//  PurchaseKitExample
//
//  Created by Anton Kormakov on 18.10.2023.
//

import UIKit
import LumaKit
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
        let view = UIView()
        view.backgroundColor = .red
        view.heightAnchor.constraint(equalToConstant: 120.0).isActive = true

        let coordinator = MediaPickerCoordinator(rootViewController: self, colorScheme: .init())
        //coordinator.sourcePickerBottomView = view
        coordinator.sources = [.camera]
        coordinator.selectionStyle = .ordered(4)
        coordinator.output = self
        coordinator.start()
    }

    @IBAction func playerExampleButtonPressed(_ sender: Any) {
        let controller = PlayersExampleViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

// MARK: - MediaPickerCoordinatorOutput

extension MainViewController: MediaPickerCoordinatorOutput {
    func mediaPickerCoordinatorDidSelect(_ coordinator: MediaPickerCoordinator, items: [MediaFetchService.Item]) {
        print(items)
        coordinator.dismiss()
    }
    
    func mediaPickerCoordinatorDidCancel(_ coordinator: MediaPickerCoordinator) {
        coordinator.dismiss()
    }
}
