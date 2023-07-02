//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation
import Sentry


///Fetches all the available Shortcuts & folders. Creates an array of `ShortcutDataTwo`, which contains each Shortcut's name, folder, & UUID
func processShortcuts() {
    NSLog("DEBUG: Starting processShortcuts()!")
    
    
    //Refresh working Data.
    listOfCuts.removeAll()
    shortcutsFolder.removeAll()
    shortcutsMapped.removeAll()
    listOfFoldersWithShortcuts.removeAll()
//    shortcutdUUIDRawStringArray.removeAll()
    var shortcutdUUIDRawStringArray = [String]()
    
    var listOfAllShortcuts = [String]()
    
    //MARK: Func that handles the CLI
    func shortcutsCLIProcessor(args: [String]) -> String {
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
            print(output)
            return "nil"
        }
        
        shortcutsCLI.waitUntilExit()
        //    NSLog("Finshed running With:  \(shortcutsCLI.arguments)")
        return safeOutput
    }
    
    func fetchFolders() {
        let listOfFolders = shortcutsCLIProcessor(args: ["list", "--folders"]).split(whereSeparator: \.isNewline).map(String.init) //Creates an array based off of the input String
        shortcutsFolder = listOfFolders
        
        //Change All to "Unsorted". All should just return all Shortcuts
        shortcutsFolder.insert("Unsorted", at: shortcutsFolder.startIndex) //Helper for JS. | Swift > Java :p
        shortcutsFolder.insert("All", at: shortcutsFolder.startIndex) //Helper for JS. | Swift > Java :p
        NSLog("Shortcuts Folders Fetched: \(shortcutsFolder)")
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
    
    print("MappedOut: \(shortcutsMapped)")
    NSLog("DEBUG: Finished Running processShortcuts()!")
}

///Checks & updates the key's data, based off it's previously saved UUID
func uuidToShortcut (inputUUID: UUID) -> String {
    //check uuid
    //        shortcutdUUIDRawStringArray
    if let matchingShortcut = newData.first(where: { $0.shortcutUUID == inputUUID }) {
        print(matchingShortcut.shortcutName)
    }
    
    return "UUID FOUND FIX ME"
}

///Checks & updates the key's data, based off it's previously saved UUID
func shortcutNameToUUID (inputShortcutName: String) -> String {
    //check uuid
    //        shortcutdUUIDRawStringArray
    var id = String()
    if let matchingShortcut = newData.first(where: { $0.shortcutName == inputShortcutName }) {
        id = matchingShortcut.shortcutUUID!.uuidString
        print(matchingShortcut.shortcutName)
    }
    
    NSLog("→ shortcutToRun: \(inputShortcutName) → UUID: \(id)")
    
    return id
}

func listFoldersNew() {
    
}
