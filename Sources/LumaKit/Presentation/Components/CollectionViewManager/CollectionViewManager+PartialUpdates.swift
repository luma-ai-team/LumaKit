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
        var oldSections: [CollectionViewSection?] = self.sections
        for _ in stride(from: oldSections.count, to: sectionCount, by: 1) {
            oldSections.append(nil)
        }

        var newSections: [CollectionViewSection?] = sections
        for _ in stride(from: newSections.count, to: sectionCount, by: 1) {
            newSections.append(nil)
        }

        var deletedSections: IndexSet = .init()
        var addedSections: IndexSet = .init()

        var deletedIndexPaths: [IndexPath] = []
        var insertedIndexPaths: [IndexPath] = []
        var reloadedSectionsIndexSet: IndexSet = .init()

        for (index, (old, new)) in zip(oldSections, newSections).enumerated() {
            guard let new = new else {
                deletedSections.insert(index)
                continue
            }

            guard let old = old else {
                addedSections.insert(index)
                continue
            }

            if new.header !== old.header,
               new.header?.matches(old.header) != true {
                reloadedSectionsIndexSet.insert(index)
                continue
            }

            if new.footer !== old.footer,
               new.footer?.matches(old.footer) != true {
                reloadedSectionsIndexSet.insert(index)
                continue
            }

            let difference = new.items.difference(from: old.items) { (lhs: any CollectionViewCellItem,
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
            if reloadedSectionsIndexSet.isEmpty == false {
                collectionView.reloadSections(reloadedSectionsIndexSet)
            }

            collectionView.insertSections(addedSections)
            collectionView.insertItems(at: insertedIndexPaths)
        }, completion: { _ in
            self.shouldIgnoreReloadRequests = false
        })
    }
}
