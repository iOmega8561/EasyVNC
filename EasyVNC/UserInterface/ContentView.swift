//
//  ContentView.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var client = VNCClient()
    
    @State private var isConnected = false

    private var aspectRatio: CGFloat {
        guard let image = client.image else {
            return 1
        }
        
        let width  = CGFloat(image.width)
        let height = CGFloat(image.height)
        
        return width / height
    }
    
    var body: some View {
        
        VStack {
            
            VNCDisplayRepresentable(client: client)
                .aspectRatio(aspectRatio, contentMode: .fit)
            
            HStack {
                Button("Connect") {
                    if !isConnected {
                        client.connect(host: "127.0.0.1", port: 5901)
                        isConnected = true
                    }
                }
                Button("Disconnect") {
                    client.disconnect()
                    isConnected = false
                }
            }
            .padding()
        }
    }
}
