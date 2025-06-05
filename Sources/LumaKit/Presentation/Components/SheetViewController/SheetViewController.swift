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
            switch materialStyle {
            case .default:
                borderView.isHidden = true
            case .glass(let tint):
                borderView.tintColor = tint
                borderView.isHidden = false
            }
        }
    }

    public private(set) lazy var contentView: UIView = .init()
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

    public var maximalWidth: CGFloat = 640 {
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

    private lazy var borderView: GlassBorderView = {
        let view = GlassBorderView()
        view.alpha = 0.5
        view.isHidden = true
        return view
    }()

    private lazy var tapGestureRecognizer: UITapGestureRecognizer = .init(target: self, action: #selector(viewTapped))

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
        if UIDevice.current.userInterfaceIdiom == .phone {
            contentView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        contentView.applyCornerRadius(value: 24.0)
        contentView.clipsToBounds = true

        update(with: content)

        view.addSubview(borderView)
        borderView.isUserInteractionEnabled = false
        borderView.applyCornerRadius(value: 24.0)

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

        let contentWidth = min(view.bounds.width, maximalWidth)
        let contentHeight = max(content.heightResolver(traitCollection), minimalHeight ?? 0.0)

        if UIDevice.current.userInterfaceIdiom != .phone {
            let offset = isContentVisible ? (-0.5 * keyboardInset) : 80.0
            contentView.frame = .init(x: 0.5 * (view.bounds.width - contentWidth),
                                      y: 0.5 * (view.bounds.height - contentHeight) + offset,
                                      width: contentWidth,
                                      height: contentHeight)
        }
        else {
            let offset = isContentVisible ? (contentHeight + keyboardInset) : 0.0
            contentView.frame = .init(x: 0.5 * (view.bounds.width - contentWidth),
                                      y: view.bounds.height - offset - view.safeAreaInsets.bottom,
                                      width: contentWidth,
                                      height: contentHeight + view.safeAreaInsets.bottom)
        }

        content.view.frame = .init(x: 0.0, y: 0.0, width: contentWidth, height: contentHeight)
        borderView.frame = contentView.frame

        if UIDevice.current.userInterfaceIdiom == .phone {
            borderView.frame.origin.x -= 1.0
            borderView.frame.size.width += 2.0
            borderView.frame.size.height += 24.0
        }

        layoutFloatingView()
    }

    private func layoutFloatingView() {
        guard let floatingView = floatingView else {
            return
        }

        floatingView.frame = .init(x: 0.0,
                                   y: 0.0,
                                   width: view.bounds.width,
                                   height: contentView.frame.minY + 24.0)
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
        contentView.backgroundColor = content.view.backgroundColor
        isModalInPresentation = content.isModal

        UIView.defaultSpringAnimation {
            self.view.layout()
        }
    }

    open func dismiss() {
        dismiss(animated: true)
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
        guard contentView.frame.contains(location) == false,
              isModalInPresentation == false else {
            return
        }

        dismiss()
    }

    @objc private func keyboardFrameWillChange(_ notification: Notification) {
        guard let rect = notification.userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect else {
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
