//
//  Copyright © 2025 Luma AI. All rights reserved.
//

import UIKit

extension CollectionViewManager: WaterfallCollectionViewLayoutDelegate {
    public func collectionView(_ collectionView: UICollectionView,
                               layout: WaterfallCollectionViewLayout,
                               aspectRatioForItemAt indexPath: IndexPath) -> CGFloat {
        return self.collectionView(collectionView, layout: layout, sizeForItemAt: indexPath).aspect
    }

    public func collectionView(_ collectionView: UICollectionView, 
                               layout: WaterfallCollectionViewLayout,
                               heightForHeaderInSection section: Int) -> CGFloat {
        return self.collectionView(collectionView, layout: layout, referenceSizeForHeaderInSection: section).height
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout: WaterfallCollectionViewLayout,
                               heightForFooterInSection section: Int) -> CGFloat {
        return self.collectionView(collectionView, layout: layout, referenceSizeForFooterInSection: section).height
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout: WaterfallCollectionViewLayout,
                               insetForSection section: Int) -> UIEdgeInsets {
        return self.collectionView(collectionView, layout: layout, insetForSectionAt: section)
    }
}
