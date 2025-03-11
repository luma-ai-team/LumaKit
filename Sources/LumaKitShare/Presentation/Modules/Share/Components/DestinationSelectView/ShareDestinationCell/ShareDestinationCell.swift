//
//  ShareDestinationCell.swift
//  LumaKit
//
//  Created by Anton K on 04.03.2025.
//

import UIKit
import LumaKit

final class ShareDestinationCell: UICollectionViewCell, CollectionViewCell {
    typealias ViewModel = ShareDestinationCellModel

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!

    static func size(with viewModel: ShareDestinationCellModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize {
        return .init(width: 60.0, height: 74.0)
    }

    static func register(in collectionView: UICollectionView, withIdentifier identifier: String) {
        collectionView.register(.init(nibName: "ShareDestinationCell", bundle: .module),
                                forCellWithReuseIdentifier: identifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.applyCornerRadius(value: 12.0)
    }

    func update(with viewModel: ShareDestinationCellModel, attributes: CollectionViewItemAttributes) {
        imageView.tintColor = viewModel.colorScheme.foreground.primary
        imageView.backgroundColor = viewModel.colorScheme.genericAction.inactive
        titleLabel.textColor = viewModel.colorScheme.foreground.primary

        imageView.image = viewModel.destination.icon
        titleLabel.text = viewModel.destination.title
    }
}
