//
//  DistributedNotifications.swift
//  StreamDeck-Shortcuts-Shared
//
//  Shared helpers for communicating over NSDistributedNotificationCenter.
//

import Foundation

/// Constants used by the distributed notification bridge between the companion app and the plugin.
public enum DistributedBridgeNotification {
    /// Notification name used for commands that should be delivered to the StreamDeck plugin.
    public static let pluginCommandName = Notification.Name("com.FTRBND.streamdeck-shortcuts.command")

    /// Notification name used for responses emitted by the StreamDeck plugin.
    public static let pluginResponseName = Notification.Name("com.FTRBND.streamdeck-shortcuts.response")

    /// Object string used when the companion posts a notification.
    public static let companionObject = "StreamDeckShortcuts.Companion"

    /// Object string used when the plugin posts a notification (reserved for future use).
    public static let pluginObject = "StreamDeckShortcuts.Plugin"

    /// Well-known command identifiers that both the plugin and companion understand.
    public enum Command {
        public static let getStatus = "getStatus"
        public static let statusResponse = "statusResponse"
    }

    /// Keys used inside the distributed notification userInfo dictionary.
    public enum Keys {
        public static let command = "command"
        public static let contextID = "contextID"
        public static let payload = "payload"
        public static let timestamp = "timestamp"
        public static let requestIdentifier = "requestIdentifier"
        public static let version = "version"
    }
}

/// A lightweight payload wrapper that is safe to transfer through `NSDistributedNotificationCenter`.
public struct DistributedBridgeMessage: Sendable {
    public let command: String
    public let contextID: String?
    public let payload: [String: String]
    public let timestamp: Date
    public let requestIdentifier: UUID?

    public init(
        command: String,
        contextID: String? = nil,
        payload: [String: String] = [:],
        timestamp: Date = Date(),
        requestIdentifier: UUID? = nil
    ) {
        self.command = command
        self.contextID = contextID
        self.payload = payload
        self.timestamp = timestamp
        self.requestIdentifier = requestIdentifier
    }

    /// Build a payload from the distributed notification's `userInfo`.
    public init?(userInfo: [AnyHashable: Any]) {
        guard let command = userInfo[Keys.command] as? String else {
            return nil
        }

        let contextID = userInfo[Keys.contextID] as? String
        let payload = userInfo[Keys.payload] as? [String: String] ?? [:]

        let timestamp: Date
        if let date = userInfo[Keys.timestamp] as? Date {
            timestamp = date
        } else if let interval = userInfo[Keys.timestamp] as? TimeInterval {
            timestamp = Date(timeIntervalSince1970: interval)
        } else {
            timestamp = Date()
        }

        let requestIdentifier: UUID?
        if let uuidString = userInfo[Keys.requestIdentifier] as? String {
            requestIdentifier = UUID(uuidString: uuidString)
        } else {
            requestIdentifier = nil
        }

        self.init(
            command: command,
            contextID: contextID,
            payload: payload,
            timestamp: timestamp,
            requestIdentifier: requestIdentifier
        )
    }

    /// Dictionary representation that only uses property-list friendly types.
    public var userInfoRepresentation: [String: Any] {
        var info: [String: Any] = [
            Keys.command: command,
            Keys.timestamp: timestamp
        ]

        if let contextID {
            info[Keys.contextID] = contextID
        }

        if !payload.isEmpty {
            info[Keys.payload] = payload
        }

        if let requestIdentifier {
            info[Keys.requestIdentifier] = requestIdentifier.uuidString
        }

        return info
    }

    private enum Keys {
        static let command = DistributedBridgeNotification.Keys.command
        static let contextID = DistributedBridgeNotification.Keys.contextID
        static let payload = DistributedBridgeNotification.Keys.payload
        static let timestamp = DistributedBridgeNotification.Keys.timestamp
        static let requestIdentifier = DistributedBridgeNotification.Keys.requestIdentifier
    }
}
