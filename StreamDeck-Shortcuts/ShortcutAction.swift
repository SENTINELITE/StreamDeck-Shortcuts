//
//  ShortcutAction.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 2/7/23.
//

import Foundation
import StreamDeck
import AppKit

var shortcutToRun = ""
var shortcutToRunUUID = ""

class ShortcutAction: Action {
    static var controllers: [StreamDeck.ControllerType] = [.keypad]
    
    static var encoder: StreamDeck.RotaryEncoder?
    
    
    struct Settings: Codable, Hashable {
        let shortcutToRun: String
        let updatedInt: Int
//        let shortcutUUID: String
    }
    
    //    static var settings: Settings = Settings
    
    static var name: String = "Launch Shortcut V2"
    
    static var uuid: String = "com.sentinelite.sds.launcher"
    
    static var icon: String = "Icons/test"
    
    static var states: [PluginActionState]?
    
    static var propertyInspectorPath: String?
    
    static var supportedInMultiActions: Bool?
    
    static var tooltip: String?
    
    static var visibleInActionsList: Bool?
    
    var context: String
    
    var coordinates: Coordinates?
    
    required init(context: String, coordinates: Coordinates?) {
        self.context = context
        self.coordinates = coordinates
    }
    
    @Environment(PluginCount.self) var count: Int
    
    var pressCount = 0
    var hold = false
    var currentTask: Task<Void, Never>?
    var tmpIsAccess = false
    var tmpAccessHoldTime = 3.3
    var startedHoldingAt = 0.0
    var sdKeyDownBuffer = 0.5 //Time between taps, for double & triple clicking. TODO: We need to make this adjustable & toggelable. Some people may not want any delay for these features.
    
    func reset() {
        pressCount = 0
        hold = false
    }
    
    //Min Hold Dur
    //Wait Dur
    
    //func processTaps
    //
    
    
    
    func keyDown(device: String, payload: KeyEvent<Settings>) {
        NSLog("Pressed keyDown...")
        getSettings()
        
        if tmpIsAccess {
            startedHoldingAt = Date.now.timeIntervalSince1970 // Store the current Unix timestamp
        } else {
            NSLog("👀 Press count \(pressCount)")
            clicked()
        }
        
        
    }
    
    func keyUp(device: String, payload: KeyEvent<Settings>) {
        if tmpIsAccess {
            let releasedAt = Date.now.timeIntervalSince1970 // Store the current Unix timestamp
            let timeDifference = releasedAt - startedHoldingAt
            
            if timeDifference > tmpAccessHoldTime {
                //RunShortcut //TODO: Merge with other finishTask logic changes.
                NSLog("Horizon-Audio | WIP... Should Run Shortcut Here")
            } else {
                NSLog("Horizon-Audio | Accessibility Shortcut failed to execute due to the user letting go early")
            }
        }
        
        
    }
    
    func vTwoRunShortcut() {
        NSLog("MRVN-Zero SDS - SE - WillAppear V2 Action Instance - KeyDown count: \(count)")
        count += 2
        
        
        //        Task {
        //            NSLog("About to execute Shortcut V2")
        //            async let dtsRunner = runShortcutDTS(inputShortcut: shortcutToRun)
        //            NSLog("Executed Shortcut V2")
        //        }
        
        //        Accessibility Test (51194254-37BC-4209-864A-34888ACDD0C7)
        
        //        func runShortcutDTS(inputShortcut: String) async {
        
        NSLog("Echo-Three | Running with DTS Fix... \(shortcutToRun)")
        shortcutToRunUUID = shortcutNameToUUID(inputShortcutName: shortcutToRun)
        NSLog("Echo-Three | Running with DTS Fix... \(shortcutToRunUUID)")
        
        let shortcutsCLI = Process()
        shortcutsCLI.standardInput = nil //TODO: DTS Fix. This allows us to run the Shortcut!!!
        
        shortcutsCLI.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        //    let xo = #"inputShortcut"#
        shortcutsCLI.arguments = ["run", shortcutToRunUUID]
        
        //MARK: This runs fine. So executing a Shortcut works...
        //shortcutsCLI.arguments = ["run", "51194254-37BC-4209-864A-34888ACDD0C7"]
        
        do {
            NSLog("About to run the shortcut...")
//            let shortcutName - uuidToShortcut(inputUUID: <#T##UUID#>)
            try shortcutsCLI.run()
            NSLog("Should've ran the shortcut with UUID: \(shortcutToRunUUID) with name: \(shortcutToRun)")
            NSLog("Ran? --- \(shortcutsCLI.arguments)")
        } catch {
            NSLog("\(error)")
        }
        NSLog("Should've ran the shortcut...")
        //        }
        
        NSLog("mapped Shortcuts: \(shortcutsMapped)")
    }
    
