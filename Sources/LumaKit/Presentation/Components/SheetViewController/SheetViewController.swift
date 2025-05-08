//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class SheetViewController: UIViewController {

    public private(set) var content: any SheetContent
    public var dismissHandler: (() -> Void)?

    open var blurOpacity: CGFloat = 0.0 {
        didSet {
            blurOverlayView.blurOpacity = blurOpacity
        }
    }

    open var materialStyle: MaterialStyle = .default {
        didSet {
            switch materialStyle {
            case .default:
                borderView.isHidden = true
            case .glass:
                borderView.isHidden = false
            }
        }
    }

    public lazy var blurOverlayView: BlurView = .init(opacity: blurOpacity)

    public var floatingView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let floatingView = floatingView {
                sheet.containerView?.insertSubview(floatingView, at: 0)
            }
            view.setNeedsLayout()
        }
    }

    public var minimalHeight: CGFloat? {
        didSet {
            if #available(iOS 16.0, *) {
                sheet.invalidateDetents()
            }
        }
    }

    private lazy var borderView: GlassBorderView = {
        let view = GlassBorderView()
        view.isHidden = true
        return view
    }()

    private var sheet: UISheetPresentationController {
        if let sheetPresentationController = sheetPresentationController {
            return sheetPresentationController
        }

        assertionFailure("Misconfigured modalPresentationStyle for \(self)")
        return UISheetPresentationController(presentedViewController: self, presenting: nil)
    }

    open override var modalPresentationStyle: UIModalPresentationStyle {
        set {}
        get {
            return .formSheet
        }
    }

    public init(content: any SheetContent) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        super.modalPresentationStyle = .formSheet
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        if traitCollection.userInterfaceIdiom == .pad {
            modalTransitionStyle = .crossDissolve
        }

        #if os(visionOS)
        #else
        sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        #endif
        sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true

        update(with: content)

        view.addSubview(borderView)
        borderView.bindMarginsToSuperview(insets: .init(top: 0.0, left: -1.0, bottom: 1.0, right: 1.0))
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let floatingView = floatingView {
            sheet.containerView?.insertSubview(floatingView, at: 0)
            UIView.performWithoutAnimation {
                if animated {
                    blurOverlayView.alpha = 0.0
                    floatingView.alpha = 0.0
                }
                layoutFloatingView()
            }
            UIView.defaultSpringAnimation {
                self.blurOverlayView.alpha = 1.0
                floatingView.alpha = 1.0
            }
        }

        sheet.containerView?.insertSubview(blurOverlayView, at: 0)
    }

    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateGestureRecognizers()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIView.defaultSpringAnimation {
            self.blurOverlayView.alpha = 0.0
            self.floatingView?.alpha = 0.0
        }
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isBeingDismissed {
            dismissHandler?()
        }
    }

    private func updateGestureRecognizers() {
        guard let recognizers = presentationController?.presentedView?.gestureRecognizers else {
            return
        }

        for recognizer in recognizers {
            recognizer.isEnabled = content.isModal == false
        }
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        content.view.frame = view.bounds

        borderView.applyCornerRadius(value: sheet.presentedView?.layer.cornerRadius ?? 0.0)
        blurOverlayView.frame = sheet.containerView?.bounds ?? .zero
        layoutFloatingView()

        if traitCollection.userInterfaceIdiom == .pad,
           let window = view.window {
            DispatchQueue.main.async {
                self.sheet.presentedView?.center = window.bounds.center
            }
        }
    }

    private func layoutFloatingView() {
        guard let floatingView = floatingView,
              let containerView = sheet.containerView else {
            return
        }

        floatingView.frame = .init(x: 0.0,
                                   y: 0.0,
                                   width: containerView.bounds.width,
                                   height: containerView.bounds.height - view.bounds.height + 16.0)
    }

    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        content.view.frame = .zero
        content.view.frame = view.bounds
        
        DispatchQueue.main.async {
            self.updateContent()
        }
    }

    open func update(with content: any SheetContent) {
        if self.content !== content {
            content.view.frame.size.width = self.content.view.frame.size.width
            self.content.view.removeFromSuperview()
        }

        self.content = content
        if let dismissableContent = content as? DismissableSheetContent {
            dismissableContent.dismissHandler = { [weak self] in
                self?.dismiss()
            }
        }

        view.addSubview(content.view)
        view.backgroundColor = content.view.backgroundColor
        content.view.layoutIfNeeded()
        view.bringSubviewToFront(borderView)

        updateContent()
    }

    open func updateContent() {
        isModalInPresentation = content.isModal

        #if os(visionOS)
        updateGestureRecognizers()
        #else
        if #available(iOS 16.0, *) {
            sheet.detents = [.custom(resolver: { [weak content, weak self] (context: UISheetPresentationControllerDetentResolutionContext) in
                guard let content = content else {
                    return 0.0
                }

                return max(content.heightResolver(context.containerTraitCollection), self?.minimalHeight ?? 0.0)
            })]
        } else {
            sheet.detents = [.medium()]
        }

        updateGestureRecognizers()
        if #available(iOS 16.0, *) {
            sheet.animateChanges {
                sheet.invalidateDetents()
            }
        }
        #endif
    }

    open func dismiss() {
        dismiss(animated: true)
    }
}
