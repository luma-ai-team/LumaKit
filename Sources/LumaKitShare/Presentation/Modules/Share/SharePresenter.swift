//
//  Copyright © 2025 . All rights reserved.
//

import UIKit
import LumaKit
import GenericModule

public final class SharePresenter: Presenter<ShareState,
                                             ShareViewController,
                                             ShareModuleInput,
                                             ShareModuleOutput,
                                             ShareModuleDependencies> {
    private lazy var progressPipe: AsyncPipe<Float> = .init(value: 0.0)
    private lazy var progressStreamTask: StreamTask<Float> = .init(pipe: progressPipe) { [weak self] (progress: Float) in
        guard let self = self,
              case let .progress(curentProgress) = self.state.step else {
            return
        }

        self.state.step = .progress(progress)
        self.update(animated: true)
    }

    private lazy var photoLibraryShareDestination: PhotoLibraryShareDestination = .init()

    public override func viewDidLoad() {
        switch state.contentFetchConfiguration {
        case .sinlge(let provider):
            state.step = .progress(0.0)
            Task {
                try await fetchContent(using: provider)
            }
        case .variants(let variants):
            state.step = .variants(variants)
        }

        super.viewDidLoad()
    }

    private func fetchContent(using provider: ShareContentProvider) async throws {
        progressStreamTask()
        state.contentProvider = provider

        do {
            if provider.isPhotoLibraryAutosaveEnabled {
                try await photoLibraryShareDestination.acquireAuthorization()
            }

            let content = try await provider.fetchHandler(progressPipe)
            if provider.isPhotoLibraryAutosaveEnabled,
               photoLibraryShareDestination.canShare(content) {
                await output?.shareModuleDidRequestShare(self,
                                                         content: content,
                                                         destination: photoLibraryShareDestination)
            }
            state.isPhotoLibraryAutoSaveCompleted = photoLibraryShareDestination.status == .completed
            state.step = .success(content)
        }
        catch {
            let shareError: ShareState.SharingError
            switch error {
            case PhotoLibraryShareDestination.PhotoLibraryShareDestinationError.notAuthorized:
                shareError = .notAuthorized
            default:
                shareError = .contentFetchFailed(error.localizedDescription)
            }
            state.step = .failure(shareError)
        }
        update(animated: true)
    }
}

// MARK: - ShareViewOutput

extension SharePresenter: ShareViewOutput {
    public func variantEventTriggered(variant: ShareContentFetchVariant) {
        state.step = .progress(0.0)
        update(animated: true)

        Task {
            try await fetchContent(using: variant.provider)
        }
    }

    public func ratingEventTriggered(rating: Int) {
        if rating >= 4 {
            output?.shareModuleDidRequestAppReview(self)
        }
        else {
            output?.shareModuleDidRequestAppFeedback(self)
        }
    }

    public func shareEventTriggered(with destination: any ShareDestination) {
        guard case let .success(content) = state.step else {
            return
        }

        Task {
            let augmentedContent = await augment(content, for: destination)
            await output?.shareModuleDidRequestShare(self, content: augmentedContent, destination: destination)
        }
    }

    public func settingsEventTriggered() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        output?.shareModuleDidRequestOpen(self, url: url)
    }

    private func augment(_ content: [ShareContent], for destination: ShareDestination) async -> [ShareContent] {
        let overrides = state.contentFetchHandlersOverrides
        guard let override = overrides.first(with: destination.identifier, at: \.destination.identifier) else {
            return content
        }

        return await override.handler(content)
    }
}

// MARK: - ShareModuleInput

extension SharePresenter: ShareModuleInput {
    //
}

// MARK: - ShareViewModelDelegate

extension SharePresenter: ShareViewModelDelegate {
    //
}
