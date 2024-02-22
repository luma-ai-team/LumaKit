//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import AVFoundation

extension CVPixelBuffer {
    static func make32BGRA(size: CGSize) -> CVPixelBuffer? {
        let size = CGRect(origin: .zero, size: size).alignedForVideoExport().size
        let width = Int(size.width)
        let height = Int(size.height)

        let bytesPerPixel = 4
        let pixelFormat = kCVPixelFormatType_32BGRA

        let surfaceProperties: [CFString: Any] = [
            kIOSurfaceWidth: width,
            kIOSurfaceHeight: height,
            kIOSurfaceBytesPerElement: bytesPerPixel,
            kIOSurfaceBytesPerRow: width * bytesPerPixel,
            kIOSurfaceAllocSize: width * height * bytesPerPixel,
            kIOSurfacePixelFormat: pixelFormat
        ]

        guard let surface = IOSurfaceCreate(surfaceProperties as CFDictionary) else {
            return nil
        }

        let pixelBufferAttributes: [CFString: Any] = [
            kCVPixelBufferPixelFormatTypeKey: pixelFormat,
            kCVPixelBufferWidthKey: width,
            kCVPixelBufferHeightKey: height
        ]

        var pixelBuffer: Unmanaged<CVPixelBuffer>?
        CVPixelBufferCreateWithIOSurface(nil, surface, pixelBufferAttributes as CFDictionary, &pixelBuffer)
        return pixelBuffer?.takeRetainedValue()
    }
}
