//
//  sdsGlobalSettings.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 8/11/23.
//

import Foundation
import StreamDeck

// Separate keys for different settings
struct ForcedTitleGlobalKey: GlobalSettingKey {
    static let defaultValue: Bool = false
}

struct AccessibilityGlobalKey: GlobalSettingKey {
    static let defaultValue: Bool = false
}

struct HoldTimeGlobalKey: GlobalSettingKey {
    static let defaultValue: Bool = false
}

extension GlobalSettings {
    @MainActor
    var isForcedTitleGlobal: Bool {
        get { self[ForcedTitleGlobalKey.self] }
        set { self[ForcedTitleGlobalKey.self] = newValue }
    }
    
    var isAccessibilityGlobal: Bool {
        get { self[AccessibilityGlobalKey.self] }
        set { self[AccessibilityGlobalKey.self] = newValue }
    }
    
    var isHoldTimeGlobal: Bool {
        get { self[HoldTimeGlobalKey.self] }
        set { self[HoldTimeGlobalKey.self] = newValue }
    }
}
