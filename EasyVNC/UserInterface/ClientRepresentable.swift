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
//  ClientRepresentable.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import SwiftUI

struct ClientRepresentable: NSViewRepresentable {
    
    @State private var toolbarHeight: CGFloat? = nil
    
    @ObservedObject var client: ViewModel

    private func getToolbarHeight(_ nsView: ClientView) {
        guard let totalWindowHeight = unsafe nsView.window?.frame.height else {
            return
        }
        self.toolbarHeight = totalWindowHeight - nsView.frame.height
    }
    
    private func setAspectRatio(_ nsView: ClientView) {
        guard let toolbarHeight else {
            return DispatchQueue.main.async { getToolbarHeight(nsView) }
        }
        unsafe nsView.window?.aspectRatio = NSSizeFromCGSize(
            .init(width: nsView.frame.width, height: nsView.frame.height + toolbarHeight)
        )
    }
    
    func makeNSView(context: Context) -> ClientView {
        let view = ClientView()
        view.client = client
        return view
    }

    func updateNSView(_ nsView: ClientView, context: Context) {
        nsView.image = client.image
        setAspectRatio(nsView)
    }
}
