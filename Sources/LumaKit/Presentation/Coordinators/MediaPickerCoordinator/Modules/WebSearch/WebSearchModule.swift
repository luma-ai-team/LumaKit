//
//  Copyright © 2025 . All rights reserved.
//

import UIKit
import GenericModule

protocol WebSearchModuleInput {
    var state: WebSearchState { get }
    func update(force: Bool, animated: Bool)
}

protocol WebSearchModuleOutput {
    func webSearchModuleDidDismiss(_ module: WebSearchModuleInput)
    func webSearchModuleDidFail(_ module: WebSearchModuleInput, with error: Error)
    func webSearchModuleDidFinish(_ module: WebSearchModuleInput, with image: UIImage)
}

typealias WebSearchModuleDependencies = WebSearchProvider

final class WebSearchModule: Module<WebSearchPresenter> {
    //
}
