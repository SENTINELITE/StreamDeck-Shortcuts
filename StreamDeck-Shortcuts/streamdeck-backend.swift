//
//  File.swift
//
//
//  Created by Kirk Land on 11/7/21.
//

import Foundation
import StreamDeck

var accessKeysToProcess = [String : Bool]()
var deviceName = "N/A"

var devicesX = [String : String]()
//The device is passed into every func, so we know which device the press originated from. This just helps us know the name of the device.
// ["D1A5DFBEA210B6A82B5E5FB2F4488E6A": "Stream Deck XL", "D1A5DFBEA210B6A82B5E5FB2F4488E6A": "Stream Deck Mobile"]


// getSettings calls ->  didReceiveSettings which *should* call -> sendToPropertyInspector?


// SelectedFolder -> Func SendNewShortcuts() -> SendToPI!
class CounterPlugin: StreamDeckPlugin {
    
    
    //  🔷----------------------------------------------------- -----------------
    //  | deviceDidConnect: Load the user's settings, create helper deviceName. |
    //  ----------------------------------------------------- -------------------
    
    //TODO: This is currently performing this 1 x the connected amount of devices!
    override func deviceDidConnect(_ device: String, deviceInfo: DeviceInfo) {
        NSLog("Device: \(device )")
        NSLog("DeviceInfo: \(deviceInfo)")
        deviceName = deviceInfo.name
        //Log each device that connected.
        
        //Add the connected device to the list of known devices
        devicesX.updateValue(deviceInfo.name, forKey: device)
        
        
        if (!loadedPrefs) {
            Task {
                await loadPrefrences(filePath: keySettingsFilePath)
                await loadPrefrences(filePath: userSettingsFilePath)
            }
            
            if (keySettingsFilePath.isFileURL)
            {
                NSLog("FP is Valid: \(keySettingsFilePath)")
            }
            else {
                NSLog("FP Not Valid: \(keySettingsFilePath)")
            }
            if (newKeyIds.keys.contains("LoadingErrorKey")) {
                newKeyIds.removeValue(forKey: "LoadingErrorKey")
                newKeyIds.removeValue(forKey: "type")
                savePrefrences(filePath: keySettingsFilePath)
            }

            loadedPrefs = true
            //TODO: Try to get settings for each known context, if we get an error, this context no longer exists, remove it from the file!
        }
    }
    
    
    //  🔷----------------------------------------------------- ---------------
    //  | accessKeyProcess: The main logic behind the Accessbility feature... |
    //  ----------------------------------------------------- -----------------
    
    func accessKeyProcess (context: String) {
#warning("Allow for floating Numbers!     |     We also need to check/mark extra calls of the same context as stale!")
        var curTime = Int(userPrefs.accessibilityHoldDownTime)
        for _ in 0..<Int(userPrefs.accessibilityHoldDownTime) {
            if (accessKeysToProcess.keys.contains(context)) {
                curTime -= 1
                setTitle(in: context, to: "cur: \(curTime)")
                sleep(1)
            }
            else {
                setTitle(in: context, to: "🚨 Canceled")
                sleep (1)
                if (userPrefs.isForcedTitle) {
                    for key in newKeyIds {
                        if (key.key == context) {
                            setTitle(in: context, to: key.value)
                        }
                    }
                }
                return
            }
        }
        
        if (accessKeysToProcess.keys.contains(context)) {
            for key in newKeyIds {
                if (key.key == context) {
                    Task {
                        async let xxvd =  RunShortcut(shortcutName: key.value)
                        Task {
                            let delay = await delayedStartup(context: context)
                        }
                        showOk(in: context)
                    }
                }
            }
        }
        else {
            setTitle(in: context, to: "")
            showAlert(in: context)
        }
        
    }
    
    func delayedStartup(context: String) async {
        await Task.sleep(1 * 1_000_000_000)
        if (userPrefs.isForcedTitle) {
            for key in newKeyIds {
                if (key.key == context) {
                    setTitle(in: context, to: key.value)
                }
            }
        }
        else {
            setTitle(in: context, to: "")
        }
    }
    
    //  ----------------------------------------------------- ----------------------------------------------------- ----------------------------------------------------- --
    //  | OnKey Appears: Check if we need to display the ForcedTitle. TODO: We need to add line breaks, if the text is too big, but I don't think the API allows for that? |
    //  ----------------------------------------------------- ----------------------------------------------------- ----------------------------------------------------- --
    
