import Foundation
import StreamDeck
import Sentry


//  🔷----------------------------------------------------- ----------------------------------------------------- ----------------
//  | This will generate the manifest, but for now, we're manually* handling this outside... TODO: Adopt the manifest generation |
//  ----------------------------------------------------- ----------------------------------------------------- ------------------

//let manifest = PluginManifest(
//    name: "StreamDeck Shortcuts",
//    description: "Launch Shortcuts straight from your StreamDeck! Features an accessibility mode for vision impaired users.",
//    author: "SENTINELITE",
//    icon: "Icons/shortcut",
//    version: "1.0.7",
//    os: [
//        .mac(minimumVersion: "12.0")
//    ],
//    software: .minimumVersion("5.0"),
//    sdkVersion: 2,
//    codePath: "StreamDeck-Shortcuts",
//    actions: [
//        PluginAction(
//            name: "Launch Shortcut",
//            uuid: "shortcut.run",
//            icon: "Icons/plus",
//            states: [
//                PluginActionState(image: "Icons/plus")
//            ],
//            tooltip: "Launches Shortcut!"),
//    ])


//  🔷--------------------
//  | Starts the plugin. |
//  ----------------------

//initalizeTD() //Starts TD...
//
////The initial signal won't send if the program exits too fast.
//SentrySDK.start { options in
//    options.dsn  = "https://e5b7ab3d23b04542818cc7bbd4a9dc0a@o1114114.ingest.sentry.io/6145162"
//    options.debug = false // Enabled debug when first installing is always helpful
//    options.tracesSampleRate = 0.1
////    options.
//    options.enableSwizzling = false
//}

//@main
//processShortcuts()
//PluginManager.main(plugin: ShortcutsPlugin.self, manifest: manifest)


//


//class IncrementAction: Action { //Type 'IncrementAction' does not conform to protocol 'Action'
//
//    typealias Settings = NoSettings
//
//    required init(context: String, coordinates: StreamDeck.Coordinates?) {
//        self.context = context
//        self.coordinates = coordinates
//    }
//
//    static var name: String = "Increment"
//
//    static var uuid: String = "counter.increment"
//
//    static var icon: String = "Icons/actionIcon"
//
//    static var states: [PluginActionState]? = [
//        PluginActionState(image: "Icons/actionDefaultImage", titleAlignment: .middle)
//    ]
//
//    static var propertyInspectorPath: String?
//
//    static var supportedInMultiActions: Bool? = true
//
//    static var tooltip: String? = "This will add a count to the number."
//
//    static var visibleInActionsList: Bool?
//
//    var context: String
//
//    var coordinates: Coordinates?
//
//    @Environment(PluginCount.self) var count: Int
//
//    required init(context: String, coordinates: Coordinates) {
//        self.context = context
//        self.coordinates = coordinates
//    }
//
////    func keyDown(device: String, payload: KeyEvent<<#S: Decodable & Hashable#>>) { //
////        count += 1
////        NSLog("Increment action ran with count: \(count) + 1...")
////
////        if payload.isInMultiAction == true {
////            NSLog("✅ This is inside a MA")
////        }
////        else {
////            NSLog("🔴 This IS NOT In a MA")
////        }
////    }
////
////    func willAppear(device: String, payload: AppearEvent) { //Reference to generic type 'AppearEvent' requires arguments in <...>
////        if payload.isInMultiAction == true {
////            NSLog("✅ This is inside a MA")
////        }
////        else {
////            NSLog("🔴 This IS NOT In a MA")
////        }
////    }
//
//}


//

