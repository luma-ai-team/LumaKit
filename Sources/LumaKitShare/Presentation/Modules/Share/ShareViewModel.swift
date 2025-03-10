//
//  Copyright © 2025 . All rights reserved.
//

import GenericModule
import LumaKit

public protocol ShareViewModelDelegate: AnyObject {
    var state: ShareState { get }
}

public final class ShareViewModel: ViewModel {
    let colorScheme: ColorScheme
    let applicationName: String?
    let contentDescription: String?
    let destinations: [ShareDestination]
    let isPhotoLibraryAutoSaveCompleted: Bool
    let step: ShareState.Step

    public init(delegate: ShareViewModelDelegate) {
        colorScheme = delegate.state.colorScheme
        applicationName = delegate.state.applicationName
        contentDescription = delegate.state.contentProvider?.contentDescription
        destinations = delegate.state.destinations
        isPhotoLibraryAutoSaveCompleted = delegate.state.isPhotoLibraryAutoSaveCompleted
        step = delegate.state.step
    }
}
