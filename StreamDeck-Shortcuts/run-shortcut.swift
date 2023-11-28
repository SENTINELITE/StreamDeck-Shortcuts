//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation
import AVFoundation
import Sentry

//  🔷----------------------------------------------------- --------------------------------------------------
//  | Runs the specified shortcut. TODO: Drop support for Applescript, & use the Shortcuts CLI excluseivly.  |
//  ----------------------------------------------------- ----------------------------------------------------



//MARK: Shortcut Runner | Fix thanks to  Apple's DTS Team! 🎉
//TODO: Make Task?

///Spins up a seperate CLI process that executes a Shortcut.
/// - inputShortcut can be either a name or a UUID. UUID is the preferred method of running, though
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

@available(*, deprecated, message: "Use sayCLI instead!")
func shellTest(_ args: String...) async -> Int32 {
    let sayCLI = Process()
    sayCLI.executableURL = URL(fileURLWithPath: "/usr/bin/say")
    sayCLI.arguments = args
    sayCLI.launch()
    sayCLI.waitUntilExit()
    NSLog("Finshed running With:  \(args)")
    
    return sayCLI.terminationStatus
}

//TODO: Repport Term.Status?
///New SDS V2 Say CLI
func sayCLI(speak: String, speechRate: Int) async {
     Task.detached {
        let sayCLI = Process()
        sayCLI.executableURL = URL(fileURLWithPath: "/usr/bin/say")
        sayCLI.arguments = [speak, "-r", "\(speechRate)"]
        sayCLI.launch()
        sayCLI.waitUntilExit()
         NSLog("Finished running With: \(sayCLI.arguments)")
    }
}

//TODO: Pass Speed Parameter
var audioPlayer: AVAudioPlayer?
///Runs the specified audiio file & return the duration of the file.
func runVoices(url: URL) async -> TimeInterval {
    let durationTask = Task {
        
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        
        guard let duration = audioPlayer?.duration else {
            return TimeInterval(0)
        }
        return duration
    }
    do {
        let result = try await durationTask.result.get()
        return result
    } catch {
        print("Error")
        return TimeInterval(0)
    }
}
