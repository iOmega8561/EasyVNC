//
//  Copyright (C) 2025  Giuseppe Rocco
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
//  ----------------------------------------------------------------------
//
//  ViewModel.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import Foundation
import SwiftUI

@MainActor
final class ViewModel: NSObject, ObservableObject {
    
    private let client: ClientWrapper = .init()

    @Published
    var image: CGImage = .defaultImage
    
    @Published
    var isConnected: Bool = false
    
    func disconnect() { client.cleanupDisconnect() }

    func connect(_ connection: Connection) {
                
        client.delegate = self

        client.initiateConnection(with: .init(
            host: connection.host,
            port: connection.port,
            username: connection.username,
            password: connection.password
        ))
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

nonisolated extension ViewModel: ClientDelegate {
    
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
        guard let provider = unsafe CGDataProvider(
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
