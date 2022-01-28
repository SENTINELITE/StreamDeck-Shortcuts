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

//MARK: 🏃🏼‍♀️Old RunShortcut Fallover Function
func newX(shortcutName: String) async -> Int32 {
    if(userPrefs.isDeprecatedRunner == true) {
        NSLog("The User has forced the deprecated function!")
        SentrySDK.capture(message: "The User has forced the deprecated function!")
    }
    else {
        NSLog("We've needed to run the old ShortcutsRun() function!")
        SentrySDK.capture(message: "We've needed to run the old ShortcutsRun() function!")
    }
    //Older method of running, it didn't work with single quotes, like: "Joe's playlist"
    //    let args: [String] = ["-e", #"do shell script "shortcuts run \#(shortcutNameParsed)""#] //Pass in the arguments for the AppleScript
    
    let anotherNew = "do shell script \"shortcuts run \\\"\(shortcutName)\\\"\""
    let args: [String] = ["-e", anotherNew] //Pass in the arguments for the AppleScript
    
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    task.launchPath = "/usr/bin/osascript"
    task.arguments = args
    do {
        try task.run()
    }
    catch {
        SentrySDK.capture(error: error)
        NSLog("\(error)")
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    var output = String(data: data, encoding: .utf8)
    
    guard let output = output else {
        SentrySDK.capture(message: "Couldn't unwrap optinal string: output from newX()... Outputs: \(output)")
        return 0
    }
    //    task.waitUntilExit()
    NSLog("Finshed running With: \(args)")
    NSLog("❄️ Finshed running output With: \(output)")
    
    
    //If the Applescript String Parsing fails, try running the Shortcut with the W.I.P backend...
    if output.contains("execution error:") {
//        let argumentsError = "Finshed running With: \(args)"
//        SentrySDK.capture(message: argumentsError)
//        SentrySDK.capture(message: shortcutName)
        NSLog("❄️ The shortcut failed from the old AS Function. This error means major work needs to be done!")
        SentrySDK.capture(message: output)
//        newX(shortcutName: shortcutName)
    }
    
    return task.terminationStatus
}

//MARK: RunShortcut V2
//TODO: We need to run the shortcuts via their UUID, that way we don't have to re-link Shortcuts to each key! Unfortunately, there doesn't appear to be a way to fetch the UUIDs outside of an Applescript. 😔
func RunShortcut(shortcutName: String) async -> Int32 {
    
    //MARK: RunShortcuts V3 Patch
    let otherRunOutput = runShortcut(name: shortcutName, input: "")
    
    if let testX = otherRunOutput {
        NSLog("🏃🏼‍♀️ Shortcut Run V3 ran successfuly")
        SentrySDK.capture(message: "Shortcut Run V3 ran successfuly")
    }
    else if otherRunOutput == nil {
        NSLog("🏃🏼‍♀️ Shortcut Run V3 ran successfuly. Nil output though")
        SentrySDK.capture(message: "Shortcut Run V3 ran successfuly. Nil output though")
    }
    else {
        NSLog("🏃🏼‍♀️🚨 Shortcut Run V3 Did Not Successfuly Run! \(otherRunOutput)")
        
        var status: Int32 = 0
        if let encoded = shortcutName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            SentrySDK.capture(message: "Shortcut Run V3 Did Not Successfuly Run! Inside if let")
            NSLog("📙: ", shortcutName, "📙: ", encoded)
            
            let inputURL = "shortcuts://run-shortcut?name=\(encoded)"
            print(inputURL)
            if let inputURLX = URL(string: inputURL) {
                NSLog("✅ 🚀 -> Running shortcuts with options: \(inputURLX)")
                NSWorkspace.shared.open(inputURLX)
            }
            else {
                SentrySDK.capture(message: "Could not run encoded URL: \(inputURL)")
                print("Could not run encoded URL! | We're Attempting to run with the AS Function!")
                Task {
                    await newX(shortcutName: shortcutName)
                }
            }
        }
        else  {
            SentrySDK.capture(message: "Could not percent encode the ShortcutName: \(shortcutName)")
            NSLog("Could not percent encode the ShortcutName! | We're Attempting to run with the AS Function!")
            Task {
                await newX(shortcutName: shortcutName)
            }
        }
        return status
        
    }
    return 0
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



//  🔷---------------------------------------------------- ----------------------------------------------------- -----------
//  | TODO: Puzzle... This works, but as soon as we try & use it for onKeyDown, it won't execute until the program exits?" |
//  ----------------------------------------------------- ----------------------------------------------------- ------------

//func launchCommand (inputShortcut: String) async {
//    let shortcutCLI = Process()
//    shortcutCLI.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
//    shortcutCLI.arguments = ["run", "\(inputShortcut)"]
//
//    var pipe = Pipe()
//
//    shortcutCLI.standardOutput = pipe
//    NSLog("🔳 PT3.5!")
//    do{
//        NSLog("🔳 PT4.5!")
//      try shortcutCLI.launch() //Run doesn't work either. | .launch is deprecated.
//        NSLog("🔳 PT5.5!")
////          let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        NSLog("🔳 PT6.5!")
////          if let output = String(data: data, encoding: String.Encoding.utf8) {
//          NSLog("🔳 PT7.5!")
////            NSLog(output)
//          print("FinisheD Running!")
////          }
//    } catch {
//It refuses to throw an error, becuase it's waiting to execute, when the app closes?
//        NSLog("Failed to run with Error \(error)")
//    }
//
//}


//  Tried spawning a shell/CLI script with the shortcutName as the input, but this failed to run aswell. Same case as launchCommand ^^^

//func runFromNewPackage(shortcutToRun: String){
//    let pro = Process()
//    pro.executableURL = URL(fileURLWithPath: "/Users/kirkland/Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.streamdeckshortcuts.sdPlugin/shortcutsCliWrapper")
//    pro.arguments = [shortcutToRun]
//    print("about to launch...")
//    do {
//        try pro.run()
//        
//    }catch {
//        NSLog("The task has failed from backen! Erre: \(error)")
//    }
//    pro.waitUntilExit()
//    print("launched!")
//
//    print("term statuse: ", pro.terminationStatus)
////    return pro.terminationStatus
//}

//func runFromNewPackage(shortcutToRun: String) {
//    let pro = Process()
//    pro.executableURL = URL(fileURLWithPath: "/Users/kirkland/Dev/Raycast Scripts/")
//    ///Users/kirkland/Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.streamdeckshortcuts.sdPlugin/shortcutsCliWrapper
//    pro.arguments = ["./runShortcutSwift.swift \(shortcutToRun)"]
//    print("about to launch...")
////    pro.launch()
//    do {
//        try pro.run()
//
//    }catch {
//        NSLog("The task has failed from backen! Erre: \(error)")
//    }
//    print("launched!")
//}

//Forked from Apple's WWDC / Alex Hay Repo

import ScriptingBridge

@objc protocol ShortcutsEvents {
    @objc optional var shortcuts: SBElementArray { get }
}

@objc protocol Shortcut {
    @objc optional var name: String { get }
    @objc optional func run(withInput: Any?) -> Any?
}

extension SBApplication: ShortcutsEvents {}
extension SBObject: Shortcut {}

// MARK: RUN A SHORTCUT V3
func runShortcut(name: String, input: String?) -> String? {
    NSLog("⚙️ Trying to run shortcut named '\(name)'...")
    guard
        let app: ShortcutsEvents = SBApplication(bundleIdentifier: "com.apple.shortcuts.events"),
        let shortcuts = app.shortcuts else {
            SentrySDK.capture(message: "Couldn't access shortcuts")
            NSLog("⛔️ Couldn't access shortcuts")
            return nil
        }

    guard let shortcut = shortcuts.object(withName: name) as? Shortcut else {
        SentrySDK.capture(message: "Shortcut doesn't exist. Value:")
        NSLog("⚠️ Shortcut doesn't exist")
        return nil
    }

    return shortcut.run?(withInput: input) as? String
}

// MARK: GET A LIST OF ALL SHORTCUTS IN THE LIBRARY
func listShortcuts() -> [String] {
    NSLog("⚙️ Trying to fetch the names of all shortcuts...")
    guard
        let app: ShortcutsEvents = SBApplication(bundleIdentifier: "com.apple.shortcuts.events"),
        let shortcuts = app.shortcuts else {
            NSLog("⛔️ Couldn't access shortcuts")
            return []
        }
    
    let shortcutNames = shortcuts.compactMap({ ($0 as? Shortcut)?.name })
    print(shortcutNames.sorted())
    return shortcutNames.sorted()
}
