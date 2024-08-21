//
//  CollectionViewManager+PartialUpdates.swift
//  
//
//  Created by Anton Kormakov on 21.08.2024.
//

import UIKit

// MARK: - Partial Updates

extension CollectionViewManager {
    public func insert(_ section: CollectionViewSection, atIndex index: Int) {
        shouldIgnoreReloadRequests = true
        sections.insert(section, at: index)

        collectionView.insertSections(.init(integer: index))
        shouldIgnoreReloadRequests = false
    }

    public func append(_ section: CollectionViewSection) {
        shouldIgnoreReloadRequests = true
        sections.append(section)

        collectionView.insertSections(.init(integer: sections.count - 1))
        shouldIgnoreReloadRequests = false
    }

    public func replace(_ section: CollectionViewSection, atIndex index: Int) {
        shouldIgnoreReloadRequests = true
        sections.remove(at: index)
        sections.insert(section, at: index)

        collectionView.reloadSections(.init(integer: index))
        shouldIgnoreReloadRequests = false
    }

    public func deleteSection(atIndex index: Int) {
        shouldIgnoreReloadRequests = true
        sections.remove(at: index)

        collectionView.deleteSections(.init(integer: index))
        shouldIgnoreReloadRequests = false
    }
}

// MARK: - Diff

extension CollectionViewManager {
    public func update(with sections: [CollectionViewSection]) {
        shouldIgnoreReloadRequests = true

        let sectionCount = max(self.sections.count, sections.count)
        var oldCellItemCollections = self.sections.map(\.items)
        for _ in stride(from: oldCellItemCollections.count, to: sectionCount, by: 1) {
            oldCellItemCollections.append([])
        }

        var newCellItemCollections = sections.map(\.items)
        for _ in stride(from: newCellItemCollections.count, to: sectionCount, by: 1) {
            newCellItemCollections.append([])
        }

        var deletedSections: IndexSet = .init()
        var addedSections: IndexSet = .init()

        var deletedIndexPaths: [IndexPath] = []
        var insertedIndexPaths: [IndexPath] = []

        for (index, (old, new)) in zip(oldCellItemCollections, newCellItemCollections).enumerated() {
            if new.isEmpty {
                deletedSections.insert(index)
                continue
            }

            if old.isEmpty {
                addedSections.insert(index)
                continue
            }

            let difference = new.difference(from: old) { (lhs: any CollectionViewCellItem, 
                                                          rhs: any CollectionViewCellItem) in
                return lhs.matches(rhs)
            }

            for change in difference.removals {
                switch change {
                case let .remove(offset, _, _):
                    deletedIndexPaths.append(.init(item: offset, section: index))
                default:
                    break
                }
            }

            for change in difference.insertions {
                switch change {
                case let .insert(offset, _, _):
                    insertedIndexPaths.append(.init(item: offset, section: index))
                default:
                    break
                }
            }
        }

        collectionView.performBatchUpdates({
            collectionView.deleteSections(deletedSections)
            collectionView.deleteItems(at: deletedIndexPaths)

            self.sections = sections
            collectionView.insertSections(addedSections)
            collectionView.insertItems(at: insertedIndexPaths)
        }, completion: { _ in
            self.shouldIgnoreReloadRequests = false
        })
    }
}
