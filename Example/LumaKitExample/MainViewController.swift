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
        ExampleCoordinator(rootViewController: self).start()
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
        coordinator.output = self
        coordinator.start()
    }
}

// MARK: - MediaPickerCoordinatorOutput

extension MainViewController: MediaPickerCoordinatorOutput {
    func mediaPickerCoordinatorDidSelect(_ coordinator: MediaPickerCoordinator, image: UIImage) {
        print(image)
        coordinator.dismiss()
    }
    
    func mediaPickerCoordinatorDidSelect(_ coordinator: MediaPickerCoordinator, asset: AVAsset) {
        print(asset)
        coordinator.dismiss()
    }
    
    func mediaPickerCoordinatorDidCancel(_ coordinator: MediaPickerCoordinator) {
        coordinator.dismiss()
    }
}
