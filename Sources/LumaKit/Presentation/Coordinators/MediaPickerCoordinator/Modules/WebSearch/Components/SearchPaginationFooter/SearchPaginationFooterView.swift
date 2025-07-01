//
//  SearchPaginationCell.swift
//  LumaKit
//
//  Created by Anton K on 01.07.2025.
//

import UIKit

final class SearchPaginationFooterView: UICollectionReusableView, CollectionViewSupplementaryView {
    typealias ViewModel = SearchPaginationFooterViewModel

    static func size(with viewModel: ViewModel, fitting size: CGSize, insets: UIEdgeInsets) -> CGSize {
        return .init(width: size.width, height: 60.0)
    }

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(activityIndicatorView)
        activityIndicatorView.bindMarginsToSuperview()
        activityIndicatorView.startAnimating()
    }

    func update(with viewModel: ViewModel, attributes: CollectionViewItemAttributes) {
        activityIndicatorView.color = viewModel.colorScheme.foreground.primary
    }
}
