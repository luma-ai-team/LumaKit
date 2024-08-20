//
//  HeaderView.swift
//  LumaKitExample
//
//  Created by Anton Kormakov on 20.08.2024.
//

import UIKit
import LumaKit

final class HeaderView: UICollectionReusableView, CollectionViewSupplementaryView {
    typealias ViewModel = String
    
    @IBOutlet weak var label: UILabel!
    
    static func register(in collectionView: UICollectionView, withIdentifier identifier: String, kind: String) {
        collectionView.register(.init(nibName: "HeaderView", bundle: nil),
                                forSupplementaryViewOfKind: kind,
                                withReuseIdentifier: identifier)
    }

    static func size(with viewModel: String, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize {
        return Self.systemLayoutSize(for: viewModel, fitting: size, usingNib: true)
    }
    
    func update(with viewModel: String, attributes: CollectionViewItemAttributes) {
        label.text = viewModel
    }
}
