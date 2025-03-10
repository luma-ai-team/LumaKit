//
//  PhotoLibraryShareDestination.swift
//  LumaKit
//
//  Created by Anton K on 05.03.2025.
//

import UIKit
import LumaKit
import Photos

public final class PhotoLibraryShareDestination: ShareDestination {
    enum PhotoLibraryShareDestinationError: Error {
        case notAuthorized
    }

    public let identifier: String = "ai.luma.kit.share.photos"
    public let title: String
    public let icon: UIImage?
    public var status: ShareStatus = .available

    public init(title: String = "Save", icon: UIImage? = .init(systemName: "photo")) {
        self.title = title
        self.icon = icon
    }

    public func canShare(_ content: [ShareContent]) -> Bool {
        return content.contains { (content: ShareContent) in
            return (content.image != nil) || (content.asset != nil)
        }
    }

    public func share(_ content: [ShareContent], in context: ShareContext) async throws {
        try await performAssetChanges(in: context) {
            var requests: [PHAssetChangeRequest] = []
            for content in content {
                if content.asset != nil,
                   let url = content.url,
                   let request: PHAssetChangeRequest = .creationRequestForAssetFromVideo(atFileURL: url) {
                    requests.append(request)
                }
                else if let image = content.image {
                    requests.append(.creationRequestForAsset(from: image))
                }
            }

            return requests
        }
        status = .completed
    }

    private func performAssetChanges(in context: ShareContext,
                                     _ handler: @escaping () -> [PHAssetChangeRequest]) async throws {
        try await acquireAuthorization()
        try await PHPhotoLibrary.shared().performChanges {
            context.assetIdentifiers = handler().map(\.placeholderForCreatedAsset?.localIdentifier).compact()
        }

        self.status = .completed
    }

    func acquireAuthorization() async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized else {
            self.status = .unavailable
            throw PhotoLibraryShareDestinationError.notAuthorized
        }
    }
}
