import Foundation
import StreamDeck
//import Sentry
import OSLog

let logger = Logger(subsystem: "StreamDeckShortcuts-2-Alpha", category: "Main")

@main
class StreamDeckShortcuts: Plugin { //Type,  'CounterPluginXYZ' does not conform to protocol 'PluginDelegate'
    struct Settings: Codable, Hashable {
//        var isForcedTitle: Bool = false
        var isAcces: Bool = false
    }
    // MARK: Manifest
    static var name: String = "StreamDeck Shortcuts BETA"
    
    static var description: String = "Shortcuts allows you to run your Apple Shortcuts within the Elgato StreamDeck ecosystem. This is the beta version, that's under active development."
    
    static var category: String? = "SDS"
    
    static var categoryIcon: String?
    
    static var author: String = "SENTINELITE"
    
    static var icon: String = "Icons/pluginIcon"
    
    static var url: URL? = URL(string: "https://sentinelite.com")
    
    static var version: String = "2.0.0-beta.11"
    
    static var os: [PluginOS] = [PluginOS.macOS("12.0")]
    
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
    
//    @GlobalSetting(\.isForcedTitleGlobal) var isForcedTitleGlobal
//    @GlobalSetting(\.isAccessibilityGlobal) var isAccessibilityGlobal
    
    required init() {
        
        
//        //The initial signal won't send if the program exits too fast.
//        SentrySDK.start { options in
//            options.dsn  = "https://e5b7ab3d23b04542818cc7bbd4a9dc0a@o1114114.ingest.sentry.io/6145162"
//            options.debug = false // Enabled debug when first installing is always helpful
//            options.enableTracing = true
//            options.swiftAsyncStacktraces = true
////            options.tracesSampleRate = 0.1
//        //    options.
//            options.enableSwizzling = false
//        }
        
        logger.debug("😡 Entry.swift | Nemesis-One Shortcuts Plugin initiated!")
        processShortcuts()
        logger.debug("😡 Entry.swift | TD-One About to init!")
        initializeTD()
    }
    
    func didReceiveGlobalSettings(_ settings: Settings) {
        NSLog("🧨 Conduit-Zero")
        NSLog("🧨 Conduit-One Settings: \(settings)")
//        isForcedTitle = settings.isForcedTitle
    }
    
    func willAppear(action: String, context: String, device: String, payload: AppearEvent<Settings>) {
//        count += 1
//        NSLog("Nemesis-One-One with count: \(count)")
//        StreamDeckPlugin.shared.instances.values.forEach {
//            $0.setTitle(to: "\(count)", target: nil, state: nil)
//        }
        NSLog("Nemesis-One-Two SDS - SE - WillAppear V2 Action Instance")
        NSLog("Nemesis-One-Three Payload \(payload)")
        logger.debug("😡 \(PluginCommunication.shared.uuid)")
        
    }
    
//    func propertyInspectorDidAppear(action: String, context: String, device: String) {
//        NSLog("👀  👀Nemesis-One-Three Got Global Settings!")
//        getGlobalSettings()
//        NSLog("👀  DONE  👀Nemesis-One-Three Got Global Settings!")
//    }
    
    func sentToPlugin(context: String, action: String, payload: [String : String]) {
        NSLog("Nemesis-One-Four sentToPlguin \(payload), action: \(action)")
    }
}
