//
//  ContentView.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

struct ContentView: View {
    
    let connection: Connection?
    
    @StateObject private var client = ViewModel()
        
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        
        ClientRepresentable(client: client)
            
            // min frame is always like client's frame
            // max frame is locked when disconnected, otherwise can be resized.
            .frame(minWidth: client.image.cgWidth,
                   maxWidth: client.isConnected ? nil : client.image.cgWidth,
                   minHeight: client.image.cgHeight,
                   maxHeight: client.isConnected ? nil : client.image.cgHeight)
            
            // always fit, we don't like streched views
            .aspectRatio(client.image.aspectRatio,
                         contentMode: .fit)
            
            .task { @MainActor in
                
                guard let connection else { dismiss(); return }
                
                client.connect(host: connection.host,
                               port: connection.port)
            }
            
            // For now, dismiss on disconnect. Will change.
            .onChange(of: client.isConnected) { !$0 ? dismiss() : () }
            // Avoid leaving connection in a broken state when disappearing
            .onDisappear { client.isConnected ? client.disconnect() : () }
    }
}
