//
//  ClientRepresentable.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

struct ClientRepresentable: NSViewRepresentable {
    
    @ObservedObject var client: ViewModel

    func makeNSView(context: Context) -> ClientView {
        let view = ClientView()
        view.client = client
        return view
    }

    func updateNSView(_ nsView: ClientView, context: Context) {
        nsView.image = client.image
    }
}
