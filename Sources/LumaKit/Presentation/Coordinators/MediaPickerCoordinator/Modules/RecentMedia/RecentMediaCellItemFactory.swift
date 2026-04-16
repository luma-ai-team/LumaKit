//
//  RecentMediaCellItemFactory.swift
//  LumaKit
//
//  Created by Anton K on 16.04.2026.
//

import UIKit

@MainActor
final class RecentMediaCellItemFactory {
    var output: RecentMediaViewOutput?

    init(output: RecentMediaViewOutput?) {
        self.output = output
    }

    func makeSectionItems(for cellModels: [RecentMediaCellModel]) -> [CollectionViewSection] {
        let items: [any CollectionViewItem] = cellModels.map { (cellModel: RecentMediaCellModel) in
            let item: LazyCollectionViewItem<RecentMediaCell> = .init(viewModel: cellModel)
            item.registerLazyKeyPath(\.metadata) {
                switch cellModel.item.content {
                case .image(let image):
                    return RecentMediaCellModel.Metadata(thumbnail: image, duration: nil)
                case .asset(let asset):
                    let thumbnailer = CachingAssetThumbnailer(asset: asset)
                    thumbnailer.maximumSize = .init(width: 240.0, height: 240.0)
                    let thumbnail = UIImage(cgImage: try thumbnailer.fetchImage(at: .zero).unwrap())
                    let duration = try await asset.load(.duration).seconds
                    return RecentMediaCellModel.Metadata(thumbnail: thumbnail, duration: duration)
                }
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
                        self?.output?.deleteEventTriggered(with: cellModel.item)
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
