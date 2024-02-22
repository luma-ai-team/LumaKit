//
//  LayoutCell.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 22.02.2024.
//

import UIKit
import LumaKit

final class LayoutCell: UICollectionViewCell, CollectionViewCell {
    typealias ViewModel = TestViewModel

    @IBOutlet weak var valueLabel: UILabel!

    override var isSelected: Bool {
        didSet {
            valueLabel.textColor = isSelected ? .red : .black
        }
    }

    static func size(with viewModel: TestViewModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize {
        return Self.systemLayoutSize(for: viewModel, fitting: size, usingNib: true)
    }

    static func register(in collectionView: UICollectionView, withIdentifier identifier: String) {
        collectionView.register(UINib(nibName: "LayoutCell", bundle: nil),
                                forCellWithReuseIdentifier: identifier)
    }

    func update(with viewModel: TestViewModel, attributes: LumaKit.CollectionViewCellAttributes) {
        valueLabel.text = "\(viewModel.color)"
    }
}
