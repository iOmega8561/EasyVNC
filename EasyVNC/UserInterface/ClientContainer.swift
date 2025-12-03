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
//  ClientContainer.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

struct ClientContainer: View {
    
    let connection: Connection?
    
    @StateObject private var client = ViewModel()
    
    @State private var showLogs: Bool = false
        
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
        
            // Distinguish connection windows using details as IP and PORT
            .navigationSubtitle(connection.title)
        
            .overlay(alignment: .topLeading) {
                ClientLogView()
                    .opacity((!client.isConnected || showLogs) ? 1 : 0)
            }
        
            .toolbar {
                ToolbarItem {
                    Toggle("action-log-toggle", systemImage: "apple.terminal",
                                                isOn: $showLogs)
                        .disabled(!client.isConnected)
                }
            }
    }
}
