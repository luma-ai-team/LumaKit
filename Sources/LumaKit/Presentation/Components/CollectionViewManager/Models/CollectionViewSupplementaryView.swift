//
//  CollectionViewHeader.swift
//
//
//  Created by Anton Kormakov on 20.08.2024.
//

import UIKit

public protocol CollectionViewSupplementaryView: UICollectionReusableView {
    associatedtype ViewModel: Equatable

    static func register(in collectionView: UICollectionView, withIdentifier identifier: String, kind: String)
    static func size(with viewModel: ViewModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize

    func update(with viewModel: ViewModel, attributes: CollectionViewItemAttributes)
}

extension CollectionViewSupplementaryView {
    public static func register(in collectionView: UICollectionView, withIdentifier identifier: String, kind: String) {
        collectionView.register(Self.self,
                                forSupplementaryViewOfKind: kind,
                                withReuseIdentifier: identifier)
    }

    public static func systemLayoutSize(for viewModel: ViewModel, fitting size: CGSize, usingNib: Bool) -> CGSize {
        let cell: Self = usingNib ? Self.fromNib() : Self()
        cell.update(with: viewModel, attributes: .init())
        cell.layout()
        return cell.systemLayoutSizeFitting(size)
    }
}
