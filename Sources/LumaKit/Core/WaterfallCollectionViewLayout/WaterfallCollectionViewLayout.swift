//
//  Copyright © 2025 Luma AI. All rights reserved.
//

import UIKit

@MainActor
@objc public protocol WaterfallCollectionViewLayoutDelegate: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout: WaterfallCollectionViewLayout,
                        aspectRatioForItemAt indexPath: IndexPath) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView, 
                                       layout: WaterfallCollectionViewLayout,
                                       heightForHeaderInSection section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView, 
                                       layout: WaterfallCollectionViewLayout,
                                       heightForFooterInSection section: Int) -> CGFloat

    @objc optional func collectionView(_ collectionView: UICollectionView, 
                                       layout: WaterfallCollectionViewLayout,
                                       insetForSection section: Int) -> UIEdgeInsets

    @objc optional func collectionView(_ collectionView: UICollectionView, 
                                       layout: WaterfallCollectionViewLayout,
                                       insetForHeaderInSection section: Int) -> UIEdgeInsets

    @objc optional func collectionView(_ collectionView: UICollectionView, 
                                       layout: WaterfallCollectionViewLayout,
                                       insetForFooterInSection section: Int) -> UIEdgeInsets

    @objc optional func collectionView(_ collectionView: UICollectionView, 
                                       layout: WaterfallCollectionViewLayout,
                                       minimumInteritemSpacingForSection section: Int) -> CGFloat
}

public class WaterfallCollectionViewLayout: UICollectionViewLayout {
    private let unionSize = 20

