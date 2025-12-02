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
        
        Window("window-main-title", id: "main") {
            NewConnectionView()
                .frame(width: 300, height: 350)
        }
        .commands {
            CommandGroup(after: .windowArrangement) {
                Button("title-new-connection", systemImage: "plus") {
                    openWindow(id: "main")
                }
                .keyboardShortcut("N", modifiers: .command)
            }
        }
        .windowResizability(.contentSize)
        
        WindowGroup("window-connection-title",
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
