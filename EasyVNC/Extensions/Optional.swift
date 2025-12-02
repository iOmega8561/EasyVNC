//
//  Optional.swift
//  EasyVNC
//
//  Created by Giuseppe Rocco on 01/12/25.
//

extension Optional where Wrapped == Connection {
    
    // Easy title unwrap when Connection is null
    var title: String {
        self?.title ?? .init(localized: "title-invalid-connection")
    }
}
