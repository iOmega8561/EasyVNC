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
        
        VStack(spacing: 48) {
            
            Text(verbatim: "EasyVNC")
                .font(.custom("ArialNarrow-BoldItalic", size: 42))
            
            VStack(alignment: .leading) {
                Text("title-connection-host")
                
                TextField("placeholder-connection-host",
                          text: $connection.host)
            }
            
            VStack(alignment: .leading) {
                Text("title-connection-port")
                
                TextField("placeholder-connection-port",
                          value: $connection.port,
                          formatter: NumberFormatter())
            }
            
            Button("action-connect") {
                openWindow(id: "connection",
                           value: connection)
                connection = .init()
                dismiss()
            }
            .disabled(!connection.isValid)
        }
        .padding()        
    }
}
