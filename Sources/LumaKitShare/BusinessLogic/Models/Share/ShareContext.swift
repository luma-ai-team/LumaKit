//
//  ShareContext.swift
//  LumaKit
//
//  Created by Anton K on 03.03.2025.
//

import UIKit

public final class ShareContext {
    public internal(set) var rootViewController: UIViewController
    public var sourceView: UIView?
    public var sourceRect: CGRect?
    public var assetIdentifiers: [String]?

    public init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        sourceView = rootViewController.view
    }
}
