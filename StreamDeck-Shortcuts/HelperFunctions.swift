//
//  HelperFunctions.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 1/27/22.
//

import StreamDeck
import Foundation
import AppKit
import RegexBuilder

func preformShortcutRun() {
    
    //IF acccess run voice version else
    //Check if forced deprecateFlag is true
    //Try defaulting to the new new runner, then try the new runner, then default to the deprecated one...
    
}

//
//func findID(id: Int) -> String {
//    let script = """
//tell application "Shortcuts Events"
//    get the name of every shortcut
//end tell
//"""
//    
//    let script2 = """
//tell application "Shortcuts Events"
//    get the id of every shortcut
//end tell
//"""
//    var args = [String]()
//    if id == 1 {
//        args = ["-e", script2]
//    }
//    else {
//        args = ["-e", script]
//    }
//    
//    let task = Process()
//    let pipe = Pipe()
//    task.standardOutput = pipe
//    task.standardError = pipe
//    
//    task.launchPath = "/usr/bin/osascript"
//    task.arguments = args
//    task.launch()
//    let data = pipe.fileHandleForReading.readDataToEndOfFile()
//    let output = String(data: data, encoding: .utf8)!
//    if output.contains("error") {
//        print("🚨 OutPut: ", output)
//        print("🚨 ", args)
//        return "nil"
//    }
//    return output
////    print(output)
////    print(script)
////    print(script2)
//}
//
//var x = findID(id: 0)
//var y = findID(id: 1)
//
////print(x.debugDescription)
//var xy = x.replacingOccurrences(of: "\n", with: "").components(separatedBy: ", ")
//
////We know that there are no spaces in the UUIDs.
//var yy = y.replacingOccurrences(of: "\n", with: "").components(separatedBy: ", ")
////xy = x.replacingOccurrences(of: "\n", with: "")
//
////y.split(separator: ",")
////y.replacingOccurrences(of: "\n", with: "")
//print("")
//print(y.debugDescription)
//print(yy)
//print(" ")
//print(yy[5].debugDescription, yy[8].debugDescription, yy[12].debugDescription)
//print(" ")
//print("")
//print(xy)
//
//
//var shortcutsWithUUIDs = [String:String]()
//for i in yy.indices {
////    print("ShortcutName: \(xy[i]) with UUID of: ", yy[i])
////    print(yy[i], xy[i])
//    shortcutsWithUUIDs.updateValue(xy[i], forKey: yy[i])
//}
//
//
//func returnShortcutNameFromUUID(input: String) {
//    for key in shortcutsWithUUIDs {
//        print(key.key)
//    }
//}
//
////In order to run the Shortcut as a background procress, we need to use the Bridge, as the CLI doens't work properly.
////Because we want to track the UUID, we have to create our own map, as AppleScript is the only way to retrieve a Shortcuts UUID.
//



struct PluginCount: EnvironmentKey {
    static let defaultValue: Int = 0
}


///A new Struct for the core back-end data, for version 2.
struct ShortcutDataTwo {
    let shortcutName: String
    
    var shortcutFolder: String
    
    /// The UUID of the Shortcut.
    /// - Important: This property is only available on macOS 13.0 or later.
    var shortcutUUID: UUID?// = UUID(uuidString: "nil")
    
    /// The UUID of the Folder.
    /// - Important: This property is only available on macOS 13.0 or later.
    let shortcutFolderUUID: UUID? = UUID(uuidString: "nil")
}


//  `shortcuts list --show-identifiers` prints: `Restart Marker Timer (64B1D7F6-CBE4-445A-8715-6E1255A06857)`
//  `shortcuts list --folders --show-identifiers` -> `Marker-Dev (F42D664E-9750-446B-BD61-D5B6E2CCC58B)`

/*
 On start/PI open, refresh list of:
 • Fetch All Shortcuts
 • Find Their Folder & assign an "Unsorted" faux folder to shortcuts without folders
    • The User could've moved the Shortcut to another folder, so the Shortcut's UUID is the source of truth.
 • Find each Shortcut & each Folder's UUID's (If applicable (macOS 13.0+) if not, then assign some *other* tag to identify that we don't have UUIDs!
 
 When The user opens The PI, we should have a func that looks up the Shortcut's UUID &/or name, & looks for it's parent folder, before sending the intial payload to the PI
 */


let uuidRegex = Regex {
    /^/
    Capture {
        OneOrMore(.reluctant) {
            /./
        }
    }
    Optionally(One(.whitespace))
    "("
    Capture {
        Regex {
            Repeat(count: 8) {
                CharacterClass(
                    ("A"..."F"),
                    ("0"..."9")
                )
            }
            "-"
            Repeat(count: 4) {
                CharacterClass(
                    ("A"..."F"),
                    ("0"..."9")
                )
            }
            "-"
            Repeat(count: 4) {
                CharacterClass(
                    ("A"..."F"),
                    ("0"..."9")
                )
            }
            "-"
            Repeat(count: 4) {
                CharacterClass(
                    ("A"..."F"),
                    ("0"..."9")
                )
            }
            "-"
            Repeat(count: 12) {
                CharacterClass(
                    ("A"..."F"),
                    ("0"..."9")
                )
            }
        }
    }
    ")"
}
    .anchorsMatchLineEndings()
