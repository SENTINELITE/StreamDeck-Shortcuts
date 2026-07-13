//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import AVFoundation
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

//TODO: Pass Speed Parameter
var audioPlayer: AVAudioPlayer?

///Runs the specified audiio file & return the duration of the file.
func runVoices(url: URL, playbackSpeed: Float = 1.0) async -> TimeInterval {
    let durationTask = Task {
        
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.enableRate = true
        audioPlayer?.rate = playbackSpeed
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
