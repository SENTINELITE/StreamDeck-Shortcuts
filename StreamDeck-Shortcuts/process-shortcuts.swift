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
    let transaction = SentrySDK.startTransaction(
      name: "transaction-processShortcuts",
      operation: "processShortcuts"
    )
    NSLog("DEBUG: Starting processShortcuts()!")
    
    listOfCuts.removeAll()
    shortcutsFolder.removeAll()
    shortcutsMapped.removeAll()
    listOfFoldersWithShortcuts.removeAll()
    
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
            SentrySDK.capture(message: "Couldn't unwrap optinal string: output from findFolders()... Outputs: \(output)")
            return "nil"
        }
        
        shortcutsCLI.waitUntilExit()
        //    NSLog("Finshed running With:  \(shortcutsCLI.arguments)")
        return safeOutput
    }
    
    let listOfAllShortcuts = shortcutsCLIProcessor(args: ["list"]).split(whereSeparator: \.isNewline).map(String.init) //Creates an array based off of the input String
    let listOfFolders = shortcutsCLIProcessor(args: ["list", "--folders"]).split(whereSeparator: \.isNewline).map(String.init) //Creates an array based off of the input String


    shortcutsFolder = listOfFolders
    
    //
    shortcutsFolder.insert("All", at: shortcutsFolder.startIndex) //Helper for JS. | Swift > Java :p
    listOfCuts = listOfAllShortcuts
    
    for name in listOfFolders {
        let splitsUp = shortcutsCLIProcessor(args: ["list", "--folder-name", "\(name)"]).split(whereSeparator: \.isNewline).map(String.init) //Fetch each shortcut from every folder, & create an array.
        for shortcut in splitsUp {
            shortcutsMapped.updateValue(name, forKey: shortcut) //Add all Shortcuts & their folderName to Dictionary.
            if(!listOfFoldersWithShortcuts.contains(name)) {
                listOfFoldersWithShortcuts.append(name)
            }
        }
    }
    listOfFoldersWithShortcuts.insert("All", at: listOfFoldersWithShortcuts.startIndex)
    shortcutsFolder = listOfFoldersWithShortcuts
    
    func findDiff() {
        var shortcutsWithFolders = [String]() //Make a temp array to compare shortcuts that have folders with all shortcuts.
        for key in shortcutsMapped {
            shortcutsWithFolders.append(key.key)
        }
        let listOfAllShortcutsSet = Set(listOfAllShortcuts)
        let shortcutsWithFoldersSet = Set(shortcutsWithFolders)
        let diff2 = listOfAllShortcutsSet.symmetricDifference(shortcutsWithFoldersSet)
            print("XSET: \(shortcutsWithFolders.count)")
            print("OGSet: \(listOfAllShortcuts.count)")
            print("OGSet: \(diff2.count)")
        print("Shortcuts without a folder:", diff2)
        
        for i in diff2 { //if the key's folder is nil, set it tall "all"
            shortcutsMapped.updateValue("All", forKey: String(i))
        }
        print(shortcutsMapped.count)
    }
    
    findDiff()
    print("MappedOut: \(shortcutsMapped)")
    
    NSLog("DEBUG: Finished Running processShortcuts()!")
    transaction.finish(); // Finishing the transaction will send it to Sentry
}
