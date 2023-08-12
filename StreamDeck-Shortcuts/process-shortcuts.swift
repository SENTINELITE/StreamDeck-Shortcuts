//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation
import Sentry
import OSLog


///Fetches all the available Shortcuts & folders. Creates an array of `ShortcutDataTwo`, which contains each Shortcut's name, folder, & UUID
func processShortcuts() {
    
    if !isCurrentlyProcessingShortcuts {
        
        let shortcutsLogger = Logger(subsystem: "StreamDeckShortcuts-2-Alpha", category: "Process Shortcuts")
        
        shortcutsLogger.debug("Starting processShortcuts()!")
        
        let startTime = Date()
        
        
        //Refresh working Data.
        listOfCuts.removeAll()
        shortcutsLogger.debug("Reset listOfCuts")
        shortcutsFolder.removeAll()
        shortcutsLogger.debug("Reset shortcutsFolder")
        shortcutsMapped.removeAll()
        shortcutsLogger.debug("Reset shortcutsMapped")
        listOfFoldersWithShortcuts.removeAll()
        shortcutsLogger.debug("Reset listOfFoldersWithShortcuts")
        newData.removeAll()
        shortcutsLogger.debug("Reset newData")
        //    shortcutdUUIDRawStringArray.removeAll()
        var shortcutdUUIDRawStringArray = [String]()
        
        var listOfAllShortcuts = [String]()
        
        //MARK: Func that handles the CLI
        func shortcutsCLIProcessor(args: [String]) -> String {
            shortcutsLogger.debug("Running CLI with: \(args)")
            let shortcutsCLI = Process()
            let pipe = Pipe()
            shortcutsCLI.standardOutput = pipe
            shortcutsCLI.standardError = pipe
            
            shortcutsCLI.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
            shortcutsCLI.arguments = args
            shortcutsCLI.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8)
            
            guard let safeOutput = output else {
                //                SentrySDK.capture(message: "Couldn't unwrap optinal string: output from findFolders()... Outputs: \(output)")
                NSLog("\(output)")
                shortcutsLogger.debug("CLI safeOutPut")
                return "nil"
            }
            
            shortcutsCLI.waitUntilExit()
            //    NSLog("Finshed running With:  \(shortcutsCLI.arguments)")
            shortcutsLogger.debug("Safely Exiting CLI...")
            return safeOutput
        }
        
        func fetchFolders() {
            let listOfFolders = shortcutsCLIProcessor(args: ["list", "--folders"]).split(whereSeparator: \.isNewline).map(String.init) //Creates an array based off of the input String
            shortcutsFolder = listOfFolders
            
            //Change All to "Unsorted". All should just return all Shortcuts
            shortcutsFolder.insert("Unsorted", at: shortcutsFolder.startIndex) //Helper for JS. | Swift > Java :p
            shortcutsFolder.insert("All", at: shortcutsFolder.startIndex) //Helper for JS. | Swift > Java :p
            shortcutsLogger.debug("Shortcuts Folders Fetched: \(shortcutsFolder)")
            listOfCuts = listOfAllShortcuts
            
            
            for name in listOfFolders {
                let splitsUp = shortcutsCLIProcessor(args: ["list", "--folder-name", "\(name)"]).split(whereSeparator: \.isNewline).map(String.init) //Fetch each shortcut from every folder, & create an array.
                for shortcut in splitsUp {
                    
                    if let index = newData.firstIndex(where: { $0.shortcutName == shortcut }) {
                        newData[index].shortcutFolder = name
                    }
                    //
                    //
                    //                shortcutsMapped.updateValue(name, forKey: shortcut) //Add all Shortcuts & their folderName to Dictionary.
                    //                if(!listOfFoldersWithShortcuts.contains(name)) {
                    //                    listOfFoldersWithShortcuts.append(name)
                    //                }
                }
            }
            listOfFoldersWithShortcuts.insert("All", at: listOfFoldersWithShortcuts.startIndex)
            //shortcutsFolder = listOfFoldersWithShortcuts
        }
        
        ///Fetches all of the user's shortcuts & their respective UUID's.
        func fetchShortcuts() {
            
            if #available(macOS 13, *) {
#warning("macOS 13 Only!")
                shortcutdUUIDRawStringArray = shortcutsCLIProcessor(args: ["list", "--show-identifiers"]).split(whereSeparator: \.isNewline).map(String.init)
                
                for i in shortcutdUUIDRawStringArray {
                    if let match = i.wholeMatch(of: uuidRegex) {
                        let uuid = UUID(uuidString: String(match.2))!
                        print("Shortcut \(match.1) has UUID of: \(uuid)")
                        newData.append(ShortcutDataTwo(shortcutName: String(match.1), shortcutFolder: "Unsorted", shortcutUUID: uuid))
                    }
                }
            } else {
                //TODO: Include UUID, maybe use AppleScript here?
                listOfAllShortcuts = shortcutsCLIProcessor(args: ["list"]).split(whereSeparator: \.isNewline).map(String.init) //Creates an array based off of the input String
            }
        }
        //
        //    func findDiff() {
        //        var shortcutsWithFolders = [String]() //Make a temp array to compare shortcuts that have folders with all shortcuts.
        //        for key in shortcutsMapped {
        //            shortcutsWithFolders.append(key.key)
        //        }
        //        let listOfAllShortcutsSet = Set(listOfAllShortcuts)
        //        let shortcutsWithFoldersSet = Set(shortcutsWithFolders)
        //        let diff2 = listOfAllShortcutsSet.symmetricDifference(shortcutsWithFoldersSet)
        //        print("XSET: \(shortcutsWithFolders.count)")
        //        print("OGSet: \(listOfAllShortcuts.count)")
        //        print("OGSet: \(diff2.count)")
        //        print("Shortcuts without a folder:", diff2)
        //
        //        for i in diff2 { //if the key's folder is nil, set it tall "all"
        //            shortcutsMapped.updateValue("All", forKey: String(i))
        //        }
        //        print(shortcutsMapped.count)
        //    }
        
        fetchShortcuts()
        fetchFolders()
        //    findDiff()
        
        let finishedTime = Date()
        let diff = (finishedTime.timeIntervalSinceNow - startTime.timeIntervalSinceNow)
        let out = diff.formatted(.number.precision(.fractionLength(3))).description
        processRunShortcutTime = "Last Run: " + out
        shortcutsLogger.debug("Finishied running processShortcuts, in \(out)")
        NSLog("Finishied running processShortcuts, in \(out) - NSLOG")
        shortcutsLogger.debug("Mapped Out: \(shortcutsMapped)")
    }
}

