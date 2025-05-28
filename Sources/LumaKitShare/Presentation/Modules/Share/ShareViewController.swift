//
//  Copyright © 2025 . All rights reserved.
//

import UIKit
import LumaKit
import GenericModule

public protocol ShareViewOutput: ViewOutput {
    func ratingEventTriggered(rating: Int)
    func variantEventTriggered(variant: ShareContentFetchVariant)
    func shareEventTriggered(with destination: ShareDestination)
    func settingsEventTriggered()
}

public final class ShareViewController: SheetViewController, View {
    public typealias Output = ShareViewOutput
    public typealias ViewModel = ShareViewModel
    public typealias ViewInput = Any

    public var output: ShareViewOutput
    public var viewModel: ShareViewModel

    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = viewModel.colorScheme.genericAction.inactive
        button.addTarget(self, action: #selector(dismissButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()

    private lazy var variantSelectionView: VariantSelectionView = {
        let view = VariantSelectionView()
        view.colorScheme = viewModel.colorScheme
        view.delegate = self
        return view
    }()

    private lazy var permissionsErrorView: PermissionsErrorView = {
        let view = PermissionsErrorView()
        view.colorScheme = viewModel.colorScheme
        view.delegate = self
        return view
    }()

    private lazy var contentFetchProgressView: ContentFetchProgressView = {
        let view = ContentFetchProgressView()
        view.colorScheme = viewModel.colorScheme
        return view
    }()

    private lazy var contentFetchErrorView: ContentFetchErrorView = {
        let view = ContentFetchErrorView()
        view.colorScheme = viewModel.colorScheme
        return view
    }()

    private lazy var destinationSelectView: DestinationSelectView = {
        let view = DestinationSelectView()
        view.colorScheme = viewModel.colorScheme
        view.destinations = viewModel.destinations
        view.isAppRateRequestEnabled = viewModel.isAppRateRequestEnabled
        view.delegate = self
        return view
    }()

    override public var materialStyle: MaterialStyle {
        didSet {
            variantSelectionView.materialStyle = materialStyle
            permissionsErrorView.materialStyle = materialStyle
            destinationSelectView.materialStyle = materialStyle

            blurOpacity = materialStyle.isGlass ? 0.15 : 0.0
        }
    }

    // MARK: - Lifecycle

    public required init(viewModel: ShareViewModel, output: ShareViewOutput) {
        self.viewModel = viewModel
        self.output = output
        super.init(content: UIViewController())
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        contentView.backgroundColor = viewModel.colorScheme.background.primary
        materialStyle = viewModel.materialStyle
        minimalHeight = 160.0

        view.addSubview(dismissButton)
        NSLayoutConstraint.activate([
            dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor),
            dismissButton.widthAnchor.constraint(equalToConstant: 48.0),
            dismissButton.heightAnchor.constraint(equalToConstant: 48.0)
        ])

        output.viewDidLoad()
    }

    public func update(with viewModel: ShareViewModel, force: Bool, animated: Bool) {
        let viewUpdate = Update(newModel: viewModel, oldModel: self.viewModel, force: force)
        self.viewModel = viewModel
        update(with: viewUpdate, animated: animated)
    }

    public func update(with viewUpdate: Update<ShareViewModel>, animated: Bool) {
        viewUpdate(\.isAppRateRequestEnabled) { (isAppRateRequestEnabled: Bool) in
            destinationSelectView.isAppRateRequestEnabled = isAppRateRequestEnabled
        }

        viewUpdate(\.step) { (step: ShareState.Step) in
            switch step {
            case .initial:
                break
            case .variants(let variants):
                variantSelectionView.update(variants: variants)
                update(with: variantSelectionView)
            case .progress(let progress):
                if let contentDescription = viewModel.contentDescription {
                    contentFetchProgressView.contentDescription = contentDescription
                }
                contentFetchProgressView.update(progress: progress)
                update(with: contentFetchProgressView)
            case .failure(let error):
                switch error {
                case ShareState.SharingError.notAuthorized:
                    update(with: permissionsErrorView)
                default:
                    contentFetchErrorView.update(with: error)
                    update(with: contentFetchErrorView)
                }
            case .success(let content):
                if viewModel.isPhotoLibraryAutoSaveCompleted {
                    destinationSelectView.status = .init(
                        icon: .init(systemName: "checkmark.circle.fill"),
                        text: "Saved To Library"
                    )
                }
                else {
                    destinationSelectView.status = nil
                }
                destinationSelectView.update(with: content)
                update(with: destinationSelectView)
            }
        }
    }

    public override func update(with content: any SheetContent) {
        content.view.frame.size.width = contentView.bounds.width
        content.view.frame.size.height = content.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
        content.view.updateConstraintsIfNeeded()

        let shouldAnimate = content !== self.content
        super.update(with: content)

        if shouldAnimate {
            let animation = CATransition()
            animation.duration = 0.075
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animation.type = .fade
            animation.subtype = .none
            view.layer.add(animation, forKey: "transition")
        }

        #if targetEnvironment(macCatalyst)
        dismissButton.isHidden = content.isModal
        view.bringSubviewToFront(dismissButton)
        #endif
    }

    // MARK: - Actions

    @objc private func dismissButtonPressed() {
        dismiss()
    }
}

// MARK: - VariantSelectionViewDelegate

extension ShareViewController: VariantSelectionViewDelegate {
    func variantSelectionViewDidSelect(_ sender: VariantSelectionView, variant: ShareContentFetchVariant) {
        output.variantEventTriggered(variant: variant)
    }
}

// MARK: - PermissionsErrorViewDelegate

extension ShareViewController: PermissionsErrorViewDelegate {
    func permissionsErrorViewDidRequestSettings(_ sender: PermissionsErrorView) {
        output.settingsEventTriggered()
    }
}

extension ShareViewController: DestinationSelectViewDelegate {
    func destinationSelectViewDidRequestShare(_ sender: DestinationSelectView, destination: any ShareDestination) {
        output.shareEventTriggered(with: destination)
    }

    func destinationSelectViewDidRequestRateApp(_ sender: DestinationSelectView, rating: Int) {
        output.ratingEventTriggered(rating: rating)
    }
}
