//
//  ContentView.swift
//  VNCViewer
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var client = VNCClient()
    
    @State private var isConnected = false

    var body: some View {
        VStack {
            VNCDisplayRepresentable(client: client)
                .frame(minWidth: 640, minHeight: 480)

            HStack {
                Button("Connect") {
                    if !isConnected {
                        client.connect(host: "192.168.0.100", port: 5900)
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
