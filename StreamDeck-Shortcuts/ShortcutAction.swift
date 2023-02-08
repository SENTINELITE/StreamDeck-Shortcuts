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
    
    func willAppear(device: String, payload: AppearEvent<NoSettings>) {
        NSLog("MRVN-One Payload \(payload)")
    }
    
    func propertyInspectorDidAppear(device: String) {
        NSLog("MRVN-Two PI Did Appear")
//        var listOfSayVoices = ["Samantha", "Victoria", "Alex", "Fred"]
        let payloadToSend = ["type": "debugPayload", "voices": "\(listOfSayVoices)", "folders": "\(shortcutsFolder)"]
        sendToPropertyInspector(payload: payloadToSend)

        getSettings() //
    }
    
    #warning("Currently not getting this. It's being re-routed to the PluginDelegate. Probably because the manifest.json action type (shortcuts.action) isn't correct 😅")
    func sentToPlugin(payload: [String : String]) {
        NSLog("MRVN-Three SendToPlugin - \(payload)")
    }
    
    func didReceiveSettings(device: String, payload: SettingsEvent<NoSettings>.Payload) {
        NSLog("MRVN-Four didReceiveSettings")
    }

}
