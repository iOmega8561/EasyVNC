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
//  ClientLogView.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 03/12/25.
//

import SwiftUI

struct ClientLogView: View {
        
    @State private var handle: FileHandle?
    @State private var logLines: [String] = []
    
    var body: some View {
    
        ScrollView {
            VStack(alignment: .leading) {
                
                ForEach(logLines, id: \.self) { line in
                    Text(line)
                        .foregroundStyle(.white)
                }
            }
        }
        .padding()
        .background(.black.opacity(0.5))
        
        // Just to make this view a little flashy
        .clipShape(.rect(cornerRadius: 10.0))
        .overlay { RoundedRectangle(cornerRadius: 10.0)
                        .stroke(Color.accentColor.opacity(0.6),
                                style: .init(lineWidth: 3.0)) }
        
        // Second padding for text<->background spacing
        .padding()
        // Finally, log tasks
        .onAppear(perform: startReading)
        .onDisappear(perform: stopReading)
    }

    private func stopReading() {
        handle?.readabilityHandler = nil
        handle = nil
    }
    
    private func startReading() {
        
        guard let pipe = ClientLogger.shared().pipe else {
            return
        }
        
        let readHandle = pipe.fileHandleForReading
        self.handle = readHandle

        readHandle.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            
            guard !data.isEmpty,
                  let text = String(data: data, encoding: .utf8),
                  !text.isEmpty else { return }
            
            DispatchQueue.main.async { logLines.append(text) }
        }
    }
}