    override func willAppear(action: String, context: String, device: String, payload: AppearEvent) {
//        getSettings(in: context)
//        if (userPrefs.isForcedTitle) {
//            for key in newKeyIds {
//                if (key.key == context) {
//                    setTitle(in: context, to: key.value)
//                }
//            }
//        }
//        else {
//            setTitle(in: context, to: "")
//        }
        
        
        Task {
            let delay = await delayedStartup(context: context)
        }
        
        
        
        //        if (!newKeyIds.keys.contains(context)) {
        //            NSLog("🔥 ❄️ 🔥 ❄️ 🔥 ❄️ Context Doens't exist, fetching settings from the backend...")
        ////            newKeyIds.updateValue(<#T##value: String##String#>, forKey: <#T##String#>)
        //            getSettings(in: context)
        //        }
    }
    
    //  🔷---------------------------------------------------- ----------------------------------------------------- ---------------------------
    //  | OnKeyDown: Check if Accessbility is on, if not just run the Shortcut, if it is, then handle some of that logic. We also sendSignal() |
    //  ----------------------------------------------------- ----------------------------------------------------- ----------------------------
    
    override func keyDown(action: String, context: String, device: String, payload: KeyEvent) {
        NSLog("Key was pressed down!")
        sendSignal()
        
        //        sendToPropertyInspector(context: context, action: action, payload: ["type": "updateSettings", "shortcutName": "This_is_from_the_Backend!"])
        //        NSLog("About to send PI data in a loop! :)")
        //        sendToPlugin(context: context, action: action, payload: ["type": "updateSettings", "shortcutName": "This_is_from_the_Backend!"])
        
        if(newKeyIds.keys.contains(context)) {
            for key in newKeyIds {
                if (key.key == context) {
                    if(userPrefs.isAccessibility == true) {
                        Task {
                            async let shelled = shellTest("-v\(userPrefs.accessibilityVoice)", "\(key.value)") //Bugs out & causes the program to crash, after the 2nd action?
                            accessKeysToProcess.updateValue(true, forKey: context)
                            accessKeyProcess(context: context)
                        }
                    }
                    else {
                        Task {
                            async let xxvd =  RunShortcut(shortcutName: key.value)
                        }
                    }
                }
            }
        }
        else {
            showAlert(in: context)
        }
        
        
        //        showOk(in: context)
        //Data that's being pushed to the WS.
        //["event": "showOk", "context": "F4C0705EB6078CBFF14F46088C0FB726"]
        
        //        setTitle(in: context, to: "TestNewTitle")
        //Data that's being pushed to the WS.
        //["context": "F4C0705EB6078CBFF14F46088C0FB726", "event": "setTitle", "payload": ["title": "TestNewTitle"]]
    }
    
    
    //  🔷---------------------------------------------------- ----------------------------------------------------- ----------------------------------------------------- ----------------------
    //  | OnKeyUp: Check if Accesilbity list has anything in it, if it does, remove it. TODO: Better handling of exiting the loop, if the shortcut has been cancled/the button has been let up. |
    //  ----------------------------------------------------- ----------------------------------------------------- ----------------------------------------------------- -----------------------
    
    override func keyUp(action: String, context: String, device: String, payload: KeyEvent) {
        accessKeysToProcess.removeValue(forKey: context) //if SayVoice == false, don't remove?
    }
    
    
    //  🔷---------------------------------------------------- ----------------------------------------------------- ----------------------------------------------------- --------------------------------
    //  | didReceiveSettings: Fetch all the shortcuts & their hiearchy. See if the Key's (Elgato) saved settings match that of our custom file .json file. If not correct our file. This was a workaround |
    //  | /fix for copy/pasting & moving keys around. Maybe rework our method more? We want to keep around the .json file for easy access to the accessbility's needed shortcut namee & TD.               |
    //  ----------------------------------------------------- ----------------------------------------------------- ----------------------------------------------------- ---------------------------------
    
