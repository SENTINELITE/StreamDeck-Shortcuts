//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation
import Sentry

//  🔷----------------------------------------------------- --------------------------------------------------
//  | Runs the specified shortcut. TODO: Drop support for Applescript, & use the Shortcuts CLI excluseivly.  |
//  ----------------------------------------------------- ----------------------------------------------------



//MARK: Shortcut Runner | Fix thanks to  Apple's DTS Team! 🎉
//TODO: Make Task?

func runShortcutDTS(inputShortcut: String) async {
    NSLog("Running with DTS Fix...")
    let shortcutsCLI = Process()
    shortcutsCLI.standardInput = nil //TODO: DTS Fix. This allows us to run the Shortcut!!!
    
    shortcutsCLI.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
//    let xo = #"inputShortcut"#
    shortcutsCLI.arguments = ["run", "\(inputShortcut)"]
    
    do {
        try shortcutsCLI.run()
    } catch {
        NSLog("\(error)")
        SentrySDK.capture(error: error)
    }
    NSLog("Should've ran the shortcut...")
}



//  🔷---------------------------------------------------- -----------------------------------
//  | AccessFeature: Speaks the name of the shortcut, when the user presses down on that key |
//  ----------------------------------------------------- ------------------------------------

func shellTest(_ args: String...) async -> Int32 {
    let sayCLI = Process()
    sayCLI.executableURL = URL(fileURLWithPath: "/usr/bin/say")
    sayCLI.arguments = args
    sayCLI.launch()
    sayCLI.waitUntilExit()
    NSLog("Finshed running With:  \(args)")
    
    return sayCLI.terminationStatus
}
