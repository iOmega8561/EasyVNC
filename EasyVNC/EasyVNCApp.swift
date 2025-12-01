//
//  EasyVNCApp.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

@main
struct EasyVNCApp: App {
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        
        Window("New Connection", id: "main") {
            NewConnectionView()
                .frame(width: 300, height: 350)
        }
        .commands {
            CommandGroup(after: .windowArrangement) {
                Button("New Connection", systemImage: "plus") {
                    openWindow(id: "main")
                }
            }
        }
        .windowResizability(.contentSize)
        
        WindowGroup("EasyVNC Connection",
                    id: "connection",
                    for: Connection.self
        ) {
            ClientContainer(connection: $0.wrappedValue)
        }
        .commandsRemoved()
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
    }
}
