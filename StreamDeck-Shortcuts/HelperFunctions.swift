//
//  HelperFunctions.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 1/27/22.
//

import StreamDeck
import Foundation
import AppKit

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


class TestAction: Action {

//    struct Settings: Codable, Hashable {
//        let someKey: String
//    }
    
//    var settings: Settings = NoS

    static var name: String = "TestAction"
    
    static var uuid: String = "test.action"
    
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
    
    func willAppear(device: String, payload: AppearEvent<NoSettings>) {
        NSLog("MRVN-One Payload \(payload)")
    }

}



struct PluginCount: EnvironmentKey {
    static let defaultValue: Int = 0
}


