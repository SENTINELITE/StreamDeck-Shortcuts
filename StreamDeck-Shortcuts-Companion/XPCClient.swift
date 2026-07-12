//
//  XPCClient.swift
//  StreamDeck-Shortcuts-Companion
//
//  XPC client wrapper for communicating with the StreamDeck bridge service
//

import Foundation
import OSLog
import StreamDeck_Shortcuts_Shared

/// Singleton client for communicating with the StreamDeck XPC bridge service
@MainActor
public class XPCClient {
    
    // MARK: - Singleton
    
    public static let shared = XPCClient()
    
    // MARK: - Properties
    
    private var connection: NSXPCConnection?
    private let logger = Logger(subsystem: "com.FTRBND.streamdeck-shortcuts", category: "XPCClient")
    
    private init() {
        logger.info("XPCClient initialized")
    }
    
    // MARK: - Connection Management
    
    /// Get or create the XPC connection
    private func getConnection() -> NSXPCConnection {
        if let connection = connection {
            return connection
        }
        
        logger.info("Creating new XPC connection to service: \(XPCConstants.serviceName)")
        
        let newConnection = NSXPCConnection(serviceName: XPCConstants.serviceName)
        newConnection.remoteObjectInterface = NSXPCInterface(with: StreamDeck_Shortcuts_XPCProtocol.self)
        
        newConnection.invalidationHandler = { [weak self] in
            self?.logger.info("XPC connection invalidated")
            self?.connection = nil
        }
        
        newConnection.interruptionHandler = { [weak self] in
            self?.logger.warning("XPC connection interrupted")
            self?.connection = nil
        }
        
        newConnection.resume()
        self.connection = newConnection
        
        logger.info("XPC connection established")
        return newConnection
    }
    
    /// Get the remote ObjC-compatible service proxy
    private func getRemoteService() throws -> StreamDeck_Shortcuts_XPCProtocol {
        let connection = getConnection()
        
        guard let service = connection.remoteObjectProxy as? StreamDeck_Shortcuts_XPCProtocol else {
            logger.error("Failed to get remote object proxy")
            throw StreamDeckBridgeError.serviceUnavailable
        }
        
        return service
    }
    
    /// Invalidate the current connection
    public func disconnect() {
        logger.info("Disconnecting XPC connection")
        connection?.invalidate()
        connection = nil
    }
    
    // MARK: - Public API Methods
    
    /// Register a plugin with the bridge service
    public func registerPlugin(descriptor: PluginDescriptor) async throws -> Bool {
        logger.info("Registering plugin with \(descriptor.activeContexts.count) contexts")
        
        let service = try getRemoteService()
        let payload = try encodePayload(descriptor, label: "plugin descriptor")
        return try await service.registerPlugin(descriptorData: payload)
    }
    
    /// Unregister a plugin from the bridge service
    public func unregisterPlugin(contextID: String) async throws -> Bool {
        logger.info("Unregistering plugin for context: \(contextID)")
        
        let service = try getRemoteService()
        return try await service.unregisterPlugin(contextID: contextID)
    }
    
    /// Execute a shortcut on the specified StreamDeck context
    public func performShortcut(contextID: String, shortcutName: String, shortcutUUID: UUID? = nil) async throws -> RunResult {
        logger.info("Performing shortcut: \(shortcutName) on context: \(contextID)")
        
        let command = ShortcutCommand(
            contextID: contextID,
            shortcutName: shortcutName,
            shortcutUUID: shortcutUUID
        )
        
        let service = try getRemoteService()
        
        return try await withTimeout(seconds: XPCConstants.commandTimeout) {
            let payload = try self.encodePayload(command, label: "shortcut command")
            let data = try await service.performShortcut(payload)
            return try self.decodePayload(RunResult.self, from: data, label: "run result")
        }
    }
    
    /// Update a key's display text on the StreamDeck
    public func updateKey(contextID: String? = nil, text: String, image: Data? = nil) async throws -> Bool {
        logger.info("Updating key with text: \(text), context: \(contextID ?? "all")")
        
        let command = KeyUpdateCommand(
            contextID: contextID,
            text: text,
            image: image
        )
        
        let service = try getRemoteService()
        
        return try await withTimeout(seconds: XPCConstants.commandTimeout) {
            let payload = try self.encodePayload(command, label: "key update command")
            return try await service.updateKey(payload)
        }
    }
    
    /// Get the current status of the StreamDeck plugin
    public func getStatus(for contextID: String? = nil) async throws -> StreamDeckStatus {
        logger.info("Getting status for context: \(contextID ?? "all")")
        
        let service = try getRemoteService()
        
        return try await withTimeout(seconds: XPCConstants.connectionTimeout) {
            let data = try await service.getStatus(contextID: contextID)
            return try self.decodePayload(StreamDeckStatus.self, from: data, label: "status response")
        }
    }   
    
    /// List all available StreamDeck contexts
    public func listContexts() async throws -> [String] {
        logger.info("Listing all contexts")
        
        let service = try getRemoteService()
        
        return try await withTimeout(seconds: XPCConstants.connectionTimeout) {
            try await service.listContexts()
        }
    }
    
    // MARK: - Helper Methods
    
    /// Execute an async operation with a timeout
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // Add the actual operation
            group.addTask {
                try await operation()
            }
            
            // Add a timeout task
            group.addTask {
                try await Task.sleep(for: .seconds(seconds))
                throw StreamDeckBridgeError.connectionTimeout
            }
            
            // Return the first result (either success or timeout)
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    private func encodePayload<T: Encodable>(_ value: T, label: String) throws -> Data {
        do {
            return try StreamDeckXPCSerialization.encode(value)
        } catch {
            logger.error("Failed to encode \(label, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw StreamDeckBridgeError.invalidCommand("Unable to encode \(label): \(error.localizedDescription)")
        }
    }
    
    private func decodePayload<T: Decodable>(_ type: T.Type, from data: Data, label: String) throws -> T {
        do {
            return try StreamDeckXPCSerialization.decode(type, from: data)
        } catch {
            logger.error("Failed to decode \(label, privacy: .public): \(error.localizedDescription, privacy: .public)")
            throw StreamDeckBridgeError.invalidCommand("Unable to decode \(label): \(error.localizedDescription)")
        }
    }
}
