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
//  EasyVNCApp.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import Tools4SwiftUI

@main
struct EasyVNCApp: App {
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some Scene {
        
        Window("window-main-title", id: "main") {
            NewConnectionView()
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
                .windowPresentation(
                    [.autoHideToolbar, .autoHideMenuBar, .fullScreen],
                    tabbingMode: .disallowed,
                    backgroundColor: .black
                )
        }
        .commandsRemoved()
        .windowResizability(.contentSize)
        .windowToolbarStyle(.unifiedCompact)
    }
}
