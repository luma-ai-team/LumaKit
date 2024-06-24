//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import AVFoundation

public extension AVAssetTrack {
    
    var presentationSize: CGSize {
        return naturalSize.applying(preferredTransform).abs()
    }
}
