//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

open class StyledNavigationController: UINavigationController {

    public enum BarStyle {
        case blurred
        case opaque
    }

    public struct Appearance {
        let color: UIColor
        let barStyle: BarStyle
        let isStatusBarHidden: Bool
        let statusBarStyle: UIStatusBarStyle

        public init(barStyle: BarStyle,
                    color: UIColor,
                    isStatusBarHidden: Bool = true,
                    statusBarStyle: UIStatusBarStyle = .default) {
            self.barStyle = barStyle
            self.color = color
            self.isStatusBarHidden = isStatusBarHidden
            self.statusBarStyle = statusBarStyle
        }
    }

    open override var prefersStatusBarHidden: Bool {
        return appearance.isStatusBarHidden
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return appearance.statusBarStyle
    }

    public let appearance: Appearance

    public init(appearance: Appearance) {
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
    }

    public init(rootViewController: UIViewController, appearance: Appearance) {
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
        viewControllers = [rootViewController]
    }

    required public init?(coder aDecoder: NSCoder) {
        self.appearance = .init(barStyle: .blurred, color: .white)
        super.init(coder: aDecoder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        if navigationBar.compactAppearance == nil {
            navigationBar.compactAppearance = navigationBar.standardAppearance
        }
        if navigationBar.scrollEdgeAppearance == nil {
            navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        }
        if navigationBar.compactScrollEdgeAppearance == nil {
            navigationBar.compactScrollEdgeAppearance = navigationBar.standardAppearance
        }
        updateStyle()
    }

    private func updateStyle() {
        view.backgroundColor = appearance.color

        updateNavigationBar(navigationBar.standardAppearance)
        if let compactAppearance = navigationBar.compactAppearance {
            updateNavigationBar(compactAppearance)
        }
        if let scrollEdgeAppearance = navigationBar.scrollEdgeAppearance {
            updateNavigationBar(scrollEdgeAppearance)
        }
        if let compactScrollEdgeAppearance = navigationBar.compactScrollEdgeAppearance {
            updateNavigationBar(compactScrollEdgeAppearance)
        }

        if appearance.barStyle == .blurred {
            navigationBar.setBackgroundImage(.init(), for: .default)
        }
    }

    private func updateNavigationBar(_ navigationBarAppearance: UINavigationBarAppearance) {
        switch appearance.barStyle {
        case .blurred:
            let blurEffect: UIBlurEffect.Style = appearance.color.yuv.y > 0.5 ? .light : .dark
            navigationBarAppearance.configureWithDefaultBackground()
            navigationBarAppearance.backgroundEffect = .init(style: blurEffect)
            navigationBarAppearance.backgroundColor = appearance.color.withAlphaComponent(0.4)
        case .opaque:
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = appearance.color
        }

        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.shadowImage = .init()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateStyle()
    }
}
