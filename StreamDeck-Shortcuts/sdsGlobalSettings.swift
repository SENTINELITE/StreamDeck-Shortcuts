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

struct DoubleTripleTapGlobalKey: GlobalSettingKey {
    static let defaultValue: Bool = true
}

struct TimeBetweenTapsGlobalKey: GlobalSettingKey {
    static let defaultValue: Double = 0.2
}

struct AccessSpeechRateGlobalKey: GlobalSettingKey {
    static let defaultValue: Int = 175
}

struct AccessibilityVoiceGlobalKey: GlobalSettingKey {
    static let defaultValue: String = Voice.shimmer.rawValue
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
    
    var isDoubleTripleTapOn: Bool {
        get { self[DoubleTripleTapGlobalKey.self] }
        set { self[DoubleTripleTapGlobalKey.self] = newValue }
    }
    
    var accessSpeechRateGlobal: Int {
        get { self[AccessSpeechRateGlobalKey.self] }
        set { self[AccessSpeechRateGlobalKey.self] = newValue }
    }
    
    var timeBetweenTaps: Double {
        get { self[TimeBetweenTapsGlobalKey.self] }
        set { self[TimeBetweenTapsGlobalKey.self] = newValue }
    }
    
    var accessibilityVoice: String {
        get { self[AccessibilityVoiceGlobalKey.self] }
        set { self[AccessibilityVoiceGlobalKey.self] = newValue }
    }
}
