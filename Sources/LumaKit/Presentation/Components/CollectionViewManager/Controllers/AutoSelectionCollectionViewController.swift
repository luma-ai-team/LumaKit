//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class AutoSelectionCollectionViewController: CollectionViewController {
    public let scrollSelectCollectionViewLayout: ScrollSelectCollectionViewLayout = .init()

    public var cellSpacing: CGFloat = 10.0 {
        didSet {
            scrollSelectCollectionViewLayout.minimumLineSpacing = cellSpacing
            scrollSelectCollectionViewLayout.minimumInteritemSpacing = cellSpacing
        }
    }

    public init() {
        super.init(layout: scrollSelectCollectionViewLayout)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layout = scrollSelectCollectionViewLayout
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        scrollSelectCollectionViewLayout.scrollDirection = .horizontal
        manager.ignoresSelectionEventsDuringDragging = true
    }

    open override func viewDidLayoutSubviews() {
        if collectionView.indexPathsForSelectedItems?.isEmpty != false,
           let section = manager.sections.first(with: false, at: \.items.isEmpty),
           let item = section.items.first {
            manager.select(item)
        }

        super.viewDidLayoutSubviews()
    }
}
