//
//  Copyright © 2023 Draftz. All rights reserved.
//

import UIKit

public final class CollectionViewManager: NSObject {

    public var sections: [CollectionViewSection] = [] {
        didSet {
            registerCellsIfNeeded()
            collectionView.reloadData()
        }
    }

    unowned var collectionView: UICollectionView

    public var ignoresSelectionEventsDuringDragging: Bool = false
    public var selectionHandler: ((any CollectionViewItem) -> Void)?
    public var deselectionHandler: ((any CollectionViewItem) -> Void)?

    public init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        super.init()
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func registerCellsIfNeeded() {
        for section in sections {
            for item in section.items {
                type(of: item).registerCell(in: collectionView)
            }
        }
    }

    public func select(_ indexPath: IndexPath, scrollPosition: UICollectionView.ScrollPosition = [], animated: Bool = true) {
        guard ignoresSelectionEventsDuringDragging == false ||
              collectionView.isDragging == false else {
            return
        }

        collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
    }

    public func select(_ target: any CollectionViewItem,
                       scrollPosition: UICollectionView.ScrollPosition = [],
                       animated: Bool = true) {
        for (sectionIndex, section) in sections.enumerated() {
            for (itemIndex, item) in section.items.enumerated() where item.matches(target) {
                select(.init(row: itemIndex, section: sectionIndex), scrollPosition: scrollPosition, animated: animated)
                return
            }
        }
    }

    public func updateSelectedItemOffset(scrollPosition: UICollectionView.ScrollPosition) {
        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else {
            return
        }

        collectionView.scrollToItem(at: selectedIndexPath, at: scrollPosition, animated: false)
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionViewManager: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        guard let cell = item.dequeueCell(in: collectionView, indexPath: indexPath) else {
            return .init()
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionViewManager: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        item.handleCellSelection()
        selectionHandler?(item)

        if let layout = collectionView.collectionViewLayout as? SelectionAwareCollectionViewFlowLayout {
            layout.collectionViewDidSelect(collectionView, indexPath: indexPath)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let item = sections[indexPath.section].items[indexPath.row]
        item.handleCellDeselection()
        deselectionHandler?(item)

        if let layout = collectionView.collectionViewLayout as? SelectionAwareCollectionViewFlowLayout {
            layout.collectionViewDidDeselect(collectionView, indexPath: indexPath)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, 
                               contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                               point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else {
            return nil
        }

        let item = sections[indexPath.section].items[indexPath.row]
        guard item.contextActions.isEmpty == false else {
            return nil
        }

        return UIContextMenuConfiguration(actionProvider: { _ in
            return UIMenu(children: item.contextActions)
        })
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CollectionViewManager: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = sections[indexPath.section].items[indexPath.row]
        return item.size(in: collectionView, at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        if let layout = collectionViewLayout as? InsetAwareCollectionViewFlowLayout {
            return layout.insets(for: sections[section], atIndex: section, in: collectionView)
        }

        return sections[section].insets
    }
}

// MARK: - UIScrollViewDelegate

extension CollectionViewManager: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let layout = collectionView.collectionViewLayout as? ScrollAwareCollectionViewFlowLayout {
            layout.collectionViewDidScroll(collectionView)
        }
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate == false else {
            return
        }

        if let layout = collectionView.collectionViewLayout as? ScrollAwareCollectionViewFlowLayout {
            layout.collectionViewDidStopScrolling(collectionView)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let layout = collectionView.collectionViewLayout as? ScrollAwareCollectionViewFlowLayout {
            layout.collectionViewDidStopScrolling(collectionView)
        }
    }
}
