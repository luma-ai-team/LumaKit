//
//  Copyright © 2024 . All rights reserved.
//

import UIKit
import GenericModule
import LumaKit

@MainActor
protocol DummyMediaProviderModuleInput {}

@MainActor
protocol DummyMediaProviderModuleOutput {
    func dummyMediaProviderDidDismiss(_ moduleInput: DummyMediaProviderModuleInput)
    func dummyMediaProviderDidFail(_ moduleInput: DummyMediaProviderModuleInput, with error: Error)
    func dummyMediaProviderDidFinish(_ moduleInput: DummyMediaProviderModuleInput, with image: UIImage)
}

typealias DummyMediaProviderModuleDependencies = Any

final class DummyMediaProviderModule: Module<DummyMediaProviderPresenter> {
    //
}

final class DummyMediaProvider: MediaProvider, DummyMediaProviderModuleOutput {
    let item: MediaProviderItem = .init(title: "Dummy", icon: .init(systemName: "plus"), badge: "NEW")
    weak var output: MediaProviderOutput?

    var viewController: UIViewController {
        let module = DummyMediaProviderModule(state: .init(), dependencies: [])
        module.output = self
        return module.viewController
    }

    // MARK: - DummyMediaProviderModuleOutput

    func dummyMediaProviderDidDismiss(_ moduleInput: any DummyMediaProviderModuleInput) {
        output?.mediaProviderDidDismiss(self)
    }

    func dummyMediaProviderDidFail(_ moduleInput: any DummyMediaProviderModuleInput, with error: any Error) {
        output?.mediaProviderDidFail(self, with: error)
    }

    func dummyMediaProviderDidFinish(_ moduleInput: any DummyMediaProviderModuleInput, with image: UIImage) {
        output?.mediaProviderDidFinish(self, with: [.image(image)])
    }
}
