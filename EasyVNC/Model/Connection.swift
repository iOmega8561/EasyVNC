//
//  Connection.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 31/03/25.
//

struct Connection: Codable, Hashable {
    
    var host: String = "localhost"
    var port: Int = 5900
    
    var isValid: Bool { host.count == 0 || port < 1024 }
}
