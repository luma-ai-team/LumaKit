//
//  Copyright © 2024 . All rights reserved.
//

import UIKit
import GenericModule
import LumaKit

@MainActor
final class DummyMediaProviderPresenter: Presenter<DummyMediaProviderState,
                                                   DummyMediaProviderViewController,
                                                   DummyMediaProviderModuleInput,
                                                   DummyMediaProviderModuleOutput,
                                                   DummyMediaProviderModuleDependencies> {
    //
}

// MARK: - DummyMediaProviderViewOutput

extension DummyMediaProviderPresenter: DummyMediaProviderViewOutput {
    func imageEventTriggered() {
        output?.dummyMediaProviderDidFinish(self, with: .init())
    }
}

// MARK: - DummyMediaProviderModuleInput

extension DummyMediaProviderPresenter: DummyMediaProviderModuleInput {
    //
}

// MARK: - DummyMediaProviderViewModelDelegate

extension DummyMediaProviderPresenter: DummyMediaProviderViewModelDelegate {
    //
}
