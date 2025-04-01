//
//  Copyright © 2025 . All rights reserved.
//

import Foundation
import GenericModule

@MainActor
public protocol ShareModuleInput {
    var state: ShareState { get }
    func update(force: Bool, animated: Bool)
}

@MainActor
public protocol ShareModuleOutput {
    func shareModuleDidRequestSystemAppReview(_ input: ShareModuleInput)
    func shareModuleDidRequestAppReview(_ input: ShareModuleInput, rating: Int)
    func shareModuleDidRequestAppFeedback(_ input: ShareModuleInput, rating: Int)
    func shareModuleDidRequestOpen(_ input: ShareModuleInput, url: URL)
    func shareModuleDidRequestShare(_ input: ShareModuleInput,
                                    content: [ShareContent],
                                    destination: ShareDestination) async
}

public typealias ShareModuleDependencies = HasStorageService

public final class ShareModule: Module<SharePresenter> {
    //
}
