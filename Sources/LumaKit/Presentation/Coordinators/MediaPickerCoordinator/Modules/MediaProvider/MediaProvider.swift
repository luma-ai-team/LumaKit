//
//  MediaProvider.swift
//  LumaKit
//
//  Created by Anton K on 14.04.2026.
//

import UIKit
import GenericModule

@MainActor
public protocol MediaProviderOutput: AnyObject {
    func mediaProviderDidDismiss(_ provider: MediaProvider)
    func mediaProviderDidFail(_ provider: MediaProvider, with error: Error)
    func mediaProviderDidFinish(_ provider: MediaProvider, with items: [MediaFetchService.Item])
}

@MainActor
public protocol MediaProvider: AnyObject {
    var item: MediaProviderItem { get }
    var viewController: UIViewController { get }
    var modalPresentationStyle: UIModalPresentationStyle { get }
    var navigationAppearance: StyledNavigationController.Appearance? { get }
    var output: (any MediaProviderOutput)? { get set }
}

extension MediaProvider {
    public var modalPresentationStyle: UIModalPresentationStyle {
        return .formSheet
    }

    public var navigationAppearance: StyledNavigationController.Appearance? {
        return nil
    }
}

public class CustomMediaProvider: MediaProvider {
    public var item: MediaProviderItem
    public var viewController: UIViewController
    public weak var output: MediaProviderOutput?

    public init(item: MediaProviderItem, viewController: UIViewController) {
        self.item = item
        self.viewController = viewController
    }
}