///Checks & updates the key's data, based off it's previously saved UUID
func uuidToShortcut(inputUUID: UUID) -> String {
    NSLog("inputUUID: \(inputUUID)")
    
    guard let matchingShortcut = newData.first(where: {
        if let uuid = $0.shortcutUUID {
//            NSLog("ShortcutName\t\($0.shortcutName)\tId\t\(uuid)")
            return uuid == inputUUID
        }
        return false
    }) else {
        return "ERROR: UUID NOT FOUND"
    }
    
    NSLog(matchingShortcut.shortcutName)
    return matchingShortcut.shortcutName
}


///Checks & updates the key's data, based off it's previously saved UUID
func shortcutNameToUUID(inputShortcutName: String) -> UUID {
    if let matchingShortcut = newData.first(where: { $0.shortcutName == inputShortcutName }) {
        guard let id = matchingShortcut.shortcutUUID else {
            // Handle the error case (e.g., throw an error or return a default UUID)
            fatalError("UUID is nil for shortcut: \(inputShortcutName)")
        }
        print(matchingShortcut.shortcutName)
        NSLog("→ shortcutToRun: \(inputShortcutName) → UUID: \(id)")
        return id
    } else {
        // Handle the error case (e.g., throw an error or return a default UUID)
        fatalError("No matching shortcut found for name: \(inputShortcutName)")
    }
}



func listFoldersNew() {
    
}
