//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import PhotosUI

public final class MediaFetchService  {
    public enum MediaFetchError: Error {
        case noContent
    }

    private var fetchProgress: Progress?
    private var progressTimer: Timer?

    public init() {
        //
    }

    public func canLoadImage(for result: PHPickerResult) -> Bool {
        return result.itemProvider.canLoadObject(ofClass: UIImage.self)
    }

    public func canLoadLivePhoto(for result: PHPickerResult) -> Bool {
        return result.itemProvider.canLoadObject(ofClass: PHLivePhoto.self)
    }

    public func canLoadAsset(for result: PHPickerResult) -> Bool {
        return result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier)
    }

    public func fetchAsset(for result: PHPickerResult,
                           progress: @escaping (Double) -> Void,
                           success: @escaping (AVAsset) -> Void,
                           failure: @escaping (Error) -> Void) {
        if canLoadLivePhoto(for: result) {
            return fetchLivePhotoContent(for: result, progress: progress, success: success, failure: failure)
        }

        fetchVideoAsset(for: result, progress: progress, success: success, failure: failure)
    }

    public func fetchImage(for result: PHPickerResult,
                           progress: @escaping (Double) -> Void,
                           success: @escaping (UIImage) -> Void,
                           failure: @escaping (Error) -> Void) {
        let provider = result.itemProvider
        guard provider.canLoadObject(ofClass: UIImage.self) else {
            return failure(MediaFetchError.noContent)
        }

        fetchProgress = provider.loadObject(ofClass: UIImage.self) { [weak self] (object: NSItemProviderReading?,
                                                                                  error: Error?) in
            guard let self = self else {
                return
            }

            self.invalidateTimer()
            DispatchQueue.main.async {
                if let image = object as? UIImage {
                    success(image)
                }
                else {
                    failure(error ?? MediaFetchError.noContent)
                }
            }
        }

        startTimer(progress: progress)
    }

    public func cancel() {
        fetchProgress?.cancel()
        fetchProgress = nil
    }

    private func invalidateTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        fetchProgress = nil
    }

    private func fetchLivePhotoContent(for result: PHPickerResult,
                                       progress: @escaping (Double) -> Void,
                                       success: @escaping (AVAsset) -> Void,
                                       failure: @escaping (Error) -> Void) {
        fetchProgress = result.itemProvider.loadObject(ofClass: PHLivePhoto.self) { [weak self] (object: NSItemProviderReading?,
                                                                                                 error: Swift.Error?) in
            guard let self = self else {
                return
            }

            self.invalidateTimer()
            guard let object = object as? PHLivePhoto else {
                DispatchQueue.main.async {
                    failure(MediaFetchError.noContent)
                }
                return
            }

            let resources = PHAssetResource.assetResources(for: object)
            guard let videoResource = resources.first(where: { (resource: PHAssetResource) -> Bool in
                return resource.type == .pairedVideo
            }) else {
                DispatchQueue.main.async {
                    failure(MediaFetchError.noContent)
                }
                return
            }

            let identifier = videoResource.assetLocalIdentifier.isEmpty ?
                videoResource.originalFilename :
                videoResource.assetLocalIdentifier
            let url =  URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(identifier.replacingOccurrences(of: "/", with: "_"))
                .appendingPathExtension("mov")
            try? FileManager.default.removeItem(at: url)

            let requestOptions = PHAssetResourceRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            PHAssetResourceManager.default().writeData(for: videoResource,
                                                       toFile: url,
                                                       options: requestOptions,
                                                       completionHandler: { _ in
                DispatchQueue.main.async {
                    let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
                    success(asset)
                }
            })
        }

        startTimer(progress: progress)
    }

    private func fetchVideoAsset(for result: PHPickerResult,
                                 progress: @escaping (Double) -> Void,
                                 success: @escaping (AVAsset) -> Void,
                                 failure: @escaping (Error) -> Void) {
        fetchProgress = result.itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier,
                                                                   completionHandler: { [weak self] (url: URL?, error: Error?) in
            self?.invalidateTimer()
            guard let url = url else {
                DispatchQueue.main.async {
                    failure(MediaFetchError.noContent)
                }
                return
            }

            let filename = result.assetIdentifier ?? url.lastPathComponent
            let targetURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(filename.replacingOccurrences(of: "/", with: "_"))
            try? FileManager.default.removeItem(at: targetURL)
            try? FileManager.default.copyItem(at: url, to: targetURL)

            DispatchQueue.main.async {
                let asset = AVAsset(url: targetURL)
                success(asset)
            }
        })

        startTimer(progress: progress)
    }

    private func startTimer(progress: @escaping (Double) -> Void) {
        progressTimer = Timer(fire: .init(timeIntervalSinceNow: 0.25), interval: 0.25, repeats: true) { [weak self] _ in
            progress(self?.fetchProgress?.fractionCompleted ?? 0.0)
        }

        DispatchQueue.main.async {
            if let progressTimer = self.progressTimer {
                RunLoop.current.add(progressTimer, forMode: .common)
            }
        }
    }
}
