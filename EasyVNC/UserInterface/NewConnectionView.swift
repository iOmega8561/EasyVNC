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
//  NewConnectionView.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

struct NewConnectionView: View {
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismiss) private var dismiss
    
    @State private var connection: Connection = .init()
    
    var body: some View {
        
        VStack(spacing: 40) {
            
            Text(verbatim: "EasyVNC")
                .font(.custom("ArialNarrow-BoldItalic", size: 42))
            
            Form {
                Section("title-connection-section") {
                    TextField("title-connection-host",
                              text: $connection.host,
                              prompt: .init("placeholder-connection-host"))
               
                    TextField("title-connection-port",
                              value: $connection.port,
                              formatter: NumberFormatter())
                    .padding(.bottom)
                }
            
                Section("title-authentication-section") {
                    TextField("title-authentication-username",
                              text: $connection.username,
                              prompt: .init("placeholder-authentication-username"))
               
                    TextField("title-authentication-password",
                              text: $connection.password,
                              prompt: .init("placeholder-authentication-password"))
                }
                .disabled(!connection.mustAuth)
                .opacity(connection.mustAuth ? 1 : 0.5)
            }
            
            HStack {
                Toggle("action-auth-toggle",
                       systemImage: "key",
                       isOn: $connection.mustAuth)
                .labelStyle(.iconOnly)
                .imageScale(.small)
                .toggleStyle(.button)
                
                Spacer()
                
                Button("action-connect",
                       systemImage: "app.connected.to.app.below.fill") {
                    openWindow(id: "connection",
                               value: connection)
                    connection = .init()
                    dismiss()
                }
                .labelStyle(.titleAndIcon)
                .imageScale(.medium)
                .disabled(!connection.isValid)
            }
        }
        .padding()
        .frame(width: 325, height: 375)
    }
}