//MARKL CounterPlugin Class
//class CounterPluginX: PluginDelegate {
//    static var actions: [any StreamDeck.Action.Type]
//
//
//    // MARK: Manifest
//    static var name: String = "CounterX"
//
//    static var description: String = "Count things. On your Stream Deck!"
//
//    static var category: String? = "emDun_Counter"
//
//    static var categoryIcon: String?
//
//    static var author: String = "Emory Dunn"
//
//    static var icon: String = "Icons/pluginIcon"
//
//    static var url: URL? = URL(string: "https://github.com/emorydunn/StreamDeckPlugin")
//
//    static var version: String = "0.3"
//
//    static var os: [PluginOS] = [.mac(minimumVersion: "12.0")]
//
//    static var applicationsToMonitor: ApplicationsToMonitor?
//
//    static var software: PluginSoftware = .minimumVersion("5.0")
//
//    static var sdkVersion: Int = 2
//
//    static var codePath: String = CounterPluginX.executableName
//
//    static var codePathMac: String?
//
//    static var codePathWin: String?
//
////    static var actions: [any Action.Type] = [
////        IncrementAction.self
//////        DecrementAction.self,
//////        MultiplyAction.self
////    ]
//
//    @Environment(PluginCount.self) var count: Int
//
//    required init() {
//        NSLog("CounterPlugin init!, with count: \(count)")
//        count = 10
//    }
//
//    func keyDown(action: String, context: String, device: String, payload: KeyEvent) { //Reference to generic type 'KeyEvent' requires arguments in <...>
//        StreamDeckPlugin.shared.instances.values.forEach {
//            $0.setTitle(to: "\(count)", target: nil, state: nil)
//        }
//        NSLog("❄️ State update: \(count) \n payload: \(payload), \n context \(context), \n Device: \(device), \n Action: \(action)")
//
//    }
////
////    func willAppear(action: String, context: String, device: String, payload: KeyEvent) {
////        count += 1
////        NSLog("CounterPlugin init!, with count: \(count)")
////        StreamDeckPlugin.shared.instances.values.forEach {
////            $0.setTitle(to: "\(count)", target: nil, state: nil)
////        }
////
////        if payload.isInMultiAction == true {
////            NSLog("✅ This is inside a MA")
////        }
////        else {
////            NSLog("🔴 This IS NOT In a MA")
////        }
////    }
//
//}


//
//  CounterPlugin.swift
//
//
//  Created by Emory Dunn on 10/12/21.
//

//import Foundation
//import StreamDeck

//@main
//struct MyApplication {
//  static func main() {
//    print(Date())
//  }
//}

@main
class CounterPluginXYZ: PluginDelegate { //Type 'CounterPluginXYZ' does not conform to protocol 'PluginDelegate'
    
    struct Settings: Codable, Hashable {
        let someKey: String
    }
    
    // MARK: Manifest
    static var name: String = "V2"
    
    static var description: String = "SDS V2!"
    
    static var category: String? = "SDS"
    
    static var categoryIcon: String?
    
    static var author: String = "SENTINELITE"
    
    static var icon: String = "Icons/pluginIcon"
    
    static var url: URL? = URL(string: "https://github.com/emorydunn/StreamDeckPlugin")
    
    static var version: String = "0.1"
    
    static var os: [PluginOS] = [.mac(minimumVersion: "12.0")]
    
    static var applicationsToMonitor: ApplicationsToMonitor?
    
    static var software: PluginSoftware = .minimumVersion("5.0")
    
    static var sdkVersion: Int = 2
    
    static var codePath: String = CounterPluginXYZ.executableName
    
    static var codePathMac: String?
    
    static var codePathWin: String?
    
    static var actions: [any Action.Type] = [
        ShortcutAction.self
////        DecrementAction.self
    ]
    
//    static var actions: [any Action.Type] = [
        
//    ]
    
    @Environment(PluginCount.self) var count: Int

    required init() {
        NSLog("Nemesis-One CounterPlugin initiated!")
        count = Int.random(in: 0...100)
        processShortcuts()
    }
    
    func willAppear(action: String, context: String, device: String, payload: AppearEvent<Settings>) {
        count += 1
        NSLog("Nemesis-One-One with count: \(count)")
        StreamDeckPlugin.shared.instances.values.forEach {
            $0.setTitle(to: "\(count)", target: nil, state: nil)
        }
        NSLog("Nemesis-One-Two SDS - SE - WillAppear V2 Action Instance")
        NSLog("Nemesis-One-Three Payload \(payload)")
        
    }
    
    func sentToPlugin(context: String, action: String, payload: [String : String]) {
        NSLog("Nemesis-One-Four sentToPlguin \(payload), action: \(action)")
    }
    
    

}




