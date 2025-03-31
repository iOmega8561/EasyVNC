//
//  VNCDisplayRepresentable.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

struct VNCDisplayRepresentable: NSViewRepresentable {
    @ObservedObject var client: VNCClient

    func makeNSView(context: Context) -> VNCDisplayView {
        let view = VNCDisplayView()
        view.client = client
        return view
    }

    func updateNSView(_ nsView: VNCDisplayView, context: Context) {
        nsView.image = client.image
    }
}
