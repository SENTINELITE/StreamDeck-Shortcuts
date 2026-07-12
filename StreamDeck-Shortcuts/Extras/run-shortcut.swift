//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//
import Foundation

//import Sentry

//  🔷----------------------------------------------------- --------------------------------------------------
//  | Runs the specified shortcut. TODO: Drop support for Applescript, & use the Shortcuts CLI excluseivly.  |
//  ----------------------------------------------------- ----------------------------------------------------

//MARK: Shortcut Runner | Fix thanks to  Apple's DTS Team! 🎉
//TODO: Make Task?

///Spins up a seperate CLI process that executes a Shortcut.
/// - inputShortcut can be either a name or a UUID. UUID is the preferred method of running, though
func runShortcutDTS(inputShortcut: String) async {
    shortcutsLogger(message: "Running with DTS Fix...")
    let shortcutsCLI = Process()
    shortcutsCLI.standardInput = nil  //Note: DTS Fix. This allows us to run the Shortcut!!!
    
    shortcutsCLI.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
    shortcutsCLI.arguments = ["run", "\(inputShortcut)"]
    
    do {
        try shortcutsCLI.run()
    } catch {
        shortcutsLogger(message: "\(error)")
        //        SentrySDK.capture(error: error)
    }
    shortcutsLogger(message: "Should've ran the shortcut...")
}

//  🔷---------------------------------------------------- -----------------------------------
//  | AccessFeature: Speaks the name of the shortcut, when the user presses down on that key |
//  ----------------------------------------------------- ------------------------------------

//TODO: Return Term.Status?
///New SDS V2 Say CLI
func sayCLI(speak: String, speechRate: Int) async {
    Task.detached {
        let sayCLI = Process()
        sayCLI.executableURL = URL(fileURLWithPath: "/usr/bin/say")
        sayCLI.arguments = [speak, "-r", "\(speechRate)"]
        sayCLI.launch()
        sayCLI.waitUntilExit()
        shortcutsLogger(message: "Finished running With: \(sayCLI.arguments)")
    }
}

