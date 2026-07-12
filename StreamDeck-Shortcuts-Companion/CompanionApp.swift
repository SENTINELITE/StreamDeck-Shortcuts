//
//  CompanionApp.swift
//  StreamDeck-Shortcuts-Companion
//
//  Companion app that hosts App Intents and provides XPC communication
//  between Shortcuts.app and the StreamDeck plugin.
//

import AppIntents
import ServiceManagement
import SwiftUI

@main
struct StreamDeckShortcutsCompanionApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Menu bar only app - no main window
        Settings {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set up menu bar icon
        setupMenuBar()
        registerLaunchAgent()

        NSLog("StreamDeck Shortcuts Companion App launched")
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Using SF Symbol for now - replace with custom icon later
            button.image = NSImage(systemSymbolName: "slider.horizontal.3", accessibilityDescription: "StreamDeck Shortcuts")
        }
        
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "StreamDeck Shortcuts", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "About", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }

    private func registerLaunchAgent() {
        guard #available(macOS 13.0, *) else {
            NSLog("StreamDeck Shortcuts Companion: LaunchAgent registration requires macOS 13 or newer")
            return
        }
        let plistName = "com.FTRBND.streamdeck-shortcuts.agent"
        do {
            let service = try SMAppService.agent(plistName: plistName)
            try service.register()
            NSLog("StreamDeck Shortcuts Companion: Registered LaunchAgent \(plistName)")
        } catch let error as SMAppService.Status {
            switch error {
            case .enabled:
                NSLog("StreamDeck Shortcuts Companion: LaunchAgent \(plistName) already registered")
            case .notFound:
                NSLog("StreamDeck Shortcuts Companion: LaunchAgent plist \(plistName) not found")
            case .notRegistered:
                NSLog("StreamDeck Shortcuts Companion: LaunchAgent plist \(plistName) is invalid")
            case .requiresApproval:
                NSLog("StreamDeck Shortcuts Companion: Code signing invalid for LaunchAgent \(plistName)")
            default:
                NSLog("StreamDeck Shortcuts Companion: SMAppService error registering LaunchAgent \(plistName): \(error)")
            }
        } catch {
            NSLog("StreamDeck Shortcuts Companion: Failed to register LaunchAgent \(plistName): \(error.localizedDescription)")
        }
    }

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "StreamDeck Shortcuts Companion"
        alert.informativeText = "Version 2.0.0-beta.12\n\nProvides App Intents support for StreamDeck Shortcuts plugin."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
