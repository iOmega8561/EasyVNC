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
        
            .frame(minWidth: client.image.cgWidth,
                   minHeight: client.image.cgHeight)
        
            .aspectRatio(client.image.aspectRatio,
                         contentMode: .fit)
        
            .task { @MainActor in
                
                guard let connection else { dismiss(); return }
                
                client.connect(host: connection.host,
                               port: connection.port)
            }
        
            .onChange(of: client.isConnected) { !$0 ? dismiss() : () }
        
            .onDisappear { client.isConnected ? client.disconnect() : () }
    }
}