    override func didReceiveSettings(action: String, context: String, device: String, payload: SettingsEvent.Payload) {
        
        //Send initial settings!
        //Get all of the shortcuts & their hiearchy.
        processShortcuts()
        listOfCuts = listOfCuts.sorted() //Sort From A-Z | Are we still using this? TODO: We should filter more of the search stuff over on the swift side.
        
        for key in newKeyIds {
            if (key.key == context) {
                savedShortcut = key.value
            }
        }
        
        if(newKeyIds.keys.contains(context)) {
            NSLog("We already have this key")
        }
        else {
            NSLog(" 🌚 This needs to be handled. We copied?.... ContexT: \(context) With new Shortcut: \(savedShortcut)")
            newKeyIds.updateValue(savedShortcut, forKey: context)
            savePrefrences(filePath: keySettingsFilePath)
        }
        
        //
        var toPass = ""
        for i in payload.settings {
            NSLog("setting i.value \(i.value)") //Logs: updateSettings | NewSettings
            NSLog("setting i.key \(i.key)") //Logs:     type           | shortcutName
            if (i.key == "shortcutName") {
                toPass = i.value
            }
        }
        
        //Send Key's Data to the PI
        sendToPropertyInspector(in: context, action: action, payload:
                                    ["type": "updateSettings", "shortcutName": "\(toPass)", "shortcuts": "\(listOfCuts)",
                                     "shortcutsFolder": "\(shortcutsFolder)", "voices": "\(listOfSayVoices)",
                                     "mappedDataFromBackend": "\(shortcutsMapped)",
                                     "isSayvoice": "\(userPrefs.isAccessibility)", "sayHoldTime": "\(userPrefs.accessibilityHoldDownTime)",
                                     "sayvoice": "\(userPrefs.accessibilityVoice)", "isForcedTitle": "\(userPrefs.isForcedTitle)"
                                    ])
        
        //Helper Title for Debuggindg
//        setTitle(in: context, to: "❄️ \(toPass)")
        
        //IF the .json key's value poperty doesn't match, correct that.
        if (toPass != savedShortcut) {
            NSLog("🟡 We've updated the shortuct, to match ELGATO's Settings! contexT: \(context), toPass: \(toPass), from staleShortcut: \(savedShortcut)")
            newKeyIds.updateValue(toPass, forKey: context)
            savePrefrences(filePath: keySettingsFilePath)
        }
    }
    
    override func propertyInspectorDidAppear(action: String, context: String, device: String) {
        //TODO: We don't need this anymore???
        
        getSettings(in: context)
        //        if (newKeyIds.keys.contains(context)) {
        //        sendToPropertyInspector(in: context, action: action, payload:
        //                                    ["type": "updateSettings", "shortcutName": "\(savedShortcut)", "shortcuts": "\(listOfCuts)",
        //                                     "shortcutsFolder": "\(shortcutsFolder)", "voices": "\(listOfSayVoices)",
        //                                     "mappedDataFromBackend": "\(shortcutsMapped)",
        //                                     "isSayvoice": "\(userPrefs.isAccessibility)", "sayHoldTime": "\(userPrefs.accessibilityHoldDownTime)",
        //                                     "sayvoice": "\(userPrefs.accessibilityVoice)", "isForcedTitle": "\(userPrefs.isForcedTitle)"
        //                                    ])
        //    }
        //        else {
        //            setTitle(in: context, to: "rawSettings")
        //            getSettings(in: context)
        //        }
    }
    
    //    override func didReceiveSettings(action: String, context: String, device: String, payload: SettingsEvent.Payload) {
    //        NSLog("🔥 ❄️ 🔥 ❄️ 🔥 ❄️ EMERGENCT \(payload.settings)")
    //
    //        sendToPropertyInspector(in: context, action: action, payload:
    //            ["type": "updateSettings", "shortcutName": "\(savedShortcut)", "shortcuts": "\(listOfCuts)",
    //             "shortcutsFolder": "\(shortcutsFolder)", "voices": "\(listOfSayVoices)",
    //             "mappedDataFromBackend": "\(shortcutsMapped)",
    //             "isSayvoice": "\(userPrefs.isAccessibility)", "sayHoldTime": "\(userPrefs.accessibilityHoldDownTime)",
    //             "sayvoice": "\(userPrefs.accessibilityVoice)", "isForcedTitle": "\(userPrefs.isForcedTitle)"
    //             ])
    //
    //        NSLog("⛄ ❄️ \(savedShortcut), Context: \(context)")
    //        newKeyIds.updateValue(savedShortcut, forKey: context)
    //        savePrefrences(filePath: keySettingsFilePath)
    //    }
    
    //    override func sendToPlugin(context: String, action: String, payload: [String : String]) {
    //        NSLog("New Payload: \(payload)")
    //    }
    
    
    //  🔷---------------------------------------------------- ----------------------------------------------------- -------------------------------
    //  | handleForcedTitle: If ForcedTitle is on, then turn on the title for all visble contexts, if not or it get's turned off, remove all text. |
    //  ----------------------------------------------------- ----------------------------------------------------- --------------------------------
    
