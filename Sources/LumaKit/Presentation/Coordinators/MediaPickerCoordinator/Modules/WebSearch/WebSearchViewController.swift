//
//  Copyright © 2025 . All rights reserved.
//

import UIKit
import GenericModule

protocol WebSearchViewOutput: ViewOutput {
    func dismissEventTriggered()
    func searchEventTriggered(term: String)
    func nextPageEventTriggered()
    func selectionEventTriggered(_ result: any WebSearchResult)
}

final class WebSearchViewController: ViewController<WebSearchViewModel, Any, WebSearchViewOutput> {
    override class var nib: ViewNib {
        return .init(name: "WebSearchViewController", bundle: .module)
    }

    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewLayout: WaterfallCollectionViewLayout!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var bottomCollectionViewConstraint: NSLayoutConstraint!

    private lazy var dismissButton: BounceButton = {
        let button = BounceButton()
        button.tintColor = viewModel.colorScheme.foreground.primary
        button.setImage(.init(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        if #unavailable(iOS 26) {
            button.activateSizeAnchors(with: .init(width: 40.0, height: 40.0))
        }
        return button
    }()

    private lazy var collectionViewManager: CollectionViewManager = .init(collectionView: collectionView)

    // MARK: - Lifecycle

    required init(viewModel: WebSearchViewModel, output: any WebSearchViewOutput) {
        super.init(viewModel: viewModel, output: output)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setup() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardFrameWillChange),
                                               name: UIApplication.keyboardWillChangeFrameNotification,
                                               object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad {
            title = "Browse Web"
            navigationItem.leftBarButtonItem = .init(customView: dismissButton)

            view.backgroundColor = viewModel.colorScheme.background.primary

            searchBar.tintColor = viewModel.colorScheme.foreground.primary
            searchBar.placeholder = "Search images on \(viewModel.searchSource)"
            searchBar.delegate = self

            if #available(iOS 26.0, *) {
                searchView.backgroundColor = .clear
                collectionView.topEdgeEffect.style = .automatic
                collectionView.topEdgeEffect.isHidden = false
            }
            else {
                searchView.backgroundColor = viewModel.colorScheme.background.primary
            }

            #if targetEnvironment(macCatalyst)
            collectionViewLayout.columnCount = 3
            #endif

            collectionView.contentInset.top = 60.0
            collectionView.verticalScrollIndicatorInsets.top = collectionView.contentInset.top

            activityIndicatorView.color = viewModel.colorScheme.foreground.primary
            statusLabel.textColor = viewModel.colorScheme.foreground.primary
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func update(with viewUpdate: Update<ViewModel>, animated: Bool) {
        super.update(with: viewUpdate, animated: animated)

        viewUpdate(\.isFetching) { (isFetching: Bool) in
            collectionView.isHidden = isFetching
            if isFetching {
                activityIndicatorView.startAnimating()
            }
            else {
                activityIndicatorView.stopAnimating()
            }
        }

        viewUpdate(\.term) { (term: String) in
            searchBar.text = term
        }

        viewUpdate(\.results, \.canLoadNextPage) {
            let items = viewModel.results.map { (model: SearchResultCellModel) in
                let item = SearchResultCellItem(viewModel: model)
                item.registerLazyKeyPath(\.image, provider: model.asset.resolve)
                item.selectionHandler = { [weak self] _ in
                    if self?.viewModel.isHapticEnabled == true {
                        Haptic.selection.generate()
                    }
                    self?.output.selectionEventTriggered(model.result)
                }
                return item
            }

            let footer = SearchPaginationFooterItem(viewModel: .init(colorScheme: viewModel.colorScheme))
            footer.willDisplayHandler = output.nextPageEventTriggered

            let section = BasicCollectionViewSection(items: items)
            if viewModel.canLoadNextPage {
                section.footer = footer
            }
            
            section.insets.left = 16.0
            section.insets.right = 16.0
            section.insets.bottom = 16.0
            collectionViewManager.sections = [section]
        }

        viewUpdate(\.status) { (status: String?) in
            statusLabel.isHidden = status == nil
            statusLabel.text = status
        }
    }

    // MARK: - Actions

    @objc private func dismissButtonPressed() {
        if viewModel.isHapticEnabled {
            Haptic.selection.generate()
        }

        output.dismissEventTriggered()
        dismiss(animated: true)
    }

    @objc private func keyboardFrameWillChange(_ notification: Notification) {
        guard let rect = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }

        if rect.isEmpty {
            bottomCollectionViewConstraint.constant = 0.0
        }
        else {
            let inset = view.bounds.height - rect.minY
            bottomCollectionViewConstraint.constant = inset
        }

        view.layout()
    }
}

// MARK: - UITextFieldDelegate

extension WebSearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if viewModel.isHapticEnabled {
            Haptic.selection.generate()
        }
        UIView.defaultSpringAnimation {
            searchBar.setShowsCancelButton(true, animated: true)
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if viewModel.isHapticEnabled {
            Haptic.selection.generate()
        }
        output.searchEventTriggered(term: .init())
        UIView.defaultSpringAnimation {
            searchBar.setShowsCancelButton(false, animated: true)
        }
        searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        output.searchEventTriggered(term: searchText)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
