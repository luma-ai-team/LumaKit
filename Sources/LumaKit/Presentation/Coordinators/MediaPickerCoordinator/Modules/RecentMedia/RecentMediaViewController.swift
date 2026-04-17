//
//  Copyright © 2026 . All rights reserved.
//

import UIKit
import GenericModule

protocol RecentMediaViewInput {
    func dismiss()
}

protocol RecentMediaViewOutput: ViewOutput {
    func selectionEventTriggered(with item: MediaFetchService.Item)
    func deleteEventTriggered(with item: MediaFetchService.Item)
    func confirmSelectionEventTriggered()
}

final class RecentMediaViewController: ViewController<RecentMediaViewModel,
                                                      RecentMediaViewInput,
                                                      RecentMediaViewOutput>, RecentMediaViewInput {
    private lazy var factory: RecentMediaCellItemFactory = .init(output: output)
    private lazy var collectionViewManager: CollectionViewManager = .init(collectionView: collectionView)
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8.0
        layout.minimumLineSpacing = 8.0
        return layout
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad {
            navigationController?.view.backgroundColor = viewModel.colorScheme.background.primary

            view.addSubview(collectionView)
            collectionView.bindMarginsToSuperview()

            #if targetEnvironment(macCatalyst)
            collectionViewManager.simulatesiOSMultiSelectionBehavior = true
            #endif

            title = "Recents"
            if #available(iOS 26.0, *) {
                var container = AttributeContainer()
                container.font = .compatibleSystemFont(ofSize: 17.0, weight: .semibold)
                container.foregroundColor = viewModel.colorScheme.foreground.primary
                navigationItem.attributedTitle = .init("Recents", attributes: container)
            }

            navigationItem.leftBarButtonItem = .init(image: makeNavigationItemImage(name: "xmark"),
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(dismissButtonPressed))
            navigationItem.leftBarButtonItem?.tintColor = viewModel.colorScheme.foreground.primary
        }
    }

    private func makeNavigationItemImage(name: String) -> UIImage? {
        let tint = viewModel.colorScheme.foreground.primary
        let configuration = UIImage.SymbolConfiguration(pointSize: 15.0, weight: .bold)
        return .init(systemName: name, withConfiguration: configuration)?.withTintColor(tint)
    }

    override func update(with viewUpdate: Update<ViewModel>, animated: Bool) {
        super.update(with: viewUpdate, animated: animated)

        viewUpdate(\.filter, \.selectionLimit) {
            if viewModel.selectionLimit > 1 {
                if #available(iOS 26.0, *) {
                    let contentDescription = "\(viewModel.filter?.rawValue ?? "media")s"
                    let subtitle = "Select up to \(viewModel.selectionLimit) \(contentDescription)"

                    var container = AttributeContainer()
                    container.font = .compatibleSystemFont(ofSize: 12.0, weight: .regular)
                    container.foregroundColor = viewModel.colorScheme.foreground.secondary
                    navigationItem.attributedSubtitle = .init(subtitle, attributes: container)
                }

                navigationItem.rightBarButtonItem = .init(image: makeNavigationItemImage(name: "checkmark"),
                                                          style: .done,
                                                          target: self,
                                                          action: #selector(confirmButtonPressed))
                navigationItem.rightBarButtonItem?.tintColor = viewModel.colorScheme.primaryAction.active
            }
            else {
                navigationItem.rightBarButtonItem = nil
                if #available(iOS 26.0, *) {
                    navigationItem.subtitle = nil
                }
            }
        }

        viewUpdate(\.cellModels) { (cellModels: [RecentMediaCellModel]) in
            if cellModels.isEmpty {
                collectionView.isUserInteractionEnabled = false
                collectionViewManager.sections = factory.makePlaceholderSectionItems(count: viewModel.expectedItemCount,
                                                                                     colorScheme: viewModel.colorScheme)
            }
            else {
                collectionView.isUserInteractionEnabled = true
                collectionViewManager.sections = factory.makeSectionItems(for: cellModels)
            }
        }

        viewUpdate(\.selectedIndexPaths) { (indexPaths: [IndexPath]) in
            navigationItem.rightBarButtonItem?.isEnabled = indexPaths.isEmpty == false
            for indexPath in collectionView.indexPathsForSelectedItems ?? [] {
                collectionView.deselectItem(at: indexPath, animated: false)
            }
            for indexPath in indexPaths {
                collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            }
        }
    }

    func dismiss() {
        super.dismiss(animated: true)
    }

    // MARK: - Actions

    @objc private func dismissButtonPressed() {
        dismiss(animated: true)
    }

    @objc private func confirmButtonPressed() {
        output.confirmSelectionEventTriggered()
    }
}
