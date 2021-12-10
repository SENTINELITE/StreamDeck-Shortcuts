//
//  analytics.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 11/27/21.
//

import Foundation
import Metal
import TelemetryClient
import CryptoKit

//let deviceType = "StreamDeck XL"
//let modelName = "Macmini9,1"

// SearchRefs = 0  |  TextFieldRefs = 0  |  DropdownRefs = 0
//^ Send the Data, then clear the cache | Need to save the cache, incase the user closes the app instead of firing off the KeyDown event

func initalizeTD () {
    let configuration = TelemetryManagerConfiguration(appID: "0D606580-553F-4148-978A-B367B2A68C04")
    
#warning("🟥 🟥 🟥 --- We need to disable test mode when we launch the app!!! --- 🟥 🟥 🟥")
    configuration.testMode = false
    configuration.showDebugLogs = false
    
    Task {
        async let uuid = getMacSerialNumber()
        configuration.defaultUser = await uuid
    }
    
    TelemetryManager.initialize(with: configuration)
}

//func sendSignal () {
//
//}

func doXy (passedIn: [String:String]) {
    
    
        TelemetryManager.send("cliTestSent", with: //shortcutSignal
                                passedIn
                              //        "deviceType": deviceName,
                              //        "isAccessOn": String(settingX.isX),
                              //        "accessVoice": String(settingX.xVoice),
                              //        "accessHoldTime": String(settingX.xTime),
                              //        "isForcedTitle": String(settingX.isForcedTitle),
                              //        "modelName": modelName,
                              //        "shortcutsFolderCount": String(shortcutsMapped.count), //This (shortcutsMapped) is all shortcuts & folders! We only want unique folders...
                              //        "totalStreamDeckShortcutsKeys": String(newKeyIds.keys.count)
                              
                              
        )
        NSLog("📶 sent signal...")
    // Reset the refs, as we've sent their cache
    userPrefs.searchRefs = 0
    userPrefs.textFieldRefs = 0
    userPrefs.dropdownRefs = 0
    savePrefrences(filePath: userSettingsFilePath)
    
}
func sendSignal () {
    
    //Await fetchStats...
    Task {
        async let payloadX = fetchAnalytics()
        signalPayloadToSendTop = await payloadX
        doXy(passedIn: await payloadX)
    }
    
//    if (!signalPayloadToSendTop.isEmpty) {
//        TelemetryManager.send("cliTestSent", with:
//                                signalPayloadToSendTop
//                              //        "deviceType": deviceName,
//                              //        "isAccessOn": String(settingX.isX),
//                              //        "accessVoice": String(settingX.xVoice),
//                              //        "accessHoldTime": String(settingX.xTime),
//                              //        "isForcedTitle": String(settingX.isForcedTitle),
//                              //        "modelName": modelName,
//                              //        "shortcutsFolderCount": String(shortcutsMapped.count), //This (shortcutsMapped) is all shortcuts & folders! We only want unique folders...
//                              //        "totalStreamDeckShortcutsKeys": String(newKeyIds.keys.count)
//
//
//        )
//        NSLog("📶 sent signal...")
//    }
//    else {
//        NSLog("📶 Signal was empty??? Not sure why!")
//    }
//    // Reset the refs, as we've sent their cache
//    userPrefs.searchRefs = 0
//    userPrefs.textFieldRefs = 0
//    userPrefs.dropdownRefs = 0
//    savePrefrences(filePath: userSettingsFilePath)
}

var signalPayloadToSend = [String:String]()
var signalPayloadToSendTop = [String:String]()

