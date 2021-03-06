//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation
import Sentry


//  🔷----------------------------------------------------- ----------------------------------------------------- ---------------
//  | Fetch all of the user's shortcuts, their folders, & generate an "all" folder. TODO: Process the search on the swift side. |
//  ----------------------------------------------------- ----------------------------------------------------- -----------------

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
    
    func findFolders(args: [String]) -> String {
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
    
    let listOfAllShortcuts = findFolders(args: ["list"]).split(whereSeparator: \.isNewline).map(String.init) //Creates an array based off of the input String
    let listOfFolders = findFolders(args: ["list", "--folders"]).split(whereSeparator: \.isNewline).map(String.init) //Creates an array based off of the input String
  
    //Maybe used on the future, to "heartbeat" the JS front-end. This is useful, if the user's library is super big.
//    for i in 1...10 {
//        initalShortcutsMapped.updateValue("All", forKey: listOfAllShortcuts[i])
//    }
//    NSLog("Mapped out initial settings \(initalShortcutsMapped)")
    
    #warning("We need to add 'All' here.")
    shortcutsFolder = listOfFolders
    shortcutsFolder.insert("All", at: shortcutsFolder.startIndex) //Helper for JS. | Swift > Java :p
    listOfCuts = listOfAllShortcuts
    
    for name in listOfFolders {
        let splitsUp = findFolders(args: ["list", "--folder-name", "\(name)"]).split(whereSeparator: \.isNewline).map(String.init) //Fetch each shortcut from every folder, & create an array.
        for shortcut in splitsUp {
            shortcutsMapped.updateValue(name, forKey: shortcut) //Add all Shortcuts & their folderName to Dictionary.
            if(!listOfFoldersWithShortcuts.contains(name)) {
                listOfFoldersWithShortcuts.append(name)
            }
        }
    }
//    listOfFoldersWithShortcuts.append("All")
//    listOfFoldersWithShortcuts.sort()
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
    
//    savePrefrences(filePath: debugShortcuts)
    
//    for key in shortcutsMapped
    
//    for folder in listOfFolders {
//        for nestedFolder in shortcutsMapped {
//            if (folder == nestedFolder.value) {
//                NSLog("❄️ This matches!!!!!")
//            }
//        }
//    }
//    
//    for folder in shortcutsMapped {
//        let x = shortcutsMapped.index(forKey: "All")
//        NSLog("\(x)")
//        NSLog("\(folder.value)")
//        
//    }
//    
//    NSLog("LOF \(listOfFolders), LOCs \(listOfAllShortcuts)")
//    NSLog("ListOfMapped \(shortcutsMapped)")
    
    NSLog("DEBUG: Finished Running processShortcuts()!")
    transaction.finish(); // Finishing the transaction will send it to Sentry
}
