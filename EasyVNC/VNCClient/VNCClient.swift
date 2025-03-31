//
//  VNCClient.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import Foundation
import SwiftUI

final class VNCClient: NSObject, ObservableObject {
    
    private let wrapper = VNCClientWrapper()

    @Published var image: CGImage?

    override init() {
        super.init()
        
        wrapper.delegate = self
    }

    func connect(host: String, port: Int) async -> Bool {
        await wrapper.connect(toHost: host, port: Int32(port))
    }

    func sendMouse(x: Int, y: Int, buttons: Int) {
        wrapper.sendPointerEventWith(x: Int32(x), y: Int32(y), buttonMask: Int32(buttons))
    }

    func sendKey(key: Int, down: Bool) {
        wrapper.sendKeyEvent(Int32(key), down: down)
    }

    func disconnect() {
        wrapper.disconnect()
    }
}

extension VNCClient: VNCClientDelegate {
    
    func didUpdateFramebuffer(_ data: UnsafePointer<UInt8>, width: Int32, height: Int32, stride: Int32) {
                        
        guard let provider = CGDataProvider(
            dataInfo: nil,
            data: data,
            size: Int(stride * height),
            releaseData: { _,_,_ in }
        ) else { return }
                
        let bitmapInfo: CGBitmapInfo = [
            .byteOrderDefault,
            CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue)
        ]
        
        let cgImage = CGImage(
            width: Int(width),
            height: Int(height),
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: Int(stride),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        
        DispatchQueue.main.async { self.image = cgImage }
    }
}
