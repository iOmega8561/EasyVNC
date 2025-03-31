//
//  EasyVNCApp.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

@main
struct EasyVNCApp: App {
    
    var body: some Scene {
        
        WindowGroup(id: "main") {
            ConnectionView()
                .frame(width: 300, height: 350)
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: "connection", for: Connection.self) { $conn in
            ContentView(connection: conn)
        }
        .windowResizability(.contentSize)
    }
}
