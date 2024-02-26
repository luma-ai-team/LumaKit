//
//  ViewController.swift
//  PurchaseKitExample
//
//  Created by Anton Kormakov on 18.10.2023.
//

import UIKit
import LumaKit

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
}
