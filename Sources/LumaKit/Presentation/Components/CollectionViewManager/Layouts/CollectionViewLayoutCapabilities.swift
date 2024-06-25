//
//  Copyright © 2023 Draftz. All rights reserved.
//

import UIKit

public protocol InsetAwareCollectionViewFlowLayout {
    func insets(for section: CollectionViewSection,
                atIndex index: Int,
                in collectionView: UICollectionView) -> UIEdgeInsets
}

public protocol ScrollAwareCollectionViewFlowLayout {
    func collectionViewDidScroll(_ collectionView: UICollectionView)
    func collectionViewDidStopScrolling(_ collectionView: UICollectionView)
}

public protocol SelectionAwareCollectionViewFlowLayout {
    func collectionViewDidSelect(_ collectionView: UICollectionView, indexPath: IndexPath)
    func collectionViewDidDeselect(_ collectionView: UICollectionView, indexPath: IndexPath)
}
