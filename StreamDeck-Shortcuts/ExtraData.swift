//
//  ExtraData.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 8/10/23.
//

import Foundation
import AppKit

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
    case globalSettingsUpdated // A Global setting has been changed
    case newVoiceSelected
}


struct sdsSettings: Codable {
    var shortcut: String
}

struct GlobalSettingsUpdated: Codable {
//    let isForcedTitle: Bool
//    let isAcces: Bool
    
    let isForcedTitleLocal: Bool
    let isForcedTitleGlobal: Bool
    let isAccesLocal: Bool
    let isAccesGlobal: Bool
    let isHoldTimeGlobal: Bool
    let accessHoldTime: Double
    let accessSpeechRateGlobal: Int
    let isHoldTime: Bool
    let isDoubleTripleTap: Bool
    let timeBetweenTaps: Double
//    let accessibilityVoicesGlobal: Voice
    
}


//TODO: Change SD Key Image | Not implemented
func updateImage() {
    
    //Oops, I left my name here! 😅
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
//    setTitle(to: randomImage)
//    setImage(to: image)
}