func fetchAnalytics() async -> [String:String]{
    let listOfFolders_ = analyticFunc(args: ["list", "--folders"]).split(whereSeparator: \.isNewline).map(String.init) //Creates an array based off of the input StringanalyticFunc
    
    var modelName = modelIdentifier()! // Macmini 9,1
    modelName = modelName.replacingOccurrences(of: "\0", with: "", options: NSString.CompareOptions.literal, range: nil)
    
    let cpuName = HWInfo.CPU.brandString()!
    let ram = String(ramInGigaBytes) + " GB"
    
    //  --------------------------------------------
    //  | Fetch GPUs (eg Apple M1, AMD Radeon XYZ) |
    //  --------------------------------------------
    
    let gpuCount = String(MTLCopyAllDevices().count) //Total GPU count
    let defaultGpuName = MTLCopyAllDevices()[0].name //Name of the Default GPU
    
    //-----------------------------  Fetch Shortcut Info  -----------------------------
    
    
    fetchCount() //Gathers the Shortcut with the longest amount of Actions
    //Get Shortcut's longest Actions
    let longestAction = String(actionSize[0])
    
    //Get Total Shortcuts Count
    let totalShortcuts = shortcutsMapped.keys.count
    
    //Get Total Folder Count
    let totalFolderCount = listOfFolders_.count
    
    //Total StreamDeck Shortcuts Keys
    let totalStreamDeckShortcutsKeys = newKeyIds.keys.count
    
    //Query all Keys, to see how many duplicate keys user's are using
    let uniques = Dictionary(grouping:newKeyIds.values){$0}.filter{$1.count==1}.map{$0.0}
    let duplicateKeysCount = (totalStreamDeckShortcutsKeys - uniques.count)
    
    
//    for d in devicesX {
//        if (d.key == device) {
//            deviceName = d.value
//            NSLog("XOD  New Device Name: \(deviceName)")
//        }
//        NSLog("XOD Device payloads: \(d)")
//        NSLog("XOD Device Debvug |||| Device: \(device), deviceName\(deviceName)")
//    }
    
    signalPayloadToSend.updateValue(modelName, forKey: "modelName")
    signalPayloadToSend.updateValue(cpuName, forKey: "cpuName")
    signalPayloadToSend.updateValue(ram, forKey: "ram")
    signalPayloadToSend.updateValue(gpuCount, forKey: "gpuCount")
    signalPayloadToSend.updateValue(defaultGpuName, forKey: "defaultGPU")
    signalPayloadToSend.updateValue(String(totalShortcuts), forKey: "totalShortcuts")
    signalPayloadToSend.updateValue(String(totalFolderCount), forKey: "totalFolderCount")
    signalPayloadToSend.updateValue(String(totalStreamDeckShortcutsKeys), forKey: "totalStreamDeckShortcutsKeys")
    signalPayloadToSend.updateValue(String(duplicateKeysCount), forKey: "duplicateKeysCount")
    signalPayloadToSend.updateValue(String(longestAction), forKey: "longestAction")
    signalPayloadToSend.updateValue(String(userPrefs.isAccessibility), forKey: "isAccessOn")
    signalPayloadToSend.updateValue(String(userPrefs.isForcedTitle), forKey: "isForcedTitle")
    signalPayloadToSend.updateValue(String(devicesX.count), forKey: "deviceCount")
    signalPayloadToSend.updateValue(deviceName, forKey: "deviceType")
    
    
    if (userPrefs.isAccessibility) {
        signalPayloadToSend.updateValue(String(userPrefs.accessibilityVoice), forKey: "accessVoice")
        signalPayloadToSend.updateValue(String(userPrefs.accessibilityHoldDownTime), forKey: "accessHoldTime")
    }
    
    if (userPrefs.searchRefs > 0) {
        signalPayloadToSend.updateValue(String(userPrefs.searchRefs), forKey: "searchRefs")
    }
    
    if (userPrefs.textFieldRefs > 0) {
        signalPayloadToSend.updateValue(String(userPrefs.textFieldRefs), forKey: "textFieldRefs")
    }
    
    if (userPrefs.dropdownRefs > 0) {
        signalPayloadToSend.updateValue(String(userPrefs.dropdownRefs), forKey: "dropdownRefs")
    }
    //Signlat....  SearchRefs
    return signalPayloadToSend
}



// SearchRefs = 0  |  TextFieldRefs = 0  |  DropdownRefs = 0
//^ Send the Data, then clear the cache | Need to save the cache, incase the user closes the app instead of firing off the KeyDown event


//🖥️ Computer Model Identifier
//🖥️ COmputer RAM, CPU, GPU

