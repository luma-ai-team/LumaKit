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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Actions

    @IBAction func moduleExampleButtonPressed(_ sender: UIButton) {
        ExampleCoordinator(rootViewController: self).start()
    }
    
    @IBAction func elementExampleButtonPressed(_ sender: UIButton) {
        let controller = UIElementsViewController()
        present(controller, animated: true)
    }
    
    @IBAction func collectionViewExampleButtonPressed(_ sender: Any) {
        let controller = CollectionViewManagerExampleViewController()
        present(controller, animated: true)
    }
}
