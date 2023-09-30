//
//  ShortcutAction.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 2/7/23.
//

import Foundation
import StreamDeck
import AppKit

class ShortcutAction: Action {
    static var controllers: [StreamDeck.ControllerType] = [.keypad]
    
    static var encoder: StreamDeck.RotaryEncoder?
    
    
    ///The Settings we store foreach Key.
    struct Settings: Codable, Hashable {
        ///A stored reference to the Shortcut's name
        let shortcutToRun: String
        
        ///Stored ref. to the Shortcut, by it's UUID (The preferred way of running)
        let shortcutUUID: UUID
        
        ///if the key is Force-projecting it's name to the Key, on the StreamDeck Display
        let isPerKeyForcedTextfield: Bool
        
        ///If this key has Accessbility mode on. (Speakes the key when running it, providing audible feedback)
        let isPerKeyAccessibility: Bool
        
        ///If this key has Hold mode on. (This makes the user click & hold the key for X time before running the key's action.)
        let isPerKeyHoldTime: Bool
        
        ///The time the user has set for *this* key's holdTime, before running the action.
        var accessHoldTime: Double
    }
    
    //MARK: Default Action Stuff
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
    
    //MARK: Action-specific extras
    
    var isPressed = false
    
    var holdTime: Double = 0.0
    
    required init(context: String, coordinates: Coordinates?) {
        self.context = context
        self.coordinates = coordinates
    }
    
    @GlobalSetting(\.isForcedTitleGlobal) var isForcedTitleGlobal
    @GlobalSetting(\.isAccessibilityGlobal) var isAccessibilityGlobal
    @GlobalSetting(\.isHoldTimeGlobal) var isHoldTimeGlobal
    @GlobalSetting(\.accessSpeechRateGlobal) var accessSpeechRateGlobal
    
    // Local, internal counter, to handle Double/Triple tap feature.
    private var pressCount = 0
    
    var currentTask: Task<Void, Never>?
    
    ///The amount of time the user has between clicks, before registering a Double/Triple tap.
    var sdKeyDownBuffer = 0.2 //TODO: We need to make this adjustable & toggelable. Some people may not want any delay for these features.
    
    var isForcedTitle = false //TODO: Connect to PI
    var isAccessibility = false //TODO: Remove this global var!
    
    /// Local ref to the Action's Setting
    var isHoldTime = false
    
    @available(*, deprecated, renamed: "UUID", message: "Switch to UUID")
    var shortcutToRun = ""
    var shortcutToRunUUID: UUID = UUID()
    var shortcutFolder = ""
    
