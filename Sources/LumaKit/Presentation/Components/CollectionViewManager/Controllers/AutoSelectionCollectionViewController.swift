//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class AutoSelectionCollectionViewController: CollectionViewController {
    public let scrollSelectCollectionViewLayout: ScrollSelectCollectionViewLayout = .init()

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
}
