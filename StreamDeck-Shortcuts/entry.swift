import Foundation
import OSLog
import StreamDeck

let logger = Logger(subsystem: "StreamDeckShortcuts-2-Alpha", category: "Main")

@main
class StreamDeckShortcuts: Plugin {
    
    static var layouts: [SDPlusLayout.Layout] {
        Layout(id: "launch") {
            // The title of the layout
            Text(title: "Current Count")
                .textAlignment(.center)
                .frame(width: 180, height: 24)
                .position(x: (200 - 180) / 2, y: 10)
        }
    }
    
    //Type,  'CounterPluginXYZ' does not conform to protocol 'PluginDelegate'
    struct Settings: Codable, Hashable {
        // var isForcedTitle: Bool = false
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
    
    static var version: String = "2.0.0-beta.12"
    
    static var os: [PluginOS] = [PluginOS.macOS("12.0")]
    
    static var applicationsToMonitor: ApplicationsToMonitor?
    
    static var software: PluginSoftware = .minimumVersion("5.0")
    
    static var sdkVersion: Int = 2
    
    static var codePath: String = StreamDeckShortcuts.executableName
    
    static var codePathMac: String?
    
    static var codePathWin: String?
    
    static var actions: [any Action.Type] = [
        ShortcutAction.self
    ]
    
    //    @GlobalSetting(\.isForcedTitleGlobal) var isForcedTitleGlobal
    //    @GlobalSetting(\.isAccessibilityGlobal) var isAccessibilityGlobal
    
    required init() {
        setupPlugin()
    }
    
    func didReceiveGlobalSettings(_ settings: Settings) {
        shortcutsLogger(message: "🧨 Conduit-Zero")
        shortcutsLogger(message: "🧨 Conduit-One Settings: \(settings)")
        //        isForcedTitle = settings.isForcedTitle
    }
    
    func willAppear(action: String, context: String, device: String, payload: AppearEvent<Settings>) {
        
        //        StreamDeckPlugin.shared.instances.values.forEach {
        //            $0.setTitle(to: "\(count)", target: nil, state: nil)
        //        }
        shortcutsLogger(message: "Nemesis-One-Two SDS - SE - WillAppear V2 Action Instance")
        shortcutsLogger(message: "Nemesis-One-Three Payload \(payload)")
        
        //TODO: Fix this
        //    shortcutsLogger(message: "😡 \(PluginCommunication.shared.uuid)", logLevel: .debug)
    }
    
    //    func propertyInspectorDidAppear(action: String, context: String, device: String) {
    //        shortcutsLogger(message: "👀  👀Nemesis-One-Three Got Global Settings!")
    //        getGlobalSettings()
    //        shortcutsLogger(message: "👀  DONE  👀Nemesis-One-Three Got Global Settings!")
    //    }
    
    func sentToPlugin(context: String, action: String, payload: [String: String]) {
        shortcutsLogger(message: "Nemesis-One-Four sentToPlguin \(payload), action: \(action)")
    }
}
