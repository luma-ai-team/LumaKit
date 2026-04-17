//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

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
            borderView.materialStyle = materialStyle
            updateBorderView()
        }
    }

    open var backgroundColorOverride: UIColor? {
        didSet {
            updateContent()
        }
    }

    public private(set) lazy var contentView: PassiveContainerView = .init()
    public private(set) lazy var blurOverlayView: BlurView = .init(opacity: blurOpacity)

    public var floatingView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let floatingView = floatingView {
                view.insertSubview(floatingView, aboveSubview: blurOverlayView)
            }
            view.setNeedsLayout()
        }
    }

    public var maximalWidth: CGFloat = 560.0 {
        didSet {
            guard isViewLoaded else {
                return
            }

            view.setNeedsLayout()
        }
    }

    public var minimalHeight: CGFloat? = 120.0 {
        didSet {
            guard isViewLoaded else {
                return
            }

            view.setNeedsLayout()
        }
    }

    public var isKeyboardTrackingEnabled: Bool = true {
        didSet {
            guard isViewLoaded else {
                return
            }

            view.setNeedsLayout()
        }
    }

    private var keyboardInset: CGFloat = 0.0

    private lazy var borderView: MaterialBorderView = {
        let view = MaterialBorderView()
        return view
    }()

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        recognizer.delegate = self
        return recognizer
    }()

    open override var modalPresentationStyle: UIModalPresentationStyle {
        set {}
        get {
            return .overCurrentContext
        }
    }

    open override var modalTransitionStyle: UIModalTransitionStyle {
        set {}
        get {
            return .crossDissolve
        }
    }

    open override var prefersStatusBarHidden: Bool {
        return presentingViewController?.prefersStatusBarHidden ?? false
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return presentingViewController?.preferredStatusBarStyle ?? .default
    }

    private var isContentVisible: Bool = false

    public init(content: any SheetContent) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    open override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black.withAlphaComponent(0.35)
        view.addSubview(blurOverlayView)

        view.addSubview(contentView)
        contentView.clipsToBounds = true

        update(with: content)

        view.addSubview(borderView)
        updateBorderView()

        let cornerRadius = max(UIScreen.main.fetchDisplayCornerRadius(fallback: 38.0), 24.0)
        if #available(iOS 26.0, *) {
            contentView.cornerConfiguration = .corners(topLeftRadius: 38.0,
                                                       topRightRadius: 38.0,
                                                       bottomLeftRadius: .init(floatLiteral: cornerRadius),
                                                       bottomRightRadius: .init(floatLiteral: cornerRadius))
            borderView.cornerConfiguration = contentView.cornerConfiguration
        }
        else {
            contentView.applyCornerRadius(value: cornerRadius)
            borderView.applyCornerRadius(value: cornerRadius)
        }

        view.addGestureRecognizer(tapGestureRecognizer)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        isContentVisible = true
        if animated {
            UIView.defaultSpringAnimation(view.layout)
        }
        else {
            view.layout()
        }

        if let floatingView = floatingView {
            view.insertSubview(floatingView, aboveSubview: blurOverlayView)
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

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        blurOverlayView.frame = view.bounds

        let edgeInset: CGFloat = 5.0
        let contentWidth = min(view.bounds.width - 2.0 * edgeInset, maximalWidth)
        let contentHeight = max(content.heightResolver(traitCollection), minimalHeight ?? 0.0)

        var contentRect: CGRect
        if UIDevice.current.userInterfaceIdiom != .phone {
            let offset = isContentVisible ? (-0.5 * keyboardInset) : 80.0
            contentRect = .init(x: 0.5 * (view.bounds.width - contentWidth),
                                y: 0.5 * (view.bounds.height - contentHeight) + offset,
                                width: contentWidth,
                                height: contentHeight)
        }
        else {
            let offset = isContentVisible ? (contentHeight + keyboardInset + edgeInset + view.safeAreaInsets.bottom) : 0.0
            contentRect = .init(x: 0.5 * (view.bounds.width - contentWidth),
                                y: view.bounds.height - offset,
                                width: contentWidth,
                                height: contentHeight + view.safeAreaInsets.bottom)
        }

        content.view.frame = .init(x: 0.0, y: 0.0, width: contentWidth, height: contentHeight)

        if contentView.superview === view {
            contentView.frame = contentRect
            borderView.frame = contentView.frame
        }
        else {
            borderView.frame = contentRect
            contentView.frame = borderView.bounds
        }

        layoutFloatingView()
    }

    private func updateBorderView() {
        borderView.frame = contentView.frame
        if borderView.materialStyle.isSystem {
            if #available(iOS 26, *) {
                view.bringSubviewToFront(borderView)
                borderView.isUserInteractionEnabled = borderView.materialStyle.isInteractive
                borderView.contentView.addSubview(contentView)
            }
            else {
                view.insertSubview(borderView, belowSubview: contentView)
                borderView.isUserInteractionEnabled = false
            }
        }
        else {
            borderView.isUserInteractionEnabled = false
            view.bringSubviewToFront(borderView)
        }
    }

    private func layoutFloatingView() {
        guard let floatingView = floatingView else {
            return
        }

        floatingView.frame = .init(x: 0.0,
                                   y: 0.0,
                                   width: view.bounds.width,
                                   height: borderView.frame.minY + 24.0)
    }

    open override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
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

        contentView.addSubview(content.view)
        content.view.layoutIfNeeded()
        updateContent()
    }

    open func updateContent() {
        if let backgroundColorOverride = backgroundColorOverride {
            content.view.backgroundColor = .clear
            contentView.backgroundColor = backgroundColorOverride
        }
        else {
            contentView.backgroundColor = content.view.backgroundColor
        }

        isModalInPresentation = content.isModal

        UIView.defaultSpringAnimation {
            self.view.layout()
        }
    }

    open func dismiss() {
        dismiss(animated: true)
    }

    open func dismissAll() {
        super.dismiss(animated: true)

        isContentVisible = false
        UIView.defaultSpringAnimation(animations: {
            self.view.backgroundColor = .black.withAlphaComponent(0.0)
            self.blurOverlayView.alpha = 0.0
            self.floatingView?.alpha = 0.0
            self.contentView.alpha = 0.0
            self.borderView.alpha = 0.0
            self.view.layout()
        }, completion: { _ in
            self.presentingViewController?.dismiss(animated: false)
        })
    }

    open override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let willDismissPresentedViewController = presentedViewController != nil
        super.dismiss(animated: flag, completion: completion)
        guard willDismissPresentedViewController == false else {
            return
        }

        isContentVisible = false
        UIView.defaultSpringAnimation {
            self.view.layout()
        }
    }

    // MARK: - Actions

    @objc private func viewTapped() {
        let location = tapGestureRecognizer.location(in: view)
        guard borderView.frame.contains(location) == false,
              isModalInPresentation == false else {
            return
        }

        dismiss()
    }

    @objc private func keyboardFrameWillChange(_ notification: Notification) {
        guard let rect = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect,
              isKeyboardTrackingEnabled else {
            return
        }

        if rect.isEmpty {
            keyboardInset = 0.0
        }
        else {
            var inset = view.bounds.height - rect.minY
            if inset > view.safeAreaInsets.bottom {
                inset -= view.safeAreaInsets.bottom
            }
            keyboardInset = inset
        }

        view.layout()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension SheetViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location = gestureRecognizer.location(in: view)
        return borderView.frame.contains(location) == false
    }
}
