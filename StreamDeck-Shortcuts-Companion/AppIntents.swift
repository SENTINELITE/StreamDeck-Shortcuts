//
//  AppIntents.swift
//  StreamDeck-Shortcuts-Companion
//
//  App Intents that can be triggered from Shortcuts.app
//  These will communicate with the StreamDeck plugin via XPC
//

import AppIntents
import Foundation
import StreamDeck_Shortcuts_Shared

// MARK: - Update StreamDeck Key Intent

struct UpdateStreamDeckKey: AppIntent {
    static var title: LocalizedStringResource = "Update StreamDeck Key"
    
    static var description = IntentDescription(
        "Updates the displayed text on the specified StreamDeck Key"
    )
    
    @Parameter(title: "Text to Display")
    var text: String
    
    @Parameter(title: "Key Context (Optional)", description: "The specific key context ID")
    var context: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Update StreamDeck key with \(\.$text)")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        NSLog("AppIntent: UpdateStreamDeckKey called with text: \(text)")
        
        do {
            let success = try await XPCClient.shared.updateKey(
                contextID: context,
                text: text
            )
            
            if success {
                return .result(value: "Successfully updated StreamDeck key to: \(text)")
            } else {
                return .result(value: "Failed to update StreamDeck key")
            }
        } catch let error as StreamDeckBridgeError {
            NSLog("AppIntent Error: \(error.localizedDescription)")
            throw error
        } catch {
            NSLog("AppIntent Error: \(error.localizedDescription)")
            throw StreamDeckBridgeError.executionFailed(error.localizedDescription)
        }
    }
}

// MARK: - Run Shortcut on StreamDeck Intent

struct RunShortcutOnStreamDeck: AppIntent {
    static var title: LocalizedStringResource = "Run Shortcut on StreamDeck"
    
    static var description = IntentDescription(
        "Triggers a shortcut to run on a specific StreamDeck key"
    )
    
    @Parameter(title: "Shortcut Name")
    var shortcutName: String
    
    @Parameter(title: "Key Context", description: "The StreamDeck key context ID")
    var context: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Run \(\.$shortcutName) on StreamDeck key")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult {
        NSLog("AppIntent: RunShortcutOnStreamDeck called: \(shortcutName)")
        
        do {
            let result = try await XPCClient.shared.performShortcut(
                contextID: context,
                shortcutName: shortcutName
            )
            
            if result.success {
                NSLog("AppIntent: Shortcut executed successfully - \(result.message)")
                return .result()
            } else {
                NSLog("AppIntent: Shortcut execution failed - \(result.message)")
                throw StreamDeckBridgeError.executionFailed(result.message)
            }
        } catch let error as StreamDeckBridgeError {
            NSLog("AppIntent Error: \(error.localizedDescription)")
            throw error
        } catch {
            NSLog("AppIntent Error: \(error.localizedDescription)")
            throw StreamDeckBridgeError.executionFailed(error.localizedDescription)
        }
    }
}

// MARK: - Get StreamDeck Status Intent

struct GetStreamDeckStatus: AppIntent {
    static var title: LocalizedStringResource = "Get StreamDeck Status"
    
    static var description = IntentDescription(
        "Returns the current status of the StreamDeck plugin"
    )
    
    static var parameterSummary: some ParameterSummary {
        Summary("Get StreamDeck connection status")
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        NSLog("AppIntent: GetStreamDeckStatus called")
        
        do {
            let response = try await DistributedNotificationPoster.shared.requestResponse(
                command: DistributedBridgeNotification.Command.getStatus
            )

            let version = response.payload[DistributedBridgeNotification.Keys.version] ?? "Unknown"

            let statusText = "StreamDeck Version: \(version)"
            return .result(value: statusText)
        } catch DistributedNotificationError.timeout {
            NSLog("AppIntent: Distributed notification timed out waiting for status response.")
            return .result(value: "StreamDeck Status: Timed out waiting for plugin response.")
        } catch {
            NSLog("AppIntent Error: \(error.localizedDescription)")
            return .result(value: "StreamDeck Status: Error - \(error.localizedDescription)")
        }
    }
}

// MARK: - Legacy Intents (from your original extension)

struct ConvertUnixTimeToDate: AppIntent, CustomIntentMigratedAppIntent {
    static let intentClassName = "UnixTimeToDateIntent"
    
    static let title: LocalizedStringResource = "Convert Unix Time to Date"
    
    static let description = IntentDescription(
        """
        Returns the date for the input Unix time.
        
        Unix time (also known as Epoch time) is a system for describing a point in time — the number of seconds that have elapsed since the Unix epoch.
        """,
        categoryName: "Date"
    )
    
    @Parameter(title: "Unix Time", description: "Example: 1663178163", controlStyle: .field)
    var unixTime: Int
    
    static var parameterSummary: some ParameterSummary {
        Summary("Convert \(\.$unixTime) to a date")
    }
    
    func perform() async throws -> some IntentResult & ReturnsValue<Date> {
        .result(value: Date(timeIntervalSince1970: Double(unixTime)))
    }
}
