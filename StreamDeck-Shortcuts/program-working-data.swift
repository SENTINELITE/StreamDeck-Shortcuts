//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation

var savedShortcut = "TheDefaultTradedValue"
var theValueToTradeVoice = "TheDefaultTradedValueVoice_DevX"

// shortcuts = [String: String] // [ShortcutName : ShortcutFolder]
var shortcutsFolder = ["placeholder Folder From Backend"]
var listOfSayVoices = ["Samantha", "Victoria", "Alex", "Fred"]

//Send the object of this, to minimize crosstalk.
// shortcuts = [String: String] // [ShortcutName : ShortcutFolder]
var shortcutsMapped = [String:String]() //Creates an Dictionary, with each Shortcut & whether they have a folder.

var listOfCuts = ["List of Shortcuts from Backend"]

var loadedPrefs = false

//var isAccessibility = true
//isSayvoice
//var accessibilityHoldDownTime = 5.0
//var accessibilityVoice = "Samantha"

struct mySettings: Codable {
    var isAccessibility: Bool //isAccessibility
    var accessibilityHoldDownTime: Float //accessibilityHoldDownTime
    var accessibilityVoice: String //accessibilityVoice
    var isForcedTitle: Bool
    var searchRefs: Int
    var textFieldRefs: Int
    var dropdownRefs: Int
}

var userPrefs = mySettings(isAccessibility: true, accessibilityHoldDownTime: 5.0, accessibilityVoice: "", isForcedTitle: false, searchRefs: 0, textFieldRefs: 0, dropdownRefs: 0)

func checkIfKeyExits(keyToLookFor: String) -> String {
    var keyStatus: String = ""
    for key in newKeyIds {
        if (key.key == keyToLookFor) {
            keyStatus = key.value
        }
    }
    if (keyStatus.isEmpty) {
        
    }
    return keyStatus
}