    func handleForcedTitle() {
        if(userPrefs.isForcedTitle) {
            instanceManager.instances.forEach {
                for key in newKeyIds {
                    if (key.key == $0.context) {
                        setTitle(in: $0.context, to: key.value)
                    }
                }
            }
        }
        else {
            instanceManager.instances.forEach {
                setTitle(in: $0.context, to: "")
            }
        }
        
        instanceManager.instances.forEach {
            NSLog("Known Contexts: \($0.context), Count: \(instanceManager.instances.count)")
        }
    }
    
    
    //  🔷---------------------------------------------------- ---------------------
    //  | sentToPlugin: This is where we recieve stuff from the PropertyInspector. |
    //  ----------------------------------------------------- ----------------------
    
    override func sentToPlugin(context: String, action: String, payload: [String : String]) {
        NSLog("We got sent something from the PI!")
        NSLog("""
                We got sent something from the PI,
                Context: \(context)
                action: \(action)
                payload: \(payload)
"""
        )
        
        //        var payloadMapped = [String:Any]()
        
        
        //Are we using these???? TODO: Check if this are needed!
        let decodedPayload = payload.map { $0.value} //["TestCut_New1", "Samantha", "updateSettings"]
        let decodedPayloadKey = payload.map { $0.key} //["shortcutName", "sayvoice", "type"]
        //        NSLog("⚠️ DPayload: \(decodedPayload)")
        //        //⚠️ DPayload: ["requestSettings"]
        //        NSLog("⚠️ DPayload Key: \(decodedPayloadKey)")
        //
        //        NSLog("⚠️ DPayload 2 [0]: \(decodedPayload[0])")
        
        
        for i in payload {
            if (i.key == "type") {
                switch i.value {
                case "requestSettings":
                    requestSettings() // Send settings to the PI!
                    if (newKeyIds.keys.contains(context) == false) {
                        newKeyIds.updateValue(i.value, forKey: i.key)
                        updateSettings(context: context, action: action, payload: payload)
                    }
                    
                case "shortcutsOfFolder":
                    shortcutsFolder
                case "updateSettings":
                    updateSettings(context: context, action: action, payload: payload) //Save User's settings to disk
                    setSettings(in: context, to: payload)
                        handleForcedTitle() //TODO: Move this call & the function outside of CounterPlugin. We should call this from Update Settings? This may not work due to the Instance Manager
                default:
                    NSLog("❄️ Switch Case that's not covered \(i.value)")
                }
            }
            //            if (i.key == "shortcutName") {
            //                theValueToTrade = i.value
            //                updateSettings(context: context, action: action, payload: payload)
            //            }
            //            else if (i.key == "sayvoice") {
            //                theValueToTradeVoice = i.value
            //            }
            //            else if (i.key == "type") {
            //                if (i.value == "requestSettings") { //The value of the payload
            //                    requestSettings()
            //                }
            //                else if (i.value == "shortcutsOfFolder") { //The value of the payload
            //                    requestShortcutsFromFolder()
            //                }
            //                else { //The value of the payload
            //                    NSLog("this was the sent type.id: \(i.value)")
            //                }
            //            }
        }
        
        //        for value in decodedPayload {
        //            payloadMapped.updateValue(decodedPayload[], forKey: <#T##String#>)
        //        }
        //        payloadMapped = [decodedPayloadKey : decodedPayload]
        //
        NSLog("payload stuff \(decodedPayload)")
        
#warning("this line was causing a hard crash, with decodedPayload[[1] being out of bounds.")
        //        NSLog("payload stuff \(decodedPayload[0]) \(decodedPayload[1])")
        
        //        theValueToTrade = decodedPayload[0]
        if (decodedPayload[0] == "requestSettings") {
            requestSettings()
            let json = """
            {
                "event": inRegisterEvent,
                "uuid": inPluginUUID
            }
            """
            
            
            //Whole JSON Message: {"action":"yat.increment","event":"sendToPropertyInspector","context":"89C7482603E12CA379788EFB1A6349DD","payload":{"shortcutName":"efgwe","type":"updateSettings"}}
            // PAYLOAD: {shortcutName: "efgwe", type: "updateSettings"}
            //            sendToPropertyInspector(context: context, action: action, payload: ["type": "updateSettings", "shortcutName": "This_is_from_the_Backend!"])
            
        }
        else {
            NSLog("⚠️ Unknown Payload: \(decodedPayload)")
            NSLog("⚠️ Unknown Payload: \(decodedPayload[0])")
        }
        //"shortcutsOfFolder"
        if (decodedPayload[0] == "shortcutsOfFolder") {
            requestShortcutsFromFolder()
        }
    }
    
}

//  🔷---------------------------------------------------- -----------------
//  | TODO: We should move the rest of the (below) code to another file... |
//  ----------------------------------------------------- ------------------


