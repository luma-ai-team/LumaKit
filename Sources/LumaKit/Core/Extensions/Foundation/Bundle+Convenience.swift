//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import Foundation

public extension Bundle {

    var appDisplayName: String? {
        let displayName = infoDictionary?["CFBundleDisplayName"] as? String
        let bundleName = infoDictionary?["CFBundleName"] as? String
        return displayName ?? bundleName
    }

    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildIdentifier: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
