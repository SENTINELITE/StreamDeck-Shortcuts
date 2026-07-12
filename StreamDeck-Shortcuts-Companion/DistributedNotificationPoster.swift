//
//  DistributedNotificationPoster.swift
//  StreamDeck-Shortcuts-Companion
//
//  Convenience wrapper for sending commands to the plugin through
//  `NSDistributedNotificationCenter`.
//

import Foundation
import OSLog
import StreamDeck_Shortcuts_Shared

/// Posts fire-and-forget commands to the StreamDeck plugin using distributed notifications.
public final class DistributedNotificationPoster {
    public static let shared = DistributedNotificationPoster()

    private let center: DistributedNotificationCenter
    private let logger = Logger(subsystem: "com.FTRBND.streamdeck-shortcuts", category: "DistributedNotifications")

    public init(center: DistributedNotificationCenter = .default()) {
        self.center = center
    }

    /// Post a message to the plugin.
    /// - Parameters:
    ///   - message: Payload describing the command to execute.
    ///   - deliverImmediately: Pass `true` to ask the system to deliver the notification without queueing.
    public func post(
        _ message: DistributedBridgeMessage,
        deliverImmediately: Bool = true
    ) {
        let userInfo = message.userInfoRepresentation
        logger.debug("Posting distributed command '\(message.command, privacy: .public)' to plugin")

        center.postNotificationName(
            DistributedBridgeNotification.pluginCommandName,
            object: DistributedBridgeNotification.companionObject,
            userInfo: userInfo,
            deliverImmediately: deliverImmediately
        )
    }

    /// Send a command and wait for a single response from the plugin.
    /// - Parameters:
    ///   - command: Command identifier to send.
    ///   - payload: Optional payload dictionary.
    ///   - timeout: Seconds to wait before timing out.
    /// - Returns: The response message produced by the plugin.
    public func requestResponse(
        command: String,
        payload: [String: String] = [:],
        timeout: TimeInterval = 3.0
    ) async throws -> DistributedBridgeMessage {
        let requestID = UUID()
        let message = DistributedBridgeMessage(
            command: command,
            payload: payload,
            requestIdentifier: requestID
        )

        return try await withCheckedThrowingContinuation { continuation in
            let coordinationLock = NSLock()
            var didResolve = false
            var observer: NSObjectProtocol?
            var timeoutWorkItem: DispatchWorkItem?

            func finish(_ result: Result<DistributedBridgeMessage, Error>) {
                coordinationLock.lock()
                defer { coordinationLock.unlock() }

                guard !didResolve else { return }
                didResolve = true

                if let observer {
                    center.removeObserver(observer)
                }

                timeoutWorkItem?.cancel()
                continuation.resume(with: result)
            }

            observer = center.addObserver(
                forName: DistributedBridgeNotification.pluginResponseName,
                object: DistributedBridgeNotification.pluginObject,
                queue: nil
            ) { notification in
                guard
                    let userInfo = notification.userInfo,
                    let response = DistributedBridgeMessage(userInfo: userInfo),
                    response.requestIdentifier == requestID
                else {
                    return
                }

                self.logger.debug("Received distributed response '\(response.command, privacy: .public)' for request \(requestID.uuidString, privacy: .public)")
                finish(.success(response))
            }

            let deadline = DispatchTime.now() + timeout
            let workItem = DispatchWorkItem {
                coordinationLock.lock()
                let alreadyResolved = didResolve
                coordinationLock.unlock()

                if alreadyResolved {
                    return
                }

                self.logger.error("Timed out waiting for distributed response to command '\(command, privacy: .public)'")
                finish(.failure(DistributedNotificationError.timeout))
            }
            timeoutWorkItem = workItem
            DispatchQueue.global().asyncAfter(deadline: deadline, execute: workItem)

            logger.debug("Posting distributed request '\(command, privacy: .public)' with ID \(requestID.uuidString, privacy: .public)")
            center.postNotificationName(
                DistributedBridgeNotification.pluginCommandName,
                object: DistributedBridgeNotification.companionObject,
                userInfo: message.userInfoRepresentation,
                deliverImmediately: true
            )
        }
    }
}

/// Errors thrown by the distributed notification helper.
public enum DistributedNotificationError: Error {
    case timeout
}
