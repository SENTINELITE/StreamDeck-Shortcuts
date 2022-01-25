//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation
import Sentry

var newKeyIds = [String:String]()
let sdDir = NSHomeDirectory().appending("/Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.streamdeckshortcuts.sdPlugin/")
let keysFile = sdDir.appending("keys.json")
let settingsFile =  sdDir.appending("userSettings.json")


// This will make sure that our .sdPlugin folder exists, before trying to load/save to the file!
func dirCheck() async -> Bool {
    let manager = FileManager.default
    do {
        let fileUrl = URL(fileURLWithPath: sdDir)
        NSLog("X : fileURL: \(fileUrl)")
        NSLog("X :  marker di=r \(sdDir)")
        if !manager.fileExists(atPath: sdDir) {
            try manager.createDirectory(
                at: fileUrl,
                withIntermediateDirectories: false,
                attributes: nil
            )
            NSLog("📂 Path has been made!")
        }
        else {
            NSLog("📂 Path exists!")
        }
        return true
    } catch {
        NSLog("🚨 #E1 \(error)")
        return false
    }
}

func saveFile (fileName: String) async -> Int {
    let fileUrl = URL(fileURLWithPath: fileName) //Input From Func
    
    //    Task {
    //Check if the .sdPlugin folder exists, this is a safety net, so we don't throw un-related error to Sentry.
    if await dirCheck() {
        do {
            NSLog("📂 Path exists! We need to save the new data!")
            if fileName.contains("keys.json") {
                let jsonData = try JSONSerialization.data(withJSONObject: newKeyIds, options: .prettyPrinted)
                try jsonData.write(to: fileUrl)
            }
            else if fileName.contains("userSettings.json") {
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let jsonData = try encoder.encode(userPrefs)
                try jsonData.write(to: fileUrl)
            }
            else {
                NSLog("Unknown filepath: \(fileUrl)")
            }
            return 1
        } catch {
            NSLog("📂 Can't creat file because of: \(error)")
            return 0
        }
        //        }
    }
    return 0
}

func loadFiles (fileName: String) async -> Int {
    let manager = FileManager.default
    let fileUrl = URL(fileURLWithPath: fileName) //Input From Func
    
    //Check if the file exists, if not we create the newly saved data.
    if manager.fileExists(atPath: fileName) { //TODO: DATA Doesn't exist, default to base stats.
        //Decode the files
        do {
            let data = try Data(contentsOf: fileUrl)
            if fileName.contains("keys.json") {
                let decodedData = try JSONDecoder().decode([String : String].self, from: data)
                newKeyIds = decodedData
                NSLog("DecodedData: \(decodedData)")
                
            }
            else if fileName.contains("userSettings.json") {
                let decodedData = try JSONDecoder().decode(mySettings.self, from: data)
                userPrefs = decodedData
                NSLog("DecodedData: \(decodedData)")
            }
            else {
                NSLog("Unknown filepath: \(fileUrl)")
            }
            return 1
        } catch {
            NSLog("📂 Loading file Error: \(error)")
            SentrySDK.capture(error: error)
            return 0
        }
    }
    else {
        NSLog("📂 File doesn't exist, defaulting to default keys & settings!")
    }
    return 0
}