//class TestPlugin: PluginDelegate {
//
//    struct Settings: Codable, Hashable {
//        let someKey: String
//    }
//
//    // MARK: Manifest
//    static var name: String = "Test Plugin"
//
//    static var description: String = "A plugin for testing."
//
//    static var category: String? = nil
//
//    static var categoryIcon: String? = nil
//
//    static var author: String = "Emory Dunn"
//
//    static var icon: String = "Icons/Test"
//
//    static var url: URL? = nil
//
//    static var version: String = "0.1"
//
//    static var os: [PluginOS] = [.mac(minimumVersion: "10.15")]
//
//    static var applicationsToMonitor: ApplicationsToMonitor? = nil
//
//    static var software: PluginSoftware = .minimumVersion("4.1")
//
//    static var sdkVersion: Int = 2
//
//    static var codePath: String = TestPlugin.executableName
//
//    static var codePathMac: String? = nil
//
//    static var codePathWin: String? = nil
//
////    let eventExp: XCTestExpectation
//
//    @Environment(PluginCount.self) var count: Int
//
//    static var actions: [any Action.Type] = [
//
//    ]
//
////    init(_ exp: XCTestExpectation) {
////        self.eventExp = exp
////    }
//
//    required init() {
//        fatalError("init(port:uuid:event:info:) has not been implemented")
//    }
//
//    func didReceiveSettings(action: String, context: String, device: String, payload: SettingsEvent<Settings>.Payload) {}
//
//    func didReceiveGlobalSettings(_ settings: Settings) {}
//
//    func willAppear(action: String, context: String, device: String, payload: AppearEvent<Settings>) {}
//
//    func willDisappear(action: String, context: String, device: String, payload: AppearEvent<Settings>) {}
//
//    func keyDown(action: String, context: String, device: String, payload: KeyEvent<Settings>) {}
//
//    func keyUp(action: String, context: String, device: String, payload: KeyEvent<Settings>) {}
//
//    func titleParametersDidChange(action: String, context: String, device: String, info: TitleInfo<Settings>) {}
//
//    func deviceDidConnect(_ device: String, deviceInfo: DeviceInfo) {}
//
//    func deviceDidDisconnect(_ device: String) {}
//
//    func applicationDidLaunch(_ application: String) {}
//
//    func applicationDidTerminate(_ application: String) {}
//
//    func systemDidWakeUp() {}
//
//    func propertyInspectorDidAppear(action: String, context: String, device: String) {}
//
//    func propertyInspectorDidDisappear(action: String, context: String, device: String) {}
//
//    func sentToPlugin(context: String, action: String, payload: [String: String]) {}
//
//
//}

//class CounterPlugin: PluginDelegate {
//
//    struct Settings: Codable, Hashable {
//        let someKey: String
//    }
//
//    // MARK: Manifest
//    static var name: String = "CounterX"
//
//    static var description: String = "Count things. On your Stream Deck!"
//
//    static var category: String? = "emDun_Counter"
//
//    static var categoryIcon: String?
//
//    static var author: String = "Emory Dunn"
//
//    static var icon: String = "Icons/pluginIcon"
//
//    static var url: URL? = URL(string: "https://github.com/emorydunn/StreamDeckPlugin")
//
//    static var version: String = "0.3"
//
//    static var os: [PluginOS] = [.mac(minimumVersion: "12.0")]
//
//    static var applicationsToMonitor: ApplicationsToMonitor?
//
//    static var software: PluginSoftware = .minimumVersion("5.0")
//
//    static var sdkVersion: Int = 2
//
//    static var codePath: String = CounterPlugin.executableName
//
//    static var codePathMac: String?
//
//    static var codePathWin: String?
//
//    static var actions: [any Action.Type] = [
//        TestAction.self
////        DecrementAction.self,
////        MultiplyAction.self
//    ]
//
//    @Environment(PluginCount.self) var count: Int
//
//    required init() {
//        NSLog("CounterPlugin init!, with count: \(count)")
//        count = 10
//    }
//
//    func keyDown(action: String, context: String, device: String, payload: KeyEvent<Settings>) {
//        StreamDeckPlugin.shared.instances.values.forEach {
//            $0.setTitle(to: "\(count)", target: nil, state: nil)
//        }
//        NSLog("❄️ State update: \(count) \n payload: \(payload), \n context \(context), \n Device: \(device), \n Action: \(action)")
//
//    }
//
//    func willAppear(action: String, context: String, device: String, payload: KeyEvent<Settings>) {
//        count += 1
//        NSLog("CounterPlugin init!, with count: \(count)")
//        StreamDeckPlugin.shared.instances.values.forEach {
//            $0.setTitle(to: "\(count)", target: nil, state: nil)
//        }
//
//        if payload.isInMultiAction == true {
//            NSLog("✅ This is inside a MA")
//        }
//        else {
//            NSLog("🔴 This IS NOT In a MA")
//        }
//    }
//
//}
