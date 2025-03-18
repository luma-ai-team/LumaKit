//
//  ShareKit.swift
//  LumaKit
//
//  Created by Anton K on 18.03.2025.
//

import UIKit
import FacebookCore
import FacebookShare
import TikTokOpenSDKCore
import TikTokOpenShareSDK

public final class ShareKit {
    public static func handleAppLaunch(with options: [UIApplication.LaunchOptionsKey: Any]?) {
        ApplicationDelegate.shared.application(UIApplication.shared, didFinishLaunchingWithOptions: options)
    }

    public static func handleOpenURL(_ url: URL) -> Bool {
        if TikTokURLHandler.handleOpenURL(url) {
            return true
        }

        return ApplicationDelegate.shared.application(UIApplication.shared,
                                                      open: url,
                                                      sourceApplication: nil,
                                                      annotation: [UIApplication.OpenURLOptionsKey.annotation])
    }
}