    func clicked() {
        NSLog("clicked()...")
        pressCount += 1 // Increment pressCount
        
        // Cancel the previous task if it exists
        currentTask?.cancel()
        
        // Create a new task
        currentTask = Task {
            NSLog("Starting Task...")
            do {
                NSLog("Starting Task 2 ...")
                try await withTaskCancellationHandler {
                    NSLog("Starting Task.sleep...")
                    try await sleep(for: sdKeyDownBuffer)
                    NSLog("Task.sleep done | Wrapping Thread Up...")
                    //                    print("pressCount count: \(self.pressCount)")
                    finishTask()
                    
                } onCancel: {
                    NSLog("Task.canceled |")
                    // Handler for task cancellation
                    // We don't need to do anything special here in this case
                }
            } catch {
                NSLog("Task.Erorr | \(error)")
                // Error handling if needed
            }
        }
    }
    
    //TODO: Move inner switch logic to individual functions.
    func finishTask () {
        NSLog("☃️ Total times clicked: \(pressCount)")
        
        switch pressCount {
        case 1:
            executeShortcut()
        case 2:
            NSLog("☃️ Should open \(shortcutToRun) in the Shortcuts.app, for editing")

            var components = URLComponents()
            components.scheme = "shortcuts"
            components.host = "open-shortcut"
            components.queryItems = [URLQueryItem(name: "name", value: shortcutToRun)]

            guard let encodedURL = components.url else {
                NSLog("🚨 Bloodhound-Two | Failed to encode shortcut. Not opening & exiting loop. Shortcut: \(shortcutToRun)")
                return
            }

            NSLog("🚨 Bloodhound-Three | Attempting to run with URL-Encoded Shortcut: \(encodedURL.absoluteString)")
            NSWorkspace.shared.open(encodedURL)

        case 3:
            if let url = URL(string: "shortcuts://create-shortcut") {
                NSWorkspace.shared.open(url)
            }
        default:
            NSLog("Bloodhound-One: Defaulted on pressCount Switch, in the `finishTask` func. \n Attempting to run anyways...")
            executeShortcut()
        }
        pressCount = 0
    }
    
