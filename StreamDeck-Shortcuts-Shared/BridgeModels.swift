//
//  BridgeModels.swift
//  StreamDeck-Shortcuts-Shared
//
//  Shared data models for StreamDeck Shortcuts XPC bridge
//

import Foundation

// MARK: - Commands
public struct ShortcutCommand: Codable, Sendable {
    public let contextID: String
    public let shortcutName: String
    public let shortcutUUID: UUID?
    
    public init(contextID: String, shortcutName: String, shortcutUUID: UUID? = nil) {
        self.contextID = contextID
        self.shortcutName = shortcutName
        self.shortcutUUID = shortcutUUID
    }
}

public struct KeyUpdateCommand: Codable, Sendable {
    public let contextID: String?
    public let text: String
    public let image: Data?
    
    public init(contextID: String? = nil, text: String, image: Data? = nil) {
        self.contextID = contextID
        self.text = text
        self.image = image
    }
}

// MARK: - Results
public struct RunResult: Codable, Sendable {
    public let success: Bool
    public let message: String
    public let executionTime: TimeInterval?
    
    public init(success: Bool, message: String, executionTime: TimeInterval? = nil) {
        self.success = success
        self.message = message
        self.executionTime = executionTime
    }
}

// MARK: - Status and Descriptors
public struct StreamDeckStatus: Codable, Sendable {
    public let isConnected: Bool
    public let activeContexts: [String]
    public let lastCommand: String?
    public let lastCommandTime: Date?
    public let version: String
    
    public init(
        isConnected: Bool,
        activeContexts: [String] = [],
        lastCommand: String? = nil,
        lastCommandTime: Date? = nil,
        version: String
    ) {
        self.isConnected = isConnected
        self.activeContexts = activeContexts
        self.lastCommand = lastCommand
        self.lastCommandTime = lastCommandTime
        self.version = version
    }
}

public struct PluginDescriptor: Codable, Sendable {
    public let version: String
    public let supportedActions: [String]
    public let activeContexts: [String]
    
    public init(version: String, supportedActions: [String], activeContexts: [String]) {
        self.version = version
        self.supportedActions = supportedActions
        self.activeContexts = activeContexts
    }
}

// MARK: - Errors
public enum StreamDeckBridgeError: Error, LocalizedError, Codable, Sendable {
    case pluginUnavailable
    case contextNotFound(String)
    case shortcutNotFound(String)
    case executionFailed(String)
    case connectionTimeout
    case invalidCommand(String)
    case serviceUnavailable
    
    public var errorDescription: String? {
        switch self {
        case .pluginUnavailable:
            return "StreamDeck plugin is not available. Please ensure the StreamDeck app is running and the plugin is loaded."
        case .contextNotFound(let context):
            return "StreamDeck context '\(context)' was not found."
        case .shortcutNotFound(let shortcut):
            return "Shortcut '\(shortcut)' was not found."
        case .executionFailed(let reason):
            return "Command execution failed: \(reason)"
        case .connectionTimeout:
            return "Connection to StreamDeck plugin timed out."
        case .invalidCommand(let reason):
            return "Invalid command: \(reason)"
        case .serviceUnavailable:
            return "StreamDeck bridge service is unavailable. Please ensure the companion app is running."
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .pluginUnavailable, .serviceUnavailable:
            return "Try launching the StreamDeck Shortcuts Companion app and ensure the StreamDeck app is running."
        case .connectionTimeout:
            return "Check your StreamDeck connection and try again."
        case .contextNotFound, .shortcutNotFound:
            return "Verify the StreamDeck key is properly configured with a valid shortcut."
        case .executionFailed, .invalidCommand:
            return "Check the shortcut configuration and try again."
        }
    }
}

// MARK: - XPC Service Constants
public enum XPCConstants {
    public static let serviceName = "com.FTRBND.streamdeck-shortcuts.xpc.StreamDeck-Shortcuts-XPC"
    public static let connectionTimeout: TimeInterval = 5.0
    public static let commandTimeout: TimeInterval = 10.0
}