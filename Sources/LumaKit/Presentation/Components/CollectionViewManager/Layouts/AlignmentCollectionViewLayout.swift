//
//  Copyright © 2023 Draftz. All rights reserved.
//

import UIKit

public final class AlignmentCollectionViewLayout: UICollectionViewFlowLayout {

    public enum Alignment {
        case leading
        case center
        case trailing
    }

    public var orthogonalAlignment: Alignment = .center

    public override init() {
        super.init()
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        minimumLineSpacing = .greatestFiniteMagnitude
        scrollDirection = .horizontal
    }

    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let attributeCollection = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        guard let collectionView = collectionView else {
            return attributeCollection
        }

        for attributes in attributeCollection {
            switch scrollDirection {
            case .horizontal:
                switch orthogonalAlignment {
                case .leading:
                    attributes.frame.origin.y = 0.0
                case .center:
                    attributes.frame.origin.y = 0.5 * (collectionView.bounds.height - attributes.frame.height)
                case .trailing:
                    attributes.frame.origin.y = collectionView.bounds.height - attributes.frame.height
                }
            case .vertical:
                switch orthogonalAlignment {
                case .leading:
                    attributes.frame.origin.x = 0.0
                case .center:
                    attributes.frame.origin.x = 0.5 * (collectionView.bounds.width - attributes.frame.width)
                case .trailing:
                    attributes.frame.origin.x = collectionView.bounds.width - attributes.frame.width
                }
            @unknown default:
                break
            }
        }

        return attributeCollection
    }
}
