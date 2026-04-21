//
//  RecentMediaCellItemFactory.swift
//  LumaKit
//
//  Created by Anton K on 16.04.2026.
//

import UIKit

@MainActor
final class RecentMediaCellItemFactory {
    static var metadataCache: NSCache<NSString, RecentMediaCellModel.Metadata> = .init()
    weak var collectionView: UICollectionView?
    var output: RecentMediaViewOutput?

    init(collectionView: UICollectionView, output: RecentMediaViewOutput?) {
        self.collectionView = collectionView
        self.output = output
    }

    func makeSectionItems(for cellModels: [RecentMediaCellModel]) -> [CollectionViewSection] {
        let items: [any CollectionViewItem] = cellModels.map { (cellModel: RecentMediaCellModel) in
            let item: LazyCollectionViewItem<RecentMediaCell> = .init(viewModel: cellModel)
            cellModel.metadata = Self.metadataCache.object(forKey: cellModel.item.identifier as NSString)
            item.registerLazyKeyPath(\.metadata) {
                let metadata: RecentMediaCellModel.Metadata
                switch cellModel.item.content {
                case .image(let image):
                    let canvasRect = CGRect(origin: .zero, size: .init(width: 240.0, height: 240.0))
                    let thumbnailSize = CGRect(filling: canvasRect, aspect: image.size.aspect).size
                    metadata = RecentMediaCellModel.Metadata(thumbnail: image.resizeLanczos(to: thumbnailSize), duration: nil)
                case .asset(let asset):
                    let thumbnailer = CachingAssetThumbnailer(asset: asset)
                    thumbnailer.maximumSize = .init(width: 240.0, height: 240.0)
                    let thumbnail = UIImage(cgImage: try thumbnailer.fetchImage(at: .zero).unwrap())
                    let duration = try await asset.load(.duration).seconds
                    metadata = RecentMediaCellModel.Metadata(thumbnail: thumbnail, duration: duration)
                }

                if #available(iOS 16.0, *) {
                    try await Task.sleep(for: .seconds(2.0))
                }
                Self.metadataCache.setObject(metadata, forKey: cellModel.item.identifier as NSString)
                return metadata
            }
            item.selectionHandler = { [weak self] _ in
                self?.output?.selectionEventTriggered(with: cellModel.item)
            }
            item.deselectionHandler = { [weak self] _ in
                self?.output?.selectionEventTriggered(with: cellModel.item)
            }
            if cellModel.isEditable {
                item.contextActions = [
                    .init(title: "Delete", image: .init(systemName: "trash"), attributes: .destructive, handler: { [weak self] _ in
                        let indexPath = IndexPath(item: cellModels.firstIndex(of: cellModel) ?? 0, section: 0)
                        self?.collectionView?.performBatchUpdates {
                            self?.collectionView?.deleteItems(at: [indexPath])
                            self?.output?.deleteEventTriggered(with: cellModel.item)
                        }
                    })
                ]
            }
            return item
        }

        let section = BasicCollectionViewSection(items: items)
        section.insets = .init(horizontal: 16, vertical: 8)
        return [section]
    }

    func makePlaceholderSectionItems(count: Int, colorScheme: ColorScheme) -> [CollectionViewSection] {
        let items: [any CollectionViewItem] = stride(from: 0, to: count, by: 1).map { _ in
            let model: RecentMediaCellModel = .empty(with: colorScheme)
            let item: LazyCollectionViewItem<RecentMediaCell> = .init(viewModel: model)
            return item
        }
        
        let section = BasicCollectionViewSection(items: items)
        section.insets = .init(horizontal: 16, vertical: 8)
        return [section]
    }
}
