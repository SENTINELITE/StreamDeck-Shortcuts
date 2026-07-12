//
//  BridgeProtocol.swift
//  StreamDeck-Shortcuts-Shared
//
//  Swift XPC Protocol definitions for StreamDeck Shortcuts bridge
//

import Foundation

// MARK: - Service Interface (Companion -> Plugin)
public protocol StreamDeckBridgeService {
    /// Register a plugin with the service
    func registerPlugin(descriptor: PluginDescriptor) async throws -> Bool
    
    /// Unregister a plugin from the service
    func unregisterPlugin(contextID: String) async throws -> Bool
    
    /// Execute a shortcut on the specified plugin context
    func performShortcut(_ command: ShortcutCommand) async throws -> RunResult
    
    /// Update a key's display on the StreamDeck
    func updateKey(_ command: KeyUpdateCommand) async throws -> Bool
    
    /// Get current status of the plugin
    func getStatus(for contextID: String?) async throws -> StreamDeckStatus
    
    /// List all available contexts
    func listContexts() async throws -> [String]
}

// MARK: - Plugin Client Interface (Plugin -> Service callbacks)
public protocol StreamDeckBridgePluginClient {
    /// Run a shortcut command
    func runShortcut(_ command: ShortcutCommand) async throws -> RunResult
    
    /// Update a key's display
    func updateKey(_ command: KeyUpdateCommand) async throws -> Bool
    
    /// Get current plugin status
    func currentStatus() async throws -> StreamDeckStatus
    
    /// Notify when context becomes available/unavailable
    func contextDidChange(contextID: String, isAvailable: Bool) async
}

// MARK: - XPC Protocol (Objective-C surface for NSXPCConnection)
/// Objective-C compatible protocol vended over NSXPCConnection.
///
/// Methods use `Data` payloads so we can keep the rest of the codebase in Swift
/// with `Codable` models. See `StreamDeckXPCSerialization` for helpers.
@objc public protocol StreamDeck_Shortcuts_XPCProtocol {
    func registerPlugin(descriptorData: Data) async throws -> Bool
    func unregisterPlugin(contextID: String) async throws -> Bool
    func performShortcut(_ commandData: Data) async throws -> Data
    func updateKey(_ commandData: Data) async throws -> Bool
    func getStatus(contextID: String?) async throws -> Data
    func listContexts() async throws -> [String]
}