//  -----------------------------------------------------
//  | Fetch Model Name (eg Macmini 9,1 MacbookPro 13,1) |
//  -----------------------------------------------------

func modelIdentifier() -> String? {
    let service: io_service_t = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
    let cfstr = "model" as CFString
    if let model = IORegistryEntryCreateCFProperty(service, cfstr, kCFAllocatorDefault, 0).takeUnretainedValue() as? NSData {
        if let nsstr =  NSString(data: model as Data, encoding: String.Encoding.utf8.rawValue) {
            return nsstr as String
        }
    }
    return nil
}

//print(gpuCount, defaultGpuName)


//  -----------------------------------
//  | Fetch RAM Count (eg 16GB, 64GB) |
//  -----------------------------------

let ramInBytes = ProcessInfo.processInfo.physicalMemory

let ramInGigaBytes = (ramInBytes / 1073741824) //Divided by 1024 / 1024 / 1024


//  --------------------------------------------------------
//  | Fetch CPU Name (eg Apple M1 Max, Intel Core i5-xxxx) |
//  --------------------------------------------------------

//From Github. Available as a Swift Package
public final class HWInfo {
    
    ///Gets a `String` from the `sysctlbyname` command
    public static func sysctlString(_ valueName: String, bufferSize: size_t) -> String? {
        var ret = [CChar].init(repeating: 0, count: bufferSize)
        
        var size = bufferSize
        
        let res = sysctlbyname(valueName, &ret, &size, nil, 0)
        
        return res == 0 ? String(utf8String: ret) : nil
    }
    
    ///Class used to gather CPU Info
    public final class CPU {
        
        //String getting functions
#if os(macOS)
        ///Gets a `String` from the sysctl machdep.cpu
        public static func sysctlMachdepCpuString(_ valueName: String, bufferSize: size_t) -> String? {
            return sysctlString("machdep.cpu." + valueName, bufferSize: bufferSize)
        }
        
        ///Gets the brand name for the current CPU
        public static func brandString() -> String? {
            return sysctlMachdepCpuString("brand_string", bufferSize: 256)
        }
#endif
        
    }
}
#warning("Not being used, delete")
func analyticFunc(args: [String]) -> String {
    let shortcutsCLI = Process()
    let pipe = Pipe()
    shortcutsCLI.standardOutput = pipe
    shortcutsCLI.standardError = pipe
    
    shortcutsCLI.executableURL = URL(fileURLWithPath: "/usr/bin/shortcuts")
    shortcutsCLI.arguments = args
    shortcutsCLI.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    shortcutsCLI.waitUntilExit()
    //    NSLog("Finshed running With:  \(shortcutsCLI.arguments)")
    return output
}

var actionSize: [Int] = []

func fetchCount() {
    
    
    
    let script = """
    tell application "Shortcuts Events"
            get the action count of every shortcut
    end tell
"""
    let args: [String] = ["-e", script]
    
    let task = Process()
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    
    task.launchPath = "/usr/bin/osascript"
    task.arguments = args
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    var arrarX = output.replacingOccurrences(of: "\n", with: "", options: NSString.CompareOptions.literal, range: nil)
    arrarX = arrarX.replacingOccurrences(of: " ", with: "", options: NSString.CompareOptions.literal, range: nil)
    
    let StringRecordedArr = arrarX.components(separatedBy: ",")
    let xpie = StringRecordedArr.map { Int($0)!}
    for num in xpie {
        actionSize.append(num)
    }
    
    actionSize = actionSize.sorted { $0 > $1 } //Sorts Array from high -> Low.
}



func getMacSerialNumber() async -> String {
    var serialNumber: String? {
        let platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice") )
        
        guard platformExpert > 0 else {
            return nil
        }
        
        guard let serialNumber = (IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            return nil
        }
        
        IOObjectRelease(platformExpert)
        
        let serialAsData = Data(serialNumber.utf8)
        let hashedSerialNum = SHA256.hash(data: serialAsData)
        let hashSerialNumAsString = hashedSerialNum.compactMap { String(format: "%02x", $0) }.joined()

        return hashSerialNumAsString
    }
    
    return serialNumber ?? "Unknown"
}
