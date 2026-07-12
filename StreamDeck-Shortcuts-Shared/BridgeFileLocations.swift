//
//  BridgeFileLocations.swift
//  StreamDeck-Shortcuts-Shared
//
//  Shared filesystem locations used by the plugin and companion app.
//

import Foundation

public enum BridgeFileLocations {
    /// Directory under the user's Application Support folder where bridge artifacts are stored.
    public static var supportDirectory: URL {
        let base = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Application Support", isDirectory: true)
        return base.appendingPathComponent("StreamDeck-Shortcuts", isDirectory: true)
    }
    
    /// File path where the anonymous XPC listener endpoint is stored.
    public static var endpointFileURL: URL {
        supportDirectory.appendingPathComponent("anonymous-xpc-endpoint")
    }
}
