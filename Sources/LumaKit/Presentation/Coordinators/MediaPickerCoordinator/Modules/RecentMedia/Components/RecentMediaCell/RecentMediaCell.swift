//
//  RecentMediaCell.swift
//  LumaKit
//
//  Created by Anton K on 15.04.2026.
//

import UIKit

final class RecentMediaCell: UICollectionViewCell, CollectionViewCell {
    typealias ViewModel = RecentMediaCellModel

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shimmerView: ShimmerView!
    @IBOutlet weak var videoOverlayView: GradientView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var selectionView: UIView!
    @IBOutlet weak var shadeView: UIView!
    @IBOutlet weak var markerView: UIView!

    var isSelectable: Bool = true
    override var isSelected: Bool {
        didSet {
            guard isSelectable else {
                return
            }

            selectionView.isHidden = isSelected == false
        }
    }

    static func register(in collectionView: UICollectionView, withIdentifier identifier: String) {
        collectionView.register(.init(nibName: "RecentMediaCell", bundle: .module),
                                forCellWithReuseIdentifier: identifier)
    }

    static func size(with viewModel: RecentMediaCellModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize {
        let cellsPerRow = 4.0
        let padding = 8.0 * (cellsPerRow - 1.0)
        let inset = 16.0
        let width = (size.width - 2.0 * inset - padding) / cellsPerRow
        return .init(width: width, height: width)
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        durationLabel.font = .compatibleSystemFont(ofSize: 12.0, weight: .semibold, design: .rounded)

        selectionView.layer.borderWidth = 2.0
        markerView.layer.borderWidth = 1.0

        selectionView.applyCornerRadius(value: 13.0)
        applyCornerRadius(value: 13.0)
        clipsToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        markerView.applyMaximumCornerRadius()
    }

    func update(with viewModel: RecentMediaCellModel, attributes: CollectionViewItemAttributes) {
        backgroundColor = viewModel.colorScheme.background.primary
        isSelectable = viewModel.isSelectable
        imageView.image = viewModel.metadata?.thumbnail
        videoOverlayView.isHidden = viewModel.metadata?.duration == nil
        durationLabel.text = viewModel.metadata?.duration?.toShortTimecodeString()
        imageView.alpha = viewModel.isEnabled ? 1.0 : 0.4
        isUserInteractionEnabled = viewModel.isEnabled

        if viewModel.metadata?.thumbnail == nil {
            shimmerView.startAnimating()
        }
        else {
            shimmerView.stopAnimating()
        }

        videoOverlayView.gradient = .vertical(colors: [
            viewModel.colorScheme.background.primary.withAlphaComponent(0.0),
            viewModel.colorScheme.background.primary.withAlphaComponent(0.7)
        ])
        durationLabel.textColor = viewModel.colorScheme.foreground.primary
        selectionView.layer.borderColor = viewModel.colorScheme.foreground.primary.cgColor
        shadeView.backgroundColor = viewModel.colorScheme.background.primary.withAlphaComponent(0.6)
        markerView.backgroundColor = viewModel.colorScheme.foreground.primary
        markerView.layer.borderColor = viewModel.colorScheme.stroke.secondary.cgColor
        shimmerView.tintColor = viewModel.colorScheme.foreground.primary
    }
}
