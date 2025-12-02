//
//  ViewModel.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import Foundation
import SwiftUI

final class ViewModel: NSObject, ObservableObject {
    
    private let client: ClientWrapper = .init()

    @Published
    var image: CGImage = .defaultImage
    
    @Published
    var isConnected: Bool = false
    
    func disconnect() { client.cleanupDisconnect() }

    func connect(host: String, port: Int) {
        
        client.delegate = self
        
        client.connect(toHost: host,
                       port: Int32(port))
    }

    func sendKey(key: Int, down: Bool) {
        
        client.sendKeyEvent(Int32(key),
                            down: down)
    }
    
    func sendMouse(x: Int, y: Int, buttons: Int) {
        
        client.sendPointerEventWith(x: Int32(x),
                                    y: Int32(y),
                                    buttonMask: Int32(buttons))
    }
}

extension ViewModel: ClientDelegate {
    
    func handleConnectionStatusChange(_ isConnected: Bool) {
        DispatchQueue.main.async {
            self.isConnected = isConnected
        }
    }

    func didUpdateFramebuffer(_ data: UnsafePointer<UInt8>,
                              width: Int32,
                              height: Int32,
                              stride: Int32
    ) {
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
        
        if let cgImage = CGImage(
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
        ) {
            DispatchQueue.main.async { self.image = cgImage }
        }
    }
}
