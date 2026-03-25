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
    @IBOutlet weak var materialBorderView: MaterialBorderView!
    @IBOutlet weak var titleLabel: UILabel!

    static func size(with viewModel: ShareDestinationCellModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize {
        return .init(width: 75.0, height: 60.0)
    }

    static func register(in collectionView: UICollectionView, withIdentifier identifier: String) {
        collectionView.register(.init(nibName: "ShareDestinationCell", bundle: .module),
                                forCellWithReuseIdentifier: identifier)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyCornerRadius(value: 12.0)
        materialBorderView.applyCornerRadius(value: 12.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if materialBorderView.materialStyle.isSystem {
            sendSubviewToBack(materialBorderView)
        }
        else {
            bringSubviewToFront(materialBorderView)
        }
    }

    func update(with viewModel: ShareDestinationCellModel, attributes: CollectionViewItemAttributes) {
        backgroundColor = viewModel.colorScheme.genericAction.active

        imageView.tintColor = viewModel.colorScheme.foreground.primary
        titleLabel.textColor = viewModel.colorScheme.foreground.primary

        imageView.image = viewModel.destination.icon
        titleLabel.text = viewModel.destination.title

        materialBorderView.materialStyle = viewModel.materialStyle
    }
}
