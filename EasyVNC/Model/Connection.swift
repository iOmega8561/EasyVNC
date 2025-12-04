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
//  Connection.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

import Foundation

struct Connection: Codable, Hashable {
    var host:     String = ""
    var port:     Int    = 5900
        
    var username: String = ""
    var password: String = ""
    
    var mustAuth: Bool   = false
    
    var isValid:  Bool {
        let connValid = !host.isEmpty && port > 1024
        
        if mustAuth {
            return !password.isEmpty &&
                   connValid
        }
        
        return connValid
    }
    
    var title: String { "\(host):\(port)" }
}