//  🔷---------------------------------------------------- ----------------------------------------------------- -----------------------------------------------------
//  | updateSettings: Handle the recieved payload & saving logic. This is the bulk of the program. Think of it like the highway.
//  ----------------------------------------------------- ----------------------------------------------------- -----------------------------------------------------

// Func inside of PI
func updateSettings(context: String, action: String, payload: [String: String]) {
    //    theValueToTrade = payload
    NSLog("❄️ Updating the settings with \(payload)")
    let decodedPayload = payload.map { $0.value} //["TestCut_New1", "Samantha", "updateSettings"]
    let decodedPayloadKey = payload.map { $0.key} //["shortcutName", "sayvoice", "type"]
    
    for i in payload {
        switch i.key {
        case "shortcutName":
            NSLog("Key's value found \(i.value)")
            newKeyIds.updateValue(i.value, forKey: context)
            savePrefrences(filePath: keySettingsFilePath)
            
            //            for key in newKeyIds {
            //                if (key.key == context) {
            //                    newKeyIds.updateValue(i.value, forKey: context)
            //                    NSLog("Key is here! \(i.value)")
            //                }
            //                else {
            //                    newKeyIds.updateValue(i.value, forKey: context)
            //                    NSLog("Key is not here, adding! \(i.value)")
            //                }
            //                savePrefrences(filePath: keySettingsFilePath)
            ////                savePrefrences(filePath: userSettingsFilePath)
            //            }
        case "sayvoice":
            NSLog("Say Voice: \(i.value)")
            userPrefs.accessibilityVoice = i.value
        case "isSayvoice":
            NSLog("isSayvoice, not doing anything with it though")
            userPrefs.isAccessibility = Bool(i.value)!
            //        case "isAccessibility":
            //            isAccessibility = Bool(i.value)!
            //            settingX.isX = Bool(i.value)!
            //            NSLog("   👻 isSay: \(isAccessibility)")
#warning("Need to convert String > Bool | Could Crash App from force unwarp!")
        case "isForcedTitle":
            userPrefs.isForcedTitle = Bool(i.value)!
            NSLog("isForcedTitle: \(i.value)")
            savePrefrences(filePath: userSettingsFilePath)
        case "sayHoldTime":
            //            accessibilityHoldDownTime = Double(i.value)!
            userPrefs.accessibilityHoldDownTime = Float(i.value)!
            NSLog("   👻 HoldTime: \(userPrefs.accessibilityHoldDownTime)")
            savePrefrences(filePath: userSettingsFilePath)
        case "refType":
            if(i.value == "textFieldRefs") {
                userPrefs.textFieldRefs += 1
            }
            else if (i.value == "searchRefs") {
                userPrefs.searchRefs += 1
            }
            else if (i.value == "dropdownRefs"){
                userPrefs.dropdownRefs += 1
            }
            else {
                NSLog("No Ref...")
            }
        case "updateSettings":
            NSLog("Update Settings is not cared for here...")
        default:
            NSLog("Nothing to save! The Value: \(i.value) With Key: \(i.key)")
        }
    }
    
    
}


func requestShortcutsFromFolder() {
    NSLog("❄️ requestShortcutsFromFolder")
}

// Func inside of PI
func requestSettings() {
    NSLog("❄️ Fetching the Requested settings")
    
}

//TODO: Do We need these functions? Leftover Skeleton code? setSettings/sendSettings... & sendEventTest...
//func sendSettings(action: String, context: String) {
//
//}
//
//func setSettings(context: String, jsonPayload: String) {
//
//}

//------

//func sendEventTest(_ eventType: SendableEventKey, context: String?, payload: [String: Any]?, action: String?) {
//
//    var event: [String: Any] = [
//        "event": eventType.rawValue
//    ]
//
//    event["context"] = context
//    event["payload"] = payload
//    event["action"] = action
//
//    guard JSONSerialization.isValidJSONObject(event) else {
//        NSLog("Data for \(eventType.rawValue) is not valid JSON.")
//        return
//    }
//
//    do {
//        let data = try JSONSerialization.data(withJSONObject: event, options: [])
//
//        task.send(URLSessionWebSocketTask.Message.data(data)) { error in
//            if let error = error {
//                NSLog("ERROR: Failed to send \(eventType.rawValue) event.")
//                NSLog(error.localizedDescription)
//            } else {
//                NSLog("Completed \(eventType.rawValue)")
//            }
//        }
//    } catch {
//        NSLog("ERROR: \(error.localizedDescription).")
//    }
//
//}


