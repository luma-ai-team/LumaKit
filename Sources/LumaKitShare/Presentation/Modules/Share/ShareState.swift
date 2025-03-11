//
//  Copyright © 2025 . All rights reserved.
//

import UIKit
import LumaKit

public final class ShareState {
    enum SharingError: LocalizedError, Equatable {
        case notAuthorized
        case contentFetchFailed(String)

        var errorDescription: String? {
            switch self {
            case .notAuthorized:
                return "Photo Library permissions missing"
            case .contentFetchFailed(let status):
                return status
            }
        }
    }

    enum Step: Equatable {
        case initial
        case variants([ShareContentFetchVariant])
        case progress(Float)
        case failure(SharingError)
        case success([ShareContent])
    }

    public let colorScheme: ColorScheme
    public let destinations: [ShareDestination]
    public let contentFetchConfiguration: ShareContentFetchConfiguration

    public var applicationName: String? = Bundle.main.appDisplayName
    public var applicationIdentifier: String?
    public var contentFetchHandlersOverrides: [ShareHandlerOverride] = []
    public var feedbackHandler: ((String) async -> Void)?

    var step: Step = .initial
    var contentProvider: ShareContentProvider?
    var isPhotoLibraryAutoSaveCompleted: Bool = false
    var isAppRateRequestEnabled: Bool = false

    public init(colorScheme: ColorScheme,
                destinations: [ShareDestination],
                contentFetchConfiguration: ShareContentFetchConfiguration) {
        self.colorScheme = colorScheme
        self.destinations = destinations
        self.contentFetchConfiguration = contentFetchConfiguration
    }
}
