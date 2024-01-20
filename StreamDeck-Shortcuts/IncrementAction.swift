////
////  IncrementAction.swift
////
////
////  Created by Emory Dunn on 12/19/21.
////
//
//import Foundation
//import StreamDeck
//
//class IncrementAction: Action {
//    typealias Settings = <#type#>
//    
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
//    static var supportedInMultiActions: Bool?
//    
//    static var tooltip: String?
//    
//    static var visibleInActionsList: Bool?
//
//    var context: String
//    
//    var coordinates: Coordinates
//    
//    @Environment(PluginCount.self) var count: Int
//    
//    required init(context: String, coordinates: Coordinates) {
//        self.context = context
//        self.coordinates = coordinates
//    }
//    
//    func keyDown(device: String, payload: KeyEvent<<#S: Decodable & Hashable#>>) {
//        count += 1
//    }
//
//}
//
////
////  File.swift
////
////
////  Created by Emory Dunn on 12/19/21.
////
//
//struct PluginCount: EnvironmentKey {
//    static let defaultValue: Int = 0
//}
//
////@main
//class CounterPlugin: PluginDelegate {
//    
//    // MARK: Manifest
//    static var name: String = "Counter"
//    
//    static var description: String = "Count things. On your Stream Deck!"
//    
//    static var category: String?
//    
//    static var categoryIcon: String?
//    
//    static var author: String = "Emory Dunn"
//    
//    static var icon: String = "Icons/pluginIcon"
//    
//    static var url: URL? = URL(string: "https://github.com/emorydunn/StreamDeckPlugin")
//    
//    static var version: String = "0.2"
//    
//    static var os: [PluginOS] = [.mac(minimumVersion: "10.15")]
//    
//    static var applicationsToMonitor: ApplicationsToMonitor?
//    
//    static var software: PluginSoftware = .minimumVersion("4.1")
//    
//    static var sdkVersion: Int = 2
//    
//    static var codePath: String = CounterPlugin.executableName
//    
//    static var codePathMac: String?
//    
//    static var codePathWin: String?
//    
//    static var actions: [Action.Type] = [
//        IncrementAction.self,
//        DecrementAction.self
//    ]
//    
//    @Environment(PluginCount.self) var count: Int
//
//    required init() {
//        NSLog("CounterPlugin init!")
//    }
//    
//    func keyDown(action: String, context: String, device: String, payload: KeyEvent) {
//        StreamDeckPlugin.shared.instances.values.forEach {
//            $0.setTitle(to: "\(count)", target: nil, state: nil)
//        }
//    }
//
//}
