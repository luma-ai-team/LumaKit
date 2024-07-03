//
//  SheetCoordinator.swift
//
//
//  Created by Anton Kormakov on 03.07.2024.
//

import UIKit
import GenericModule

open class SheetPresentationContext: ModulePresentationContext {
    public typealias V = UIViewController

    private var retainedSheetViewController: SheetViewController?
    private weak var weakSheetViewController: SheetViewController?

    open var sheetViewController: SheetViewController {
        get {
            return weakSheetViewController ?? retainedSheetViewController ?? .init(content: UIViewController())
        }
        set {
            retainedSheetViewController = newValue
        }
    }

    required public init() {}

    open func present(_ target: UIViewController, in rootViewController: V) {
        sheetViewController = .init(content: target)
        rootViewController.present(sheetViewController, animated: true)
        relinquishSheetViewControllerOwnership()
    }

    private func relinquishSheetViewControllerOwnership() {
        weakSheetViewController = retainedSheetViewController
        retainedSheetViewController = nil
    }
}

open class SheetCoordinator<M: PresentableModule<P>,
                            P: ModulePresenter>: ModuleCoordinator<M, P, SheetPresentationContext> {
    //
}
