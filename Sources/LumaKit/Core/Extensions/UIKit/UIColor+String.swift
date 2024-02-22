//
//  Copyright © 2024 Luma AI. All rights reserved.
//

import UIKit

public extension UIColor {
    enum CodingColorSpace: String {
        case srgb
        case p3
    }

    var stringRepresentation: String {
        let components: [CGFloat]
        let codingColorSpace: CodingColorSpace
        if let colorSpace = CGColorSpace(name: CGColorSpace.displayP3),
           let p3Components = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil)?.components {
            components = p3Components
            codingColorSpace = .p3
        }
        else if let srgbComponents = cgColor.components {
            components = srgbComponents
            codingColorSpace = .srgb
        }
        else {
            return .init()
        }

        var result = ""
        result.append(codingColorSpace.rawValue)
        result.append("#")
        result.append(makeHexRepresentation(for: components))
        return result
    }

    convenience init?(string: String) {
        var string: String = string.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if string.hasPrefix("#") {
            string.remove(at: string.startIndex)
        }

        let scanner = Scanner(string: string)
        var colorSpace: CodingColorSpace = .p3
        if string.contains("#"),
           let colorSpaceString = scanner.scanUpToCharacters(from: .init(charactersIn: "#")) {
            colorSpace = .init(rawValue: colorSpaceString) ?? colorSpace
            _ = scanner.scanCharacter()
        }

        var value: UInt64 = 0
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0
        scanner.scanHexInt64(&value)

        switch string.count {
        case 2:
            let white = CGFloat((value & 0xFF00) >> 8) / 255.0
            let alpha = CGFloat((value & 0x00FF) >> 0) / 255.0
            self.init(white: white, alpha: alpha)
            return
        case 3:
            r = CGFloat((value & 0x000F00) >> 8) / 16.0
            g = CGFloat((value & 0x0000F0) >> 4) / 16.0
            b = CGFloat((value & 0x00000F) >> 0) / 16.0
        case 6:
            r = CGFloat((value & 0xFF0000) >> 16) / 255.0
            g = CGFloat((value & 0x00FF00) >> 8) / 255.0
            b = CGFloat((value & 0x0000FF) >> 0) / 255.0
        case 8:
            r = CGFloat((value & 0xFF000000) >> 24) / 255.0
            g = CGFloat((value & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((value & 0x0000FF00) >> 8) / 255.0
            a = CGFloat((value & 0x000000FF) >> 0) / 255.0
        default:
            return nil
        }

        switch colorSpace {
        case .srgb:
            self.init(red: r, green: g, blue: b, alpha: a)
        case .p3:
            self.init(displayP3Red: r, green: g, blue: b, alpha: a)
        }
    }

    private func makeHexRepresentation(for components: [CGFloat]) -> String {
        var result: String = .init()
        for component in components {
            let value = UInt8(component * 255)
            result += String(format: "%02lX", value)
        }
        return result
    }
}

