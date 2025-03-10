//
//  ShareContentFetchConfiguration.swift
//  LumaKit
//
//  Created by Anton K on 04.03.2025.
//

import UIKit
import LumaKit

public final class ShareContentProvider {
    public let isPhotoLibraryAutosaveEnabled: Bool
    public var contentDescription: String = "Content"
    public let fetchHandler: (_ progressSink: AsyncPipe<Float>) async throws -> [ShareContent]

    public init(isPhotoLibraryAutosaveEnabled: Bool = true,
                fetchHandler: @escaping (_ progressSink: AsyncPipe<Float>) async throws -> [ShareContent]) {
        self.isPhotoLibraryAutosaveEnabled = isPhotoLibraryAutosaveEnabled
        self.fetchHandler = fetchHandler
    }
}

public final class ShareContentFetchVariant: Equatable {
    public let identifier: UUID = .init()
    public let title: String
    public let icon: UIImage
    public let provider: ShareContentProvider

    public init(title: String, icon: UIImage, provider: ShareContentProvider) {
        self.title = title
        self.icon = icon
        self.provider = provider
    }

    public static func == (lhs: ShareContentFetchVariant, rhs: ShareContentFetchVariant) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

public enum ShareContentFetchConfiguration {
    case sinlge(ShareContentProvider)
    case variants([ShareContentFetchVariant])
}
