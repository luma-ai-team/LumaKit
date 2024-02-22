//
//  Copyright © 2023 Draftz. All rights reserved.
//

import UIKit

public class ScrollSelectCollectionViewLayout: UICollectionViewFlowLayout {
    public var defersSelectionEvents: Bool = false

    public override init() {
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        scrollDirection = .horizontal
    }

    public override func invalidateLayout() {
        super.invalidateLayout()

        if let indexPath = collectionView?.indexPathsForSelectedItems?.first {
            scroll(to: indexPath, animated: false)
        }
    }

    private func scroll(to indexPath: IndexPath, animated: Bool) {
        let position: UICollectionView.ScrollPosition = (scrollDirection == .horizontal) ?
            .centeredHorizontally :
            .centeredVertically
        collectionView?.scrollToItem(at: indexPath, at: position, animated: animated)
    }

    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint,
                                             withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView, 
              collectionView.isPagingEnabled == false else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }

        let targetRect = CGRect(origin: .zero, size: collectionView.contentSize)
        guard let layoutAttributes = layoutAttributesForElements(in: targetRect) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }

        switch scrollDirection {
        case .horizontal:
            let halfWidth = collectionView.bounds.size.width / 2.0
            let proposedContentCenter = proposedContentOffset.x + halfWidth

            let attributes = layoutAttributes.sorted { (lhs: UICollectionViewLayoutAttributes,
                                                        rhs: UICollectionViewLayoutAttributes) in
                let lDistance = lhs.center.x - proposedContentCenter
                let rDistance = rhs.center.x - proposedContentCenter
                return abs(lDistance) < abs(rDistance)
            }

            let closest = attributes.first ?? .init()
            return CGPoint(x: floor(closest.center.x - halfWidth), y: proposedContentOffset.y)
        case .vertical:
            let halfHeight = collectionView.bounds.size.height / 2.0
            let proposedContentCenter = proposedContentOffset.y + halfHeight

            let attributes = layoutAttributes.sorted { (lhs: UICollectionViewLayoutAttributes,
                                                        rhs: UICollectionViewLayoutAttributes) in
                let lDistance = lhs.center.y - proposedContentCenter
                let rDistance = rhs.center.y - proposedContentCenter
                return abs(lDistance) < abs(rDistance)
            }

            let closest = attributes.first ?? .init()
            return CGPoint(x: proposedContentOffset.x, y: floor(closest.center.y - halfHeight))
        @unknown default:
            return proposedContentOffset
        }
    }
}

// MARK: - InsetAwareCollectionViewFlowLayout

extension ScrollSelectCollectionViewLayout: InsetAwareCollectionViewFlowLayout {

    public func insets(for section: CollectionViewSection,
                       atIndex index: Int,
                       in collectionView: UICollectionView) -> UIEdgeInsets {
        guard section.items.isEmpty == false else {
            return .zero
        }

        let collectionSize = collectionView.bounds.size
        let numberOfSections = collectionView.numberOfSections
        let firstItemSize = section.items.first?.size(in: collectionView,
                                                      at: .init(row: 0, section: index)) ?? .zero
        let lastItemSize = section.items.last?.size(in: collectionView,
                                                    at: .init(row: section.items.count - 1, section: index)) ?? .zero

        var insets: UIEdgeInsets = section.insets
        switch scrollDirection {
        case .horizontal:
            insets.top = 0.5 * (collectionSize.height - firstItemSize.height)
            insets.bottom = insets.top
            
            if index == 0 {
                insets.left = 0.5 * (collectionSize.width - firstItemSize.width)
            }

            if index == (numberOfSections - 1) {
                insets.right = 0.5 * (collectionSize.width - lastItemSize.width)
            }
        case .vertical:
            insets.left = 0.5 * (collectionSize.width - firstItemSize.width)
            insets.right = insets.left

            if index == 0 {
                insets.top = 0.5 * (collectionSize.height - firstItemSize.height)
            }

            if index == (numberOfSections - 1) {
                insets.bottom = 0.5 * (collectionSize.height - lastItemSize.height)
            }
        @unknown default:
            break
        }

        return insets
    }
}


// MARK: - ScrollAwareCollectionViewFlowLayout

extension ScrollSelectCollectionViewLayout: ScrollAwareCollectionViewFlowLayout {
    public func collectionViewDidScroll(_ collectionView: UICollectionView) {
        guard collectionView.isDragging ||
              collectionView.isDecelerating else {
            return
        }

        selectCurrentItem(collectionView, shouldSendSelectionEvent: defersSelectionEvents == false)
    }

    public func collectionViewDidStopScrolling(_ collectionView: UICollectionView) {
        guard defersSelectionEvents else {
            return
        }

        selectCurrentItem(collectionView, shouldSendSelectionEvent: true)
    }

    private func selectCurrentItem(_ collectionView: UICollectionView, shouldSendSelectionEvent: Bool) {
        let position = collectionView.contentOffset.x + collectionView.bounds.width / 2.0
        for indexPath in collectionView.indexPathsForVisibleItems {
            guard let cellFrame = layoutAttributesForItem(at: indexPath)?.frame else {
                continue
            }

            guard cellFrame.contains(CGPoint(x: position, y: cellFrame.midY)) else {
                continue
            }

            guard collectionView.indexPathsForSelectedItems?.first != indexPath else {
                continue
            }

            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            if shouldSendSelectionEvent {
                collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
            }
            return
        }
    }
}

extension ScrollSelectCollectionViewLayout: SelectionAwareCollectionViewFlowLayout {
    public func collectionViewDidSelect(_ collectionView: UICollectionView, indexPath: IndexPath) {
        guard collectionView.isDragging == false else {
            return
        }
        
        scroll(to: indexPath, animated: true)
    }
}
