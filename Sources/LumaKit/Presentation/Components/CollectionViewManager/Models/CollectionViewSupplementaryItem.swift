//
//  CollectionViewHeader.swift
//
//
//  Created by Anton Kormakov on 20.08.2024.
//

import UIKit

public protocol CollectionViewSupplementaryItem: AnyObject {
    associatedtype View: CollectionViewSupplementaryView

    var viewModel: View.ViewModel { get }
    var attributes: CollectionViewItemAttributes { get set }

    @MainActor
    func configure(_ view: View, in collectionView: UICollectionView, indexPath: IndexPath)
}

extension CollectionViewSupplementaryItem {
    public func matches(_ rhs: (any CollectionViewSupplementaryItem)?) -> Bool {
        return viewModel == (rhs?.viewModel as? View.ViewModel)
    }

    @MainActor
    static func registerView(in collectionView: UICollectionView, kind: String) {
        View.register(in: collectionView, withIdentifier: "\(View.self)", kind: kind)
    }

    @MainActor
    public func size(in collectionView: UICollectionView) -> CGSize {
        return View.size(with: viewModel, fitting: collectionView.bounds.size, insets: collectionView.contentInset)
    }

    @MainActor
    public func dequeueView(in collectionView: UICollectionView, indexPath: IndexPath, kind: String) -> View? {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: "\(View.self)",
                                                                         for: indexPath) as? View else {
            return nil
        }

        attributes.indexPath = indexPath
        configure(view, in: collectionView, indexPath: indexPath)
        return view
    }

    @MainActor
    public func configure(in collectionView: UICollectionView, indexPath: IndexPath, kind: String) {
        guard let view = collectionView.supplementaryView(forElementKind: kind, at: indexPath) as? View else {
            return
        }

        configure(view, in: collectionView, indexPath: indexPath)
    }
}


// MARK: - BasicCollectionViewSupplementaryItem

open class BasicCollectionViewSupplementaryItem<View: CollectionViewSupplementaryView>: CollectionViewSupplementaryItem {
    public let viewModel: View.ViewModel
    public var attributes: CollectionViewItemAttributes = .init()

    public init(viewModel: View.ViewModel) {
        self.viewModel = viewModel
    }

    open func configure(_ view: View, in collectionView: UICollectionView, indexPath: IndexPath) {
        view.update(with: viewModel, attributes: attributes)
    }
}