    @IBInspectable
    public var columnCount: Int = 2 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: columnCount)
        }
    }

    @IBInspectable
    public var minimumColumnSpacing: CGFloat = 10.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: minimumColumnSpacing)
        }
    }

    @IBInspectable
    public var minimumInteritemSpacing: CGFloat = 10.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: minimumInteritemSpacing)
        }
    }

    @IBInspectable
    public var headerHeight: CGFloat = 0.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: headerHeight)
        }
    }

    @IBInspectable
    public var footerHeight: CGFloat = 0.0 {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: footerHeight)
        }
    }

    @IBInspectable
    public var headerInset: UIEdgeInsets = .zero {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: headerInset)
        }
    }

    @IBInspectable
    public var footerInset: UIEdgeInsets = .zero {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: footerInset)
        }
    }

    @IBInspectable
    public var sectionInset: UIEdgeInsets = .zero {
        didSet {
            invalidateIfNotEqual(oldValue, newValue: sectionInset)
        }
    }

    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }

        let numberOfSections = collectionView.numberOfSections
        if numberOfSections == 0 {
            return .zero
        }

        var contentSize = collectionView.bounds.size
        contentSize.height = CGFloat(columnHeights[safe: 0] ?? 0.0)

        return contentSize
    }

    private weak var delegate: WaterfallCollectionViewLayoutDelegate? {
        return collectionView?.delegate as? WaterfallCollectionViewLayoutDelegate
    }

    private var columnHeights: [CGFloat] = []
    private var sectionItemAttributes: [[UICollectionViewLayoutAttributes]] = []
    private var allItemAttributes: [UICollectionViewLayoutAttributes] = []
    private var headersAttribute: [Int: UICollectionViewLayoutAttributes] = [:]
    private var footersAttribute: [Int: UICollectionViewLayoutAttributes] = [:]
    private var unionRects: [CGRect] = []

    public override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else {
            return
        }

        guard let delegate = delegate else {
            assertionFailure("UICollectionView's delegate should conform to WaterfallLayoutDelegate protocol")
            return
        }

        let numberOfSections = collectionView.numberOfSections
        assert(columnCount > 0, "WaterfallFlowLayout's columnCount should be greater than 0")

        headersAttribute.removeAll(keepingCapacity: false)
        footersAttribute.removeAll(keepingCapacity: false)
        unionRects.removeAll(keepingCapacity: false)
        allItemAttributes.removeAll(keepingCapacity: false)
        sectionItemAttributes.removeAll(keepingCapacity: false)

        columnHeights = .init(repeating: 0, count: columnCount)

        var top: CGFloat = 0
        var attributes: UICollectionViewLayoutAttributes

        for section in stride(from: 0, to: numberOfSections, by: 1) {
            let minimumInteritemSpacing = delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSection: section) ?? self.minimumInteritemSpacing
            let sectionInset = delegate.collectionView?(collectionView, layout: self, insetForSection: section) ?? self.sectionInset

            let width = CGFloat(collectionView.frame.size.width - sectionInset.horizontalSum)
            let itemWidth = floor((width - CGFloat(columnCount - 1) * minimumColumnSpacing) / CGFloat(columnCount))

            let headerHeight = delegate.collectionView?(collectionView, layout: self, heightForHeaderInSection: section) ?? self.headerHeight
            let headerInset = delegate.collectionView?(collectionView, layout: self, insetForHeaderInSection: section) ?? self.headerInset
            top += headerInset.top

            if headerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                              with: .init(item: 0, section: section))
                attributes.frame = CGRect(x: headerInset.left,
                                          y: top,
                                          width: collectionView.frame.size.width - headerInset.horizontalSum,
                                          height: CGFloat(headerHeight))
                headersAttribute[section] = attributes
                allItemAttributes.append(attributes)

                top = attributes.frame.maxY + headerInset.bottom
            }

            top += sectionInset.top
            for index in stride(from: 0, to: columnCount, by: 1) {
                columnHeights[index] = top
            }

            let itemCount = collectionView.numberOfItems(inSection: section)
            var itemAttributes = [UICollectionViewLayoutAttributes]()

            // Item will be put into shortest column.
            for index in stride(from: 0, to: itemCount, by: 1) {
                let indexPath = IndexPath(item: index, section: section)
                let columnIndex = shortestColumnIndex()

                let xOffset = sectionInset.left + (itemWidth + minimumColumnSpacing) * CGFloat(columnIndex)
                let yOffset = columnHeights[columnIndex]
                let aspectRatio = delegate.collectionView(collectionView, layout: self, aspectRatioForItemAt: indexPath)

                var itemHeight: CGFloat = 0.0
                if aspectRatio.isFinite,
                   aspectRatio.isNaN == false {
                    itemHeight = itemWidth / aspectRatio
                }

                attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = .init(x: xOffset, y: yOffset, width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                allItemAttributes.append(attributes)
                columnHeights[columnIndex] = attributes.frame.maxY + minimumInteritemSpacing
            }

            sectionItemAttributes.append(itemAttributes)

            let columnIndex = longestColumnIndex()
            top = columnHeights[columnIndex] - minimumInteritemSpacing + sectionInset.bottom

            let footerHeight = delegate.collectionView?(collectionView, layout: self, heightForFooterInSection: section) ?? self.footerHeight

            let footerInset = delegate.collectionView?(collectionView, layout: self, insetForFooterInSection: section) ?? self.footerInset
            top += footerInset.top

            if footerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                                              with: .init(item: 0, section: section))
                attributes.frame = CGRect(x: footerInset.left,
                                          y: top,
                                          width: collectionView.frame.size.width - footerInset.horizontalSum,
                                          height: footerHeight)

                footersAttribute[section] = attributes
                allItemAttributes.append(attributes)

                top = attributes.frame.maxY + footerInset.bottom
            }

            for index in stride(from: 0, to: columnCount, by: 1) {
                columnHeights[index] = top
            }
        }

        var index = 0
        let itemCounts = allItemAttributes.count

        while index < itemCounts {
            let rect1 = allItemAttributes[index].frame
            index = min(index + unionSize, itemCounts) - 1

            let rect2 = allItemAttributes[index].frame
            unionRects.append(rect1.union(rect2))

            index += 1
        }
    }

    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= sectionItemAttributes.count {
            return nil
        }

        if indexPath.item >= sectionItemAttributes[indexPath.section].count {
            return nil
        }

        return sectionItemAttributes[indexPath.section][indexPath.item]
    }

    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attribute: UICollectionViewLayoutAttributes?

        if elementKind == UICollectionView.elementKindSectionHeader {
            attribute = headersAttribute[indexPath.section]
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            attribute = footersAttribute[indexPath.section]
        }

        return attribute
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var begin: Int = 0
        var end: Int = unionRects.count
        var attributes = [UICollectionViewLayoutAttributes]()

        for index in stride(from: 0, to: unionRects.count, by: 1) {
            guard rect.intersects(unionRects[index]) else {
                continue
            }

            begin = index * unionSize
            break
        }

        for index in stride(from: unionRects.count - 1, through: 0, by: -1) {
            guard rect.intersects(unionRects[index]) else {
                continue
            }

            end = min((index + 1) * unionSize, allItemAttributes.count)
            break
        }

        for index in stride(from: begin, to: end, by: 1) {
            let attribute = allItemAttributes[index]
            if rect.intersects(attribute.frame) {
                attributes.append(attribute)
            }
        }

        return attributes
    }

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let oldBounds = collectionView?.bounds
        if newBounds.width != oldBounds?.width {
            return true
        }

        return false
    }
}

// MARK: - Helpers

private extension WaterfallCollectionViewLayout {
    func shortestColumnIndex() -> Int {
        var result: Int = 0
        var shortestHeight: CGFloat = .greatestFiniteMagnitude

        for (index, height) in columnHeights.enumerated() where height < shortestHeight {
            shortestHeight = height
            result = index
        }

        return result
    }

    func longestColumnIndex() -> Int {
        var result: Int = 0
        var longestHeight: CGFloat = 0.0

        for (index, height) in columnHeights.enumerated() where height > longestHeight {
            longestHeight = height
            result = index
        }

        return result
    }

    func invalidateIfNotEqual<T: Equatable>(_ oldValue: T, newValue: T) {
        guard oldValue != newValue else {
            return
        }

        invalidateLayout()
    }
}
