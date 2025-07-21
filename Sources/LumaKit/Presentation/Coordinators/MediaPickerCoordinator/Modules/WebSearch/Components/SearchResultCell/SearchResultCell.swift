//
//  SearchResultCell.swift
//  LumaKit
//
//  Created by Anton K on 27.06.2025.
//

import UIKit

final class SearchResultCell: UICollectionViewCell, CollectionViewCell {
    typealias ViewModel = SearchResultCellModel

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var materialBorderView: MaterialBorderView!

    static func register(in collectionView: UICollectionView, withIdentifier identifier: String) {
        collectionView.register(.init(nibName: "SearchResultCell", bundle: .module),
                                forCellWithReuseIdentifier: identifier)
    }

    static func size(with viewModel: SearchResultCellModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize {
        let aspect = viewModel.result.size.aspect
        return .init(width: size.width, height: size.width / aspect)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyCornerRadius(value: 12.0)
        materialBorderView.applyCornerRadius(value: 12.0)
    }

    func update(with viewModel: SearchResultCellModel, attributes: CollectionViewItemAttributes) {
        backgroundColor = viewModel.colorScheme.background.secondary
        materialBorderView.materialStyle = viewModel.materialStyle

        imageView.image = viewModel.image
        if imageView.image == nil {
            activityIndicatorView.startAnimating()
        }
        else {
            activityIndicatorView.stopAnimating()
        }
    }
}
