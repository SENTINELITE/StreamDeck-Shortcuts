//
//  BridgePluginXPCProtocol.swift
//  StreamDeck-Shortcuts-Shared
//
//  Objective-C compatible plugin callback interface for XPC.
//

import Foundation

@objc public protocol StreamDeckBridgePluginXPCProtocol {
    func runShortcut(_ commandData: Data, withReply reply: @escaping (Data?, NSError?) -> Void)
    func updateKey(_ commandData: Data, withReply reply: @escaping (NSNumber?, NSError?) -> Void)
    func currentStatus(withReply reply: @escaping (Data?, NSError?) -> Void)
    func contextDidChange(_ contextID: String, isAvailable: Bool)
}