    func clicked(settings: ShortcutAction.Settings) {
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
                    finishTask(settings: settings)
                    
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
    func finishTask (settings: ShortcutAction.Settings) {
        NSLog("☃️ Total times clicked: \(pressCount)")
        
        switch pressCount {
        case 1:
            Task {
                await executeShortcut(settings: settings)
            }
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
            Task {
                await executeShortcut(settings: settings)
            }
        }
        pressCount = 0
    }
    
    ///Runs the shortcut.
    func executeShortcut (settings: ShortcutAction.Settings) async {
        if settings.isPerKeyAccessibility || isAccessibilityGlobal {
            await sayCLI(speak: settings.shortcutToRun, speechRate: accessSpeechRateGlobal)
            if isHoldTimeGlobal || isHoldTime {
                Task {
                    var hasLoopedOnce = false
                    var curTime = holdTime //5.5 seconds
                    
                    if curTime >= 0 { //if this is zero, it's disabled so we ignore
                        while curTime > 0 {
                            if !isPressed {
                                print("User let go early!")
                                setTitleSDS()
                                await sayCLI(speak: "Cancelled Shortcut!", speechRate: accessSpeechRateGlobal)
                                return
                            }
                            
                            let duration = Duration.seconds(curTime).formatted(.units(fractionalPart: .show(length: 0)))
                            if hasLoopedOnce {
                                let shellText = Int(curTime).description //duration.description
                                await sayCLI(speak: shellText, speechRate: accessSpeechRateGlobal)
                            } else {
                                hasLoopedOnce = true
                            }
                            
                            setTitleSDSAcess(inputStr: "\(duration)")
                            
                            try await Task.sleep(nanoseconds: 1_000_000_000) //Sleep 1s
                            curTime -= 1 //Subtract 1s
                            //                        isFirstLoop = false
                        }
                        
                        if !isPressed {
                            print("User let go early!")
                            setTitleSDS()
                            await sayCLI(speak: "Cancelled Shortcut!", speechRate: accessSpeechRateGlobal)
                            return
                        }
                        
                        await sayCLI(speak: "Running Shortcut!", speechRate: accessSpeechRateGlobal)
                        vTwoRunShortcut()
                        setTitleSDS()
                        print("vTwoRunShortcut - One")
                    }
                }
            } else {
                vTwoRunShortcut()
            }
        } else {
            vTwoRunShortcut()
        }
    }
    
    
    func vTwoRunShortcut() {
        NSLog("MRVN-Zero SDS - SE - WillAppear V2 Action Instance - KeyDown")
        
        
        //        Task {
        //            NSLog("About to execute Shortcut V2")
        //            async let dtsRunner = runShortcutDTS(inputShortcut: shortcutToRun)
        //            NSLog("Executed Shortcut V2")
        //        }
        
        //        Accessibility Test (51194254-37BC-4209-864A-34888ACDD0C7)
        
        //        func runShortcutDTS(inputShortcut: String) async {
        
        NSLog("Echo-Three | Running with DTS Fix... \(shortcutToRun)")
        NSLog("Echo-Three | Running with DTS Fix... \(shortcutToRunUUID)")
        
        let shortcutsCLI = Process()
        shortcutsCLI.standardInput = nil //TODO: DTS Fix. This allows us to run the Shortcut!!!
        
        shortcutsCLI.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        //    let xo = #"inputShortcut"#
        shortcutsCLI.arguments = ["run", shortcutToRunUUID.uuidString]
        
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
    
    func keyDown(device: String, payload: KeyEvent<Settings>) {
        isPressed = true
        
        NSLog("Pressed keyDown...")
        getSettings()
        //        StreamDeckPlugin.shared getGlobalSettings()
        //        StreamDeckPlugin.shared.sendEvent(.getGlobalSettings, context: StreamDeckPlugin.shared.uuid, payload: payload)
        
        //        if payload.settings.isPerKeyAccessibility {
        //        } else {
        //            NSLog("👀 Press count \(pressCount)")
        clicked(settings: payload.settings)
        //        }
    }
    
    func keyUp(device: String, payload: KeyEvent<Settings>) {
        isPressed = false
    }
    
    func sleep(for seconds: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
    
//    MARK: WillAppear
    func willAppear(device: String, payload: AppearEvent<Settings>) {
        NSLog("🛡️ DomeOfProtection With: \(payload)")
        SDVersion = StreamDeckPlugin.shared.info.application.version //TODO: Regex to only get the first 3 numbers/2 dot notations: 6.3.0.18948 -> 6.3.0 -> 6.3 -> 6
        NSLog("Nemesis-Zero-Init with count: \(SDVersion)")
        getSettings()
        processShortcuts() //TODO: We need to do this as soon as the PI appears, & mark the old data as stale, if there are changes in the dataset.
    }
    
    //TODO: Get the settings first, loading the previous state & use that to fill the PI!
    func propertyInspectorDidAppear(device: String) {
        //        processRunShortcutTime = "0"
        logger.debug("😡 MRVN-Two PI Did Appear")
        getSettings() //
        NSLog("MRVN-Two PI Did Appear")
        NSLog("🤖 MRVN-Five PI Did Appear before sending init payload: \(shortcutToRun)")
        
//        findFolderFromShortcut() Send the folder //TODO: Send the init selected folder with the init payload, that way we're already filtering instead of showing All.
        
        //        let payloadToSend = ["type": "debugPayload", "voices": "\(listOfSayVoices)", "folders": "\(shortcutsFolder)"]
        let date = Date.now
        
        let formattedDate = date.formatted(.iso8601.year().day().month().dateSeparator(.dash).dateTimeSeparator(.standard).timeSeparator(.colon).timeZoneSeparator(.colon).time(includingFractionalSeconds: true).locale(Locale(identifier: "us_EN")))
        
        let payload: [String: Any] = [
            "totalShortcuts": newData.count,
            "totalListOfShortcuts": listOfCuts.count,
            "totalFolders": shortcutsFolder.count,
            "processShortcutsSwift": processRunShortcutTime,
            "sentAt": formattedDate.description,
            "sdsEvt": SdsEventSendType.initialPayload.rawValue,
            "folders": shortcutsFolder, //
            "selectedFolder": shortcutFolder,
            "isForcedTitle": isForcedTitle,
            "isAccessibility": isAccessibility,
            "isHoldTime": isHoldTime,
            "isForcedTitleGlobal": isForcedTitleGlobal,
            "isAccessibilityGlobal": isAccessibilityGlobal,
            "isHoldTimeGlobal": isHoldTimeGlobal,
            "accessSpeechRateGlobal": accessSpeechRateGlobal,
            "accessHoldTime": holdTime,
            
            
            
            //            "": listOfCuts
            //TODO: Add all shortcuts here?
        ]
        
        sendToPropertyInspector(payload: payload)
        
        NSLog("FolderSearch Being Sent 🚨 ⚠️ | Found folder \(shortcutFolder) for shortcut \(shortcutToRun)")
        logger.debug("Sending PI Appear, 📦 Initial Payload Size: \(MemoryLayout.size(ofValue: payload))")
        
        //Check for folder here first!
        
        
        
        
        sendNewFolderAndShortcuts(folder: "All")
        NSLog("🤖 MRVN-Six PI Did Appear After sending init payload: \(shortcutToRun)")
    }
    
    
    
    func propertyInspectorDidDisappear(device: String) {
        saveSettingsHelper()
        getSettings() // Retrieve the saved settings | TODO: Do We really need this anymore?
        processShortcuts() //TODO: We need to do this as soon as the PI appears, & mark the old data as stale, if there are changes in the dataset.
    }
    
    ///A Generalized helper function to save settings.
    func saveSettingsHelper() {
        let xy = Settings(shortcutToRun: shortcutToRun, shortcutUUID: shortcutToRunUUID, isPerKeyForcedTextfield: isForcedTitle, isPerKeyAccessibility: isAccessibility, isPerKeyHoldTime: isHoldTime, accessHoldTime: holdTime)
        //        setSettings(to: xy)
        setSettings(to: xy)
        NSLog("Gibby One | New Settings saved, with: \(xy)")
        setTitleSDS()
        //        setSettings(to: xy) // Save the updated settings
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
                if let evt = SdsEventRecieveType(rawValue: i.value) {
                    switch evt {
                        
                    case .newShortcutSelected:
                        NSLog("Beta-One | New Shortcut Selected As Event String... \(payload["data"])")
                        shortcutToRun = payload["data"] ?? "nil"
                        NSLog("Beta-One | New Shortcut Selected... \(shortcutToRun)")
                        NSLog("🤖 Shortcut UUID Debug 1: \(shortcutToRunUUID)")
                        shortcutToRunUUID = shortcutNameToUUID(inputShortcutName: shortcutToRun)
                        NSLog("🤖 Shortcut UUID Debug 2: \(shortcutToRunUUID)")
                        let customJSON = sdsSettings(shortcut: shortcutToRun)
                        saveSettingsHelper()
                        
                    case .newFolderSelected:
                        if let folder = payload["data"] {
                            sendNewFolderAndShortcuts(folder: folder)
                        } else {
                            NSLog("newFolderSelected Failed with: \(payload)")
                        }
                    case .globalSettingsUpdated:
                        
                        if let jsonDataString = payload["data"] {
                            NSLog("🌐 global setting has changed... title: \(jsonDataString) ")
                            // Step 2: Convert the "data" field back to a Swift data
                            if let jsonData = jsonDataString.data(using: .utf8) {
                                // Step 3: Use JSONDecoder to decode the JSON data into GlobalSettingsUpdated struct
                                do {
                                    let decoder = JSONDecoder()
                                    let settings = try decoder.decode(GlobalSettingsUpdated.self, from: jsonData)
                                    
                                    NSLog("📦 GlobalSettings Payload... \(settings)")
                                    
                                    isForcedTitle = settings.isForcedTitleLocal
                                    isAccessibility = settings.isAccesLocal
                                    holdTime = settings.accessHoldTime //If this is true then the above will equalt true & vice versa
                                    isHoldTime = settings.isHoldTime
                                    
                                    isForcedTitleGlobal = settings.isForcedTitleGlobal
                                    isAccessibilityGlobal = settings.isAccesGlobal //If this is true then the above will equalt true & vice versa
                                    isHoldTimeGlobal = settings.isHoldTimeGlobal //If this is true then the above will equalt true & vice versa
                                    accessSpeechRateGlobal = settings.accessSpeechRateGlobal
                                    
                                    NSLog("SettingsDEBUG: About to save holdTime: \(holdTime) with holdTimeToggle: \(isHoldTimeGlobal)")
                                    saveSettingsHelper()
                                } catch {
                                    NSLog("🌐 Error: \(error) \(#file) \(#line) ")
                                }
                            } else {
                                NSLog("🌐 Failed to load payload \(#file) \(#line) ")
                            }
                        }
                    }
                } else {
                    NSLog("SentFromSteamDeckApp -> This case has defaulted with: \(payload)")
                }
            }
        }
    }
    
    func newShortcutSelected () {
        
    }
    
    func sendNewFolderAndShortcuts(folder: String) {
        NSLog("MRVN-Five-Two newFolderSelected")
        logger.debug("😡 MRVN-Five-Two newFolderSelected")
        NSLog("MRVN-Five-Three data")
        let newShortcutsPayload = filterMappedFolder(folderName: folder)
        NSLog("🚀 Ultra-One New Folder Selected | Shortcut.first = \(shortcutToRun)")
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
        
        sendToPropertyInspector(payload: finalPayload)
        NSLog("MRVN-Five-One \(newShortcutsPayload)")
        NSLog("MRVN-Five-Two Sending Payload \(finalPayload)")
        saveSettingsHelper()
        //                    }
    }
    
    func didReceiveSettings(device: String, payload: SettingsEvent<Settings>.Payload) {
        NSLog("MRVN-Four didReceiveSettings \(payload.settings)")
        NSLog("🤖 Shortcut UUID Debug 3: \(shortcutToRunUUID)")
        shortcutToRunUUID = payload.settings.shortcutUUID
        NSLog("🤖 Shortcut UUID Debug 4: \(shortcutToRunUUID)")
        shortcutToRun = uuidToShortcut(inputUUID: shortcutToRunUUID)
        
//        shortcutToRun = payload.settings.shortcutToRun
        findFolderFromShortcut()
        
        isAccessibility = payload.settings.isPerKeyAccessibility
        isForcedTitle = payload.settings.isPerKeyForcedTextfield
        isHoldTime = payload.settings.isPerKeyHoldTime
        
        
        holdTime = payload.settings.accessHoldTime
        
        if payload.settings.isPerKeyForcedTextfield || isForcedTitleGlobal == true  {
//            setTitle(to: payload.settings.shortcutToRun)
            setTitleSDS()
        }
    }
    
    func didReceiveGlobalSettings() {
        NSLog("Nemesis-Zero-GlobalSettings -> \(self.isForcedTitleGlobal) \(self.isAccessibilityGlobal) \(self.isHoldTimeGlobal)")
        setTitleSDS()
    }
    

}

//MARK: Extended Functions
extension ShortcutAction {
    func setTitleSDSAcess(inputStr: String) {
        setTitle(to: inputStr)
    }
    
