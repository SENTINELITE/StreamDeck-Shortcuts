import Foundation
import StreamDeck
import Sentry
import OSLog

let logger = Logger(subsystem: "StreamDeckShortcuts-2-Alpha", category: "Main")

@main
class StreamDeckShortcuts: PluginDelegate { //Type,  'CounterPluginXYZ' does not conform to protocol 'PluginDelegate'
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
    
    static var codePath: String = StreamDeckShortcuts.executableName
    
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
        logger.debug("😡 Entry.swift")
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
