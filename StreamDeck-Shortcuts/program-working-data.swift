//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation

var newData = [ShortcutDataTwo]()
var processRunShortcutTime: String = "nil"
var isCurrentlyProcessingShortcuts = false

var savedShortcut = "TheDefaultTradedValue"
var theValueToTradeVoice = "TheDefaultTradedValueVoice_DevX"

// shortcuts = [String: String] // [ShortcutName : ShortcutFolder]
var shortcutsFolder = ["placeholder Folder From Backend"]

@available(*, deprecated, message: "Move to the ")
var listOfSayVoices = ["Samantha", "Victoria", "Alex", "Fred"]

var accessibilityVoices = ["system", "alloy", "echo", "fable", "onyx", "nova", "shimmer"]

//Send the object of this, to minimize crosstalk.
// shortcuts = [String: String] // [ShortcutName : ShortcutFolder]
var shortcutsMapped = [String:String]() //Creates an Dictionary, with each Shortcut & whether they have a folder.
//var initalShortcutsMapped = [String:String]() //Creates an Dictionary, with each Shortcut & whether they have a folder.

var listOfCuts = ["List of Shortcuts from Backend"]
var listOfFoldersWithShortcuts = [String]()

var loadedPrefs = false

struct mySettings: Codable {
    var isAccessibility: Bool //isAccessibility
    var accessibilityHoldDownTime: Float //accessibilityHoldDownTime
    var accessibilityVoice: String //accessibilityVoice
    var isForcedTitle: Bool
//    var isDeprecatedRunner: Bool
    var searchRefs: Int
    var textFieldRefs: Int
    var dropdownRefs: Int
}
                                                                                                                //, isDeprecatedRunner: false
@available(*, deprecated, message: "Move away from this")
var userPrefs = mySettings(isAccessibility: false, accessibilityHoldDownTime: 5.0, accessibilityVoice: "Samantha", isForcedTitle: false, searchRefs: 0, textFieldRefs: 0, dropdownRefs: 0)


//Currently unused function. We should replace the many key checks with this simple return func.
func checkIfKeyExits(keyToLookFor: String) -> String {
    var keyStatus: String = ""
    for key in newKeyIds {
        if (key.key == keyToLookFor) {
            keyStatus = key.value
        }
    }
    return keyStatus
}


//streamdeck-backend.swift
var deviceName = "N/A"
//
var devicesX = [String : String]()
var devices = [String : String]()
