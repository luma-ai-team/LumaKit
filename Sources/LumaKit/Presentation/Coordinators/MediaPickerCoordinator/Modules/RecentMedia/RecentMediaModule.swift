//
//  Copyright © 2026 . All rights reserved.
//

import GenericModule

@MainActor
protocol RecentMediaModuleInput {
    var state: RecentMediaState { get }
    func update(force: Bool, animated: Bool)
}

@MainActor
protocol RecentMediaModuleOutput {
    func recentMediaModuleDidFinish(_ moduleInput: RecentMediaModuleInput, with items: [MediaFetchService.Item])
}

typealias RecentMediaModuleDependencies = Any

final class RecentMediaModule: Module<RecentMediaPresenter> {
    //
}
