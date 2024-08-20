//
//  TestCell.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 14.02.2024.
//

import UIKit
import LumaKit

struct TestViewModel: Equatable {
    let color: UInt32
}

final class TestCell: UICollectionViewCell, CollectionViewCell {
    typealias ViewModel = TestViewModel

    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? 2.0 : 0.0
        }
    }

    static func register(in collectionView: UICollectionView, withIdentifier identifier: String) {
        collectionView.register(Self.self, forCellWithReuseIdentifier: identifier)
    }

    static func size(with viewModel: TestViewModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize {
        return .init(width: 80.0 + CGFloat(viewModel.color / 100000), height: 80.0)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        layer.borderColor = UIColor.black.cgColor
    }

    func update(with viewModel: TestViewModel, attributes: LumaKit.CollectionViewItemAttributes) {
        backgroundColor = .p3(rgb: viewModel.color)
    }
}
