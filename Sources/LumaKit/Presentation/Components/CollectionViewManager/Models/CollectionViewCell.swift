//
//  Copyright © 2023 Draftz. All rights reserved.
//

import UIKit

public protocol CollectionViewCell: UICollectionViewCell {
    associatedtype ViewModel: Equatable

    static func register(in collectionView: UICollectionView, withIdentifier identifier: String)
    static func size(with viewModel: ViewModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize

    func update(with viewModel: ViewModel, attributes: CollectionViewCellAttributes)
}

extension CollectionViewCell {
    public static func register(in collectionView: UICollectionView, withIdentifier identifier: String) {
        collectionView.register(Self.self, forCellWithReuseIdentifier: identifier)
    }

    public static func systemLayoutSize(for viewModel: ViewModel, fitting size: CGSize, usingNib: Bool) -> CGSize {
        let cell: Self = usingNib ? Self.fromNib() : Self()
        cell.update(with: viewModel, attributes: .init())
        cell.layout()
        return cell.systemLayoutSizeFitting(size)
    }
}
