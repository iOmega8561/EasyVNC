//
//  ContentView.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

struct ContentView: View {
    
    let connection: Connection?
    
    @StateObject private var client = VNCClient()
    
    @State private var isConnected = false
    
    @Environment(\.dismiss) private var dismiss
    
    private var screenWidth: CGFloat? {
        guard let image = client.image else {
            return nil
        }
        
        return .init(image.width)
    }
    
    private var screenHeight: CGFloat? {
        guard let image = client.image else {
            return nil
        }
        
        return .init(image.height)
    }
    
    private var aspectRatio: CGFloat {
        guard let screenWidth,
              let screenHeight else { return 1 }
        
        return screenWidth / screenHeight
    }
    
    var body: some View {
        
        VNCClientRepresentable(client: client)
            .frame(minWidth: screenWidth, minHeight: screenHeight)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .task { @MainActor in
                
                guard let connection,
                      await client.connect(host: connection.host,
                                           port: connection.port) else {
                    dismiss(); return
                }
                
                isConnected = true
            }
            .onDisappear { if isConnected { client.disconnect() } }
    }
}
