//
//  DistributedNotificationListener.swift
//  StreamDeck-Shortcuts
//
//  Lightweight helper for receiving commands from the companion app via
//  `NSDistributedNotificationCenter`.
//

import Foundation
import StreamDeck_Shortcuts_Shared

/// Listens for distributed notifications posted by the companion app and forwards them to the plugin.
final class DistributedNotificationListener {
    static let shared = DistributedNotificationListener()

    private let center: DistributedNotificationCenter
    private let lock = NSLock()
    private var observer: NSObjectProtocol?

    init(center: DistributedNotificationCenter = .default()) {
        self.center = center
    }

    deinit {
        stopListening()
    }

    /// Start listening for incoming commands from the companion app.
    /// - Parameters:
    ///   - queue: Optional queue for delivering callbacks. Defaults to the posting thread.
    ///   - handler: Callback invoked whenever a valid command payload is received.
    func startListening(
        queue: OperationQueue? = nil,
        handler: @escaping (DistributedBridgeMessage) -> Void
    ) {
        lock.lock()
        defer { lock.unlock() }

        stopListeningLocked()

        observer = center.addObserver(
            forName: DistributedBridgeNotification.pluginCommandName,
            object: DistributedBridgeNotification.companionObject,
            queue: queue
        ) { notification in
            guard let userInfo = notification.userInfo,
                  let message = DistributedBridgeMessage(userInfo: userInfo) else {
                NSLog("DistributedNotificationListener: Dropped malformed payload: \(String(describing: notification.userInfo))")
                return
            }

            handler(message)
        }
    }

    /// Stop listening for distributed notifications.
    func stopListening() {
        lock.lock()
        stopListeningLocked()
        lock.unlock()
    }

    private func stopListeningLocked() {
        if let observer {
            center.removeObserver(observer)
            self.observer = nil
        }
    }
}
