//
//  DestinationSelectView.swift
//  LumaKit
//
//  Created by Anton K on 10.03.2025.
//

import UIKit
import LumaKit
import GenericModule

protocol DestinationSelectViewDelegate: AnyObject {
    func destinationSelectViewDidRequestShare(_ sender: DestinationSelectView, destination: ShareDestination)
    func destinationSelectViewDidRequestRateApp(_ sender: DestinationSelectView, rating: Int)
}

final class DestinationSelectView: UIView, NibBackedView, SheetContent {
    final class Status {
        let icon: UIImage?
        let text: String

        init(icon: UIImage?, text: String) {
            self.icon = icon
            self.text = text
        }
    }

    static var nib: ViewNib {
        return .init(name: "DestinationSelectView", bundle: .module)
    }

    weak var delegate: DestinationSelectViewDelegate?

    var colorScheme: ColorScheme = .init() {
        didSet {
            updateColorScheme()
            updateDestinations()
        }
    }

    var destinations: [ShareDestination] = [] {
        didSet {
            updateDestinations()
        }
    }

    var status: Status? {
        didSet {
            statusImageVIew.image = status?.icon
            statusLabel.text = status?.text
            statusStackView.setHidden(status == nil, animated: false)
            setNeedsLayout()
        }
    }

    var isAppRateRequestEnabled: Bool = false {
        didSet {
            rateAppView.setHidden(isAppRateRequestEnabled == false, animated: false)
        }
    }

    var isModal: Bool {
        return false
    }

    @IBOutlet weak var stackView: UIStackView!

    @IBOutlet weak var statusStackView: UIStackView!
    @IBOutlet weak var statusImageVIew: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var rateAppView: RateAppView!

    private lazy var collectionViewManager: CollectionViewManager = .init(collectionView: collectionView)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        loadFromNib()
        updateColorScheme()
        updateDestinations()

        rateAppView.delegate = self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.layoutIfNeeded()

        let contentWidth = collectionView.contentSize.width
        let inset = max(0.5 * (collectionView.bounds.width - contentWidth), 0.0)
        collectionView.contentInset.left = inset
        collectionView.contentInset.right = inset
    }

    private func updateColorScheme() {
        backgroundColor = colorScheme.background.primary
        rateAppView.colorScheme = colorScheme

        statusLabel.textColor = colorScheme.foreground.primary
        statusImageVIew.tintColor = colorScheme.foreground.primary
    }

    private func updateDestinations(with content: [ShareContent] = []) {
        let cellItems: [any CollectionViewCellItem] = destinations.compactMap { (destination: ShareDestination) in
            guard destination.status != .unavailable,
                  destination.canShare(content) else {
                return nil
            }

            let model = ShareDestinationCellModel(colorScheme: colorScheme, destination: destination)
            let item = BasicCollectionViewItem<ShareDestinationCell>(viewModel: model)
            item.selectionHandler = { [weak self] _ in
                guard let self = self else {
                    return
                }

                self.delegate?.destinationSelectViewDidRequestShare(self, destination: destination)
            }
            return item
        }

        let section = BasicCollectionViewSection(items: cellItems)
        section.insets.left = 14.0
        section.insets.right = 14.0
        collectionViewManager.sections = [section]
    }

    func update(with content: [ShareContent]) {
        updateDestinations(with: content)
    }
}

// MARK: - RateAppViewDelegate

extension DestinationSelectView: RateAppViewDelegate {
    func rateAppDidSelect(_ sender: RateAppView, rating: Int) {
        delegate?.destinationSelectViewDidRequestRateApp(self, rating: rating)
    }
}
