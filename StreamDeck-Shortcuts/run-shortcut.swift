//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation


//  🔷----------------------------------------------------- --------------------------------------------------
//  | Runs the specified shortcut. TODO: Drop support for Applescript, & use the Shortcuts CLI excluseivly.  |
//  ----------------------------------------------------- ----------------------------------------------------

func RunShortcut(shortcutName: String) async -> Int32 {
    
    let shortcutNameParsed = shortcutName.replacingOccurrences(of: " ", with: "\\\\ ", options: .literal, range: nil) //Handle whitespace in a shortcut's name.
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
        NSLog("\(error)")
    }
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    //    task.waitUntilExit()
    NSLog("Finshed running With: \(args)")
    NSLog("❄️ Finshed running output With: \(output)")
    
    return task.terminationStatus
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
