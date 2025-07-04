//
//  DisplayLinkProxy.swift
//  LumaKit
//
//  Created by Anton K on 04.07.2025.
//

import UIKit

public class DisplayLinkProxy {
    weak var target: AnyObject?
    var selector: Selector

    public init(target: AnyObject, selector: Selector) {
        self.target = target
        self.selector = selector
    }

    @objc public func handleDisplayLinkTick(_ sender: CADisplayLink) {
        guard let target = target else {
            sender.invalidate()
            return
        }

        _ = target.perform(selector, with: sender)
    }

    @objc public func callAsFunction(_ sender: CADisplayLink) {
        handleDisplayLinkTick(sender)
    }
}
