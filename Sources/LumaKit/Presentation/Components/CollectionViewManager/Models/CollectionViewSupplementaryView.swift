//
//  CollectionViewHeader.swift
//
//
//  Created by Anton Kormakov on 20.08.2024.
//

import UIKit

public protocol CollectionViewSupplementaryView: UICollectionReusableView {
    associatedtype ViewModel: Equatable

    @MainActor
    static func register(in collectionView: UICollectionView, withIdentifier identifier: String, kind: String)

    @MainActor
    static func size(with viewModel: ViewModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize

    @MainActor
    func update(with viewModel: ViewModel, attributes: CollectionViewItemAttributes)
}

extension CollectionViewSupplementaryView {
    @MainActor
    public static func register(in collectionView: UICollectionView, withIdentifier identifier: String, kind: String) {
        collectionView.register(Self.self,
                                forSupplementaryViewOfKind: kind,
                                withReuseIdentifier: identifier)
    }

    @MainActor
    public static func systemLayoutSize(for viewModel: ViewModel, fitting size: CGSize, usingNib: Bool) -> CGSize {
        let cell: Self = usingNib ? Self.fromNib() : Self()
        cell.update(with: viewModel, attributes: .init())
        cell.layout()
        return cell.systemLayoutSizeFitting(size)
    }
}