    func executeShortcut () {
        if !tmpIsAccess {
            vTwoRunShortcut()
        } else {
            NSLog("Horizon-Audio | Soft-releasing shortcutRun, due to accessbility-mode being on.")
        }
    }
    
    
    func sleep(for seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
    
    //TODO: Change SD Key Image | Not implemented
    func updateImage() {
        
        //Oops, I left my name here! 😅
        let images = [
            "/Users/kirkland/Downloads/SDS-Tests/1.png",
            "/Users/kirkland/Downloads/SDS-Tests/2.png",
            "/Users/kirkland/Downloads/SDS-Tests/3.png",
            "/Users/kirkland/Downloads/SDS-Tests/4.png",
            "/Users/kirkland/Downloads/SDS-Tests/5.png",
            "/Users/kirkland/Downloads/SDS-Tests/6.png"
        ]
        
        let randomImage = images[Int.random(in: 0...5)]
        let image = NSImage(contentsOfFile: randomImage)
        
        NSLog("Nemesis-One-Three-Image Base64Str: \(image?.base64String)")
        
        
        //        setImage(in: context, to: image)
        setTitle(to: randomImage)
        setImage(to: image)
    }
    
    func updateText() { //contextStr: String
        let int = Int.random(in: 0...1337)
        setTitle(to: int.description)
    }
    
    func willAppear(device: String, payload: AppearEvent<Settings>) {
        NSLog("🛡️ DomeOfProtection With: \(payload)")
        SDVersion = StreamDeckPlugin.shared.info.application.version //TODO: Regex to only get the first 3 numbers/2 dot notations: 6.3.0.18948 -> 6.3.0 -> 6.3 -> 6
        NSLog("Nemesis-Zero-Init with count: \(SDVersion)")
        
        getSettings()
    }
    
    //TODO: Get the settings first, loading the previous state & use that to fill the PI!
    func propertyInspectorDidAppear(device: String) {
        getSettings() //
        NSLog("MRVN-Two PI Did Appear")
        NSLog("🤖 MRVN-Five PI Did Appear before sending init payload: \(shortcutToRun)")
        
        findFolderFromShortcut() //Send the folder //TODO: Send the init selected folder with the init payload, that way we're already filtering instead of showing All.
        
        //        processShortcuts()
        //        let payloadToSend = ["type": "debugPayload", "voices": "\(listOfSayVoices)", "folders": "\(shortcutsFolder)"]
        
        let finalPayload: [String: Any] = [
            "sdsEvt": SdsEventSendType.initialPayload.rawValue,
            //            "folders": ["SE", "All", "DEV", "Shortcuts Demo", "StreamDeck Shortcuts"]//shortcutsFolder
            
            "folders": shortcutsFolder //shortcutsFolder
//            "": listOfCuts
            //TODO: Add all shortcuts here?
        ]
        
        sendToPropertyInspector(payload: finalPayload)
        
        //Check for folder here first!
        
        sendNewFolderAndShortcuts(folder: "All")
        NSLog("🤖 MRVN-Six PI Did Appear After sending init payload: \(shortcutToRun)")
        
    }
    
    
    
    func propertyInspectorDidDisappear(device: String) {
        saveSettingsHelper()
        getSettings() // Retrieve the saved settings
    }
    
    ///A Generalized helper function to save settings.
    func saveSettingsHelper() {
        let xy = Settings(shortcutToRun: shortcutToRun, updatedInt: Int.random(in: 0...100))
        NSLog("Gibby One | New Settings saved, with: \(xy)")
        setSettings(to: xy) // Save the updated settings
    }
    
#warning("Currently not getting this. It's being re-routed to the PluginDelegate. Probably because the manifest.json action type (shortcuts.action) isn't correct 😅")
    //TODO: Make an Alias called SentFromSteamDeckApp?
    func sentToPlugin(payload: [String : String]) {
        NSLog("MRVN-Three SendToPlugin - \(payload)")
        
        //The PI has requested X to be done. Delegate to that...
        
        //Folder Selection changed...
        
        for i in payload {
            if i.key == "type" {
                NSLog("MRVN-Five-One i.key == type, evt: \(i.value)")
                let evt = i.value
                switch evt {
                    
                case "newShortcutSelected":
                    NSLog("Beta-One | New Shortcut Selected As Event String... \(payload["data"])")
                    shortcutToRun = payload["data"] ?? "nil"
                    NSLog("Beta-One | New Shortcut Selected... \(shortcutToRun)")
                    shortcutToRunUUID = shortcutNameToUUID(inputShortcutName: shortcutToRun)
                    
                    setTitle(to: shortcutToRun)
                    
                    //                    struct SettingsX: Codable, Hashable {
                    //                        let someKey: String
                    //                    }
                    
                    //                    let xy = Settings(shortcutToRun: "shortcutToRun_BravoZero", updatedInt: 3)
                    //                    NSLog ("LifeLine One | New Settings saved, with: \(xy)")
                    //TODO: Move to updateSettings func, Set settings.
                    
                    //                    setSettings(to: xy)
                    //                    NSLog ("LifeLine One | New Settings saved, with: \(xy)")
                    let customJSON = sdsSettings(shortcut: shortcutToRun)
                    //                    setSettings(to: ["x":"yz"])
                    //                    Settings.encode(customJSON)
                    saveSettingsHelper()
                    
                    
                case SdsEventRecieveType.newShortcutSelected.rawValue:
                    NSLog("New Shortcut Selected //Raw Event... \(payload["data"])")
                    //                    print("New Shortcut Selected... ", payload["data"])
                    
                    //                case SdsEventRecieveType.re
                    
                case "newFolderSelected":
                    if let folder = payload["data"] {
                        sendNewFolderAndShortcuts(folder: folder)
                    } else {
                        NSLog("newFolderSelected Failed with: \(payload)")
                    }
                default:
                    NSLog("This case has defualted with: \(payload)")
                }
                //Switch on the eventType
            }
        }
        
        //Send Sorted Shortcuts
        //        sendToPropertyInspector(payload: <#T##[String : Any]#>)
    }
    
    func sendNewFolderAndShortcuts(folder: String) {
        NSLog("MRVN-Five-Two newFolderSelected")
        //                    if i.key == "data" {
        NSLog("MRVN-Five-Three data")
        let newShortcutsPayload = filterMappedFolder(folderName: folder)
        
//        if shortcutToRun.isEmpty {
//            shortcutToRun = newShortcutsPayload.first ?? "nil"
//        }
        NSLog("🚀 Ultra-One New Folder Selected | Shortcut.first = \(shortcutToRun)")
        //                    let payloadToSend = ["sdsEvt": SdsEventSendType.filteredFolder, "filteredShortcuts": "\(newShortcutsPayload)"]
        
        //                    let newPayload: [String: Any] = [
        //                        "sdsEvt": SdsEventRecieveType.folderSelected.rawValue,
        //                        "filteredShortcuts": newShortcutsPayload
        //                    ]
        
        var isShortcutInFolder = false
        if newShortcutsPayload.contains(shortcutToRun) {
            NSLog("🧱 CastleWall-One: The folder contains our shortcuts: \(shortcutToRun)")
            isShortcutInFolder = true
        } else {
            NSLog("🧱 CastleWall-Two: Shortcut: \(shortcutToRun) is not in our folder")
            shortcutToRun = newShortcutsPayload.first ?? "nil"
            //Set
        }
        
        let finalPayload: [String: Any] = [
            "sdsEvt": SdsEventSendType.filteredFolder.rawValue,
            "filteredShortcuts": newShortcutsPayload,
            "isShortcutInFolder": isShortcutInFolder,
            "shortcutToRun": shortcutToRun
        ]
        
#warning("The `folderSelected` event is wrong! We need to send the *other* event!")
        //                    let payloadToSend = ["sdsEvt": SdsEventSendType.filteredFolder.rawValue, "filteredShortcuts": "\(newShortcutsPayload)"]
        
        sendToPropertyInspector(payload: finalPayload)
        NSLog("MRVN-Five-One \(newShortcutsPayload)")
        NSLog("MRVN-Five-Two Sending Payload \(finalPayload)")
        saveSettingsHelper()
        //                    }
    }
    
    func didReceiveSettings(device: String, payload: SettingsEvent<Settings>.Payload) {
        NSLog("MRVN-Four didReceiveSettings \(payload.settings)")
        shortcutToRun = payload.settings.shortcutToRun
        
    }
    
}


///Retutrns an array of shortcuts, that match the passed in folder String.
func filterMappedFolder(folderName: String) -> [String] {
    if folderName == "All" {
        return newData.map { $0.shortcutName }.sorted()
    } else {
        return newData.filter { $0.shortcutFolder == folderName }
            .map { $0.shortcutName }
    }
}

func findFolderFromShortcut() {
    let matchingShortcut = newData.first { $0.shortcutName == shortcutToRun }
    if let folderName = matchingShortcut?.shortcutFolder {
        let filteredShortcuts = filterMappedFolder(folderName: folderName)
        // Use the filteredShortcuts as needed
    }
}




//Send Types
enum SdsEventSendType: String {
    case initialPayload
    case filteredFolder //filteredFolder from Js
    case shortcuts
}

extension SdsEventSendType: CustomStringConvertible {
    var description: String {
        switch self {
        case .initialPayload: return "ip"
        case .filteredFolder: return "south"
        case .shortcuts: return "s"
        }
    }
}

//JS/PI -> Swift
enum SdsEventRecieveType: String, Codable {
    case newShortcutSelected //A Shortcut has been selected
    case newFolderSelected // A Folder has been selected
}


struct sdsSettings: Codable {
    var shortcut: String
}
