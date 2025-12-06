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
    
    // Stores the height of the window toolbar/titlebar
    @State private var toolbarHeight: CGFloat? = nil
    
    // View model driving the content of the ClientView
    @ObservedObject var client: ViewModel

    // Calculates the toolbar height by subtracting the content height
    // from the full window frame height
    private func getToolbarHeight(_ nsView: ClientView) {
        guard let totalWindowHeight = unsafe nsView.window?.frame.height else {
            return
        }
        self.toolbarHeight = totalWindowHeight - nsView.frame.height
    }
    
    // Sets the window aspect ratio based on the content size
    // plus the previously measured toolbar height
    private func setAspectRatio(_ nsView: ClientView) {
        guard let toolbarHeight else {
            // If the toolbar height is not known yet, compute it on the next runloop
            return DispatchQueue.main.async { getToolbarHeight(nsView) }
        }
        unsafe nsView.window?.aspectRatio = NSSizeFromCGSize(
            .init(width: nsView.frame.width, height: nsView.frame.height + toolbarHeight)
        )
    }
    
    // Creates the underlying AppKit view and injects the view model
    func makeNSView(context: Context) -> ClientView {
        let view = ClientView()
        view.client = client
        return view
    }

    // Updates the AppKit view when SwiftUI state changes
    func updateNSView(_ nsView: ClientView, context: Context) {
        nsView.image = client.image
        setAspectRatio(nsView)
    }
}
