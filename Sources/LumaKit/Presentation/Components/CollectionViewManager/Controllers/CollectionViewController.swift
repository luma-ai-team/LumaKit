//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class CollectionViewController: UIViewController {

    public var sections: [any CollectionViewSection] {
        get {
            return manager.sections
        }
        set {
            manager.sections = newValue
        }
    }

    public private(set) lazy var manager: CollectionViewManager = {
        let manager = CollectionViewManager(collectionView: collectionView)
        manager.ignoresSelectionEventsDuringDragging = true
        return manager
    }()

    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    public internal(set) var layout: UICollectionViewLayout {
        didSet {
            collectionView.collectionViewLayout = layout
        }
    }

    public init(layout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        self.layout = layout
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        layout = UICollectionViewFlowLayout()
        super.init(coder: coder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView.frame = view.bounds
        layout.invalidateLayout()
    }
}
