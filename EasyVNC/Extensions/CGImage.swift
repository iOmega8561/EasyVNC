//
//  CGImage.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 29/11/25.
//

import CoreGraphics

extension CGImage {
    
    static let defaultImage: CGImage = {
        let width  = 800
        let height = 600

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            fatalError("Cannot create CGContext")
        }

        context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))

        guard let image = context.makeImage() else {
            fatalError("Cannot generate CGImage from CGContext")
        }

        return image
    }()
    
    
    var cgWidth: CGFloat { .init(self.width) }
    
    var cgHeight: CGFloat { .init(self.height) }
    
    var aspectRatio: CGFloat { cgWidth / cgHeight }
}
