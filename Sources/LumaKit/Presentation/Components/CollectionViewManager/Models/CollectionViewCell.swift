//
//  Copyright © 2023 Draftz. All rights reserved.
//

import UIKit

public protocol CollectionViewCell: UICollectionViewCell {
    associatedtype ViewModel: Equatable

    @MainActor
    static func register(in collectionView: UICollectionView, withIdentifier identifier: String)

    @MainActor
    static func size(with viewModel: ViewModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize

    @MainActor
    func update(with viewModel: ViewModel, attributes: CollectionViewItemAttributes)
}

extension CollectionViewCell {
    @MainActor
    public static func register(in collectionView: UICollectionView, withIdentifier identifier: String) {
        collectionView.register(Self.self, forCellWithReuseIdentifier: identifier)
    }

    @MainActor
    public static func systemLayoutSize(for viewModel: ViewModel, fitting size: CGSize, usingNib: Bool) -> CGSize {
        let cell: Self = usingNib ? Self.fromNib() : Self()
        cell.update(with: viewModel, attributes: .init())
        cell.layout()
        return cell.systemLayoutSizeFitting(size)
    }
}
