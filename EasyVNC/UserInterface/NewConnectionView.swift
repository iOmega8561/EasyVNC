//
//  ConnectionView.swift
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
            
            Text("EasyVNC")
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                Text("Connection Host")
                
                TextField("Host", text: $connection.host)
            }
            
            VStack(alignment: .leading) {
                Text("TCP Port")
                
                TextField("Port", value: $connection.port,
                                  formatter: NumberFormatter())
            }
            
            Button("Connect") {
                openWindow(id: "connection", value: connection)
                connection = .init()
                dismiss()
            }
            .disabled(!connection.isValid)
        }
        .padding()
    }
}
