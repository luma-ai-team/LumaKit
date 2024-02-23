//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import CoreGraphics
import CoreVideo
import UIKit.UIImage

public final class PixelBufferRenderer {

    public enum Error: Swift.Error {
        case noContext
        case noSurface
        case noPixelBuffer
        case noImage
    }

    public let size: CGSize
    public let colorSpace: CGColorSpace

    public var pixelFormat: OSType = kCVPixelFormatType_32BGRA
    public var bytesPerPixel: Int = 4
    public var bitsPerComponent: Int = 8
    public var bitmapInfo: UInt32 = CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue

    private var context: CGContext?
    private(set) var pixelBuffer: CVPixelBuffer?

    private let transposedOrientations: [UIImage.Orientation] = [
        .left,
        .leftMirrored,
        .right,
        .rightMirrored
    ]

    public init(size: CGSize, colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()) {
        self.size = size
        self.colorSpace = colorSpace
    }

    @discardableResult
    public func draw(actions: (CGContext) -> Void) throws -> CVPixelBuffer {
        try setupContextIfNeeded()
        guard let pixelBuffer = pixelBuffer, let context = context else {
            throw Error.noPixelBuffer
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        context.saveGState()

        actions(context)

        context.restoreGState()
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])

        return pixelBuffer
    }

    @discardableResult
    public func draw(_ image: CGImage,
                     transform: CGAffineTransform = .identity,
                     isTransposed: Bool = false) throws -> CVPixelBuffer {
        let rect = CGRect(origin: .zero, size: size)
        return try draw { (context: CGContext) in
            context.clear(rect)
            context.translateBy(x: 0, y: rect.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.concatenate(transform)
            if isTransposed {
                context.draw(image, in: rect.transposed())
            }
            else {
                context.draw(image, in: rect)
            }
        }
    }

    @discardableResult
    public func draw(_ image: UIImage) throws -> CVPixelBuffer {
        guard let cgImage = image.cgImage else {
            throw Error.noImage
        }

        let rect = CGRect(origin: .zero, size: size)
        let transform = image.displayTransform(in: rect)
        let isTransposed = transposedOrientations.contains(image.imageOrientation)
        return try draw(cgImage, transform: transform, isTransposed: isTransposed)
    }

    @discardableResult
    public func nextPixelBuffer() throws -> CVPixelBuffer {
        pixelBuffer = nil

        try setupContextIfNeeded()
        guard let pixelBuffer = pixelBuffer else {
            throw Error.noPixelBuffer
        }

        return pixelBuffer
    }

    private func setupContextIfNeeded() throws {
        guard pixelBuffer == nil else {
            return
        }

        let width = Int(size.width)
        let height = Int(size.height)

        let surfaceProperties: [CFString: Any] = [
            kIOSurfaceWidth: width,
            kIOSurfaceHeight: height,
            kIOSurfaceBytesPerElement: bytesPerPixel,
            kIOSurfaceBytesPerRow: width * bytesPerPixel,
            kIOSurfaceAllocSize: width * height * bytesPerPixel,
            kIOSurfacePixelFormat: pixelFormat
        ]

        guard let surface = IOSurfaceCreate(surfaceProperties as CFDictionary) else {
            throw Error.noSurface
        }

        guard let context = CGContext(data: IOSurfaceGetBaseAddress(surface),
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: width * bytesPerPixel,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            throw Error.noContext
        }

        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0.0, y: -size.height)
        self.context = context

        let pixelBufferAttributes: [CFString: Any] = [
            kCVPixelBufferPixelFormatTypeKey: pixelFormat,
            kCVPixelBufferWidthKey: width,
            kCVPixelBufferHeightKey: height
        ]

        var pixelBuffer: Unmanaged<CVPixelBuffer>?
        CVPixelBufferCreateWithIOSurface(nil, surface, pixelBufferAttributes as CFDictionary, &pixelBuffer)
        self.pixelBuffer = pixelBuffer?.takeRetainedValue()
    }
}