    func setTitleSDS() {
//        NSLog("About to set Title... \(shortcutToRun)")
//        Task {
//            try await Task.sleep(nanoseconds: 1_000_000_000)
            if isForcedTitle || isForcedTitleGlobal {
                setTitle(to: shortcutToRun)
                NSLog("set Title -> \(shortcutToRun)")
            } else {
                setTitle(to: "")
                NSLog("set Title -> BLANK")
            }
//        }
    }
    
    func findFolderFromShortcut() {
        //shortcutName
        NSLog("FolderSearch 🚨 ⚠️ | looking for folder for shortcut \(shortcutToRun)")
        let matchingShortcut = newData.first { $0.shortcutName == shortcutToRun }
        if let folderName = matchingShortcut?.shortcutFolder {
            shortcutFolder = folderName
            NSLog("FolderSearch 🚨 ⚠️ | Found folder \(folderName) for shortcut \(shortcutToRun)")
            let filteredShortcuts = filterMappedFolder(folderName: folderName)
            // Use the filteredShortcuts as needed
        }
    }
    
    //MARK: Access Speach
    
}


//MARK: Misc Functions
///Retutrns an array of shortcuts, that match the passed in folder String.
func filterMappedFolder(folderName: String) -> [String] {
    if folderName == "All" {
        return newData.map { $0.shortcutName }.sorted()
    } else {
        return newData.filter { $0.shortcutFolder == folderName }
            .map { $0.shortcutName }
    }
}
