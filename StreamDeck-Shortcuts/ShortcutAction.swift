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

class ShortcutAction: Action {

//    struct Settings: Codable, Hashable {
//        let someKey: String
//    }
    
//    var settings: Settings = NoS

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
    
    func keyDown(device: String, payload: KeyEvent<NoSettings>) {
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
            shortcutToRun = shortcutNameToUUID(inputShortcutName: shortcutToRun)
            NSLog("Echo-Three | Running with DTS Fix... \(shortcutToRun)")
        
            let shortcutsCLI = Process()
            shortcutsCLI.standardInput = nil //TODO: DTS Fix. This allows us to run the Shortcut!!!

            shortcutsCLI.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
        //    let xo = #"inputShortcut"#
            shortcutsCLI.arguments = ["run", shortcutToRun]

            do {
                try shortcutsCLI.run()
            } catch {
                NSLog("\(error)")
            }
            NSLog("Should've ran the shortcut...")
//        }
        
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
        
        NSLog("mapped Shortcuts: \(shortcutsMapped)")
        

    }
    
    func updateText() { //contextStr: String
        let int = Int.random(in: 0...1337)
        setTitle(to: int.description)
    }
    
    func willAppear(device: String, payload: AppearEvent<NoSettings>) {
        NSLog("MRVN-One Payload \(payload)")
    }
    
    func propertyInspectorDidAppear(device: String) {
        NSLog("MRVN-Two PI Did Appear")
//        processShortcuts()
//        let payloadToSend = ["type": "debugPayload", "voices": "\(listOfSayVoices)", "folders": "\(shortcutsFolder)"]
        
        let finalPayload: [String: Any] = [
            "sdsEvt": SdsEventSendType.initialPayload.rawValue,
            "folders": ["SE", "All", "DEV", "Shortcuts Demo"]//shortcutsFolder
        ]
        
        sendToPropertyInspector(payload: finalPayload)

        getSettings() //
    }
    
    #warning("Currently not getting this. It's being re-routed to the PluginDelegate. Probably because the manifest.json action type (shortcuts.action) isn't correct 😅")
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
                    NSLog("New Shortcut Selected As Event String... \(payload["data"])")
                    
                case SdsEventRecieveType.newShortcutSelected.rawValue:
                    NSLog("New Shortcut Selected... \(payload["data"])")
                    shortcutToRun = payload["data"] ?? "nil"
//                    print("New Shortcut Selected... ", payload["data"])
                    
//                case SdsEventRecieveType.re
                    
                case "newFolderSelected":
                    NSLog("MRVN-Five-Two newFolderSelected")
                    //                    if i.key == "data" {
                    NSLog("MRVN-Five-Three data")
                    let folder = payload["data"]
                    let newShortcutsPayload = filterMappedFolder(folderName: folder!)
//                    let payloadToSend = ["sdsEvt": SdsEventSendType.filteredFolder, "filteredShortcuts": "\(newShortcutsPayload)"]
                    
//                    let newPayload: [String: Any] = [
//                        "sdsEvt": SdsEventRecieveType.folderSelected.rawValue,
//                        "filteredShortcuts": newShortcutsPayload
//                    ]
                    
                    let finalPayload: [String: Any] = [
                        "sdsEvt": SdsEventSendType.filteredFolder.rawValue,
                        "filteredShortcuts": newShortcutsPayload
                    ]
                    
                    #warning("The `folderSelected` event is wrong! We need to send the *other* event!")
//                    let payloadToSend = ["sdsEvt": SdsEventSendType.filteredFolder.rawValue, "filteredShortcuts": "\(newShortcutsPayload)"]
                    
                    sendToPropertyInspector(payload: finalPayload)
                    NSLog("MRVN-Five-One \(newShortcutsPayload)")
                    NSLog("MRVN-Five-Two Sending Payload \(finalPayload)")
                    //                    }
                default:
                    NSLog("This case has defualted with: \(payload)")
                }
                //Switch on the eventType
            }
        }
        
        //Send Sorted Shortcuts
//        sendToPropertyInspector(payload: <#T##[String : Any]#>)
    }
    
    func didReceiveSettings(device: String, payload: SettingsEvent<NoSettings>.Payload) {
        NSLog("MRVN-Four didReceiveSettings")
    }

}


///Retutrns an array of shortcuts, that match the passed in folder String.
func filterMappedFolder(folderName: String) -> [String] {
    return newData.filter { $0.shortcutFolder == folderName }
        .map { $0.shortcutName }
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
