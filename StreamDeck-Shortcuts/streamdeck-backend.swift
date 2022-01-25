//
//  File.swift
//
//
//  Created by Kirk Land on 11/7/21.
//

import Foundation
import StreamDeck
import Sentry

var accessKeysToProcess = [String : Bool]()
var deviceName = "N/A"

var devicesX = [String : String]()
var devices = [String : String]()
//The device is passed into every func, so we know which device the press originated from. This just helps us know the name of the device.
// ["D1A5DFBEA210B6A82B5E5FB2F4488E6A": "Stream Deck XL", "D1A5DFBEA210B6A82B5E5FB2F4488E6A": "Stream Deck Mobile"]

var WebSocketDelayForcePIEvent = false
//var firstLaunch = true

// getSettings calls ->  didReceiveSettings which *should* call -> sendToPropertyInspector?



//⚠️ Unknown Payload: ["nil", "", "updateSettings", "true", "0.0", "Samantha", "true"]
//⚠️ Unknown Payload: nil

//⚠️ Unknown Payload: ["true", "Samantha", "Open Apps Bundle", "nil", "0.0", "true", "updateSettings"]
//⚠️ Unknown Payload: true

// SelectedFolder -> Func SendNewShortcuts() -> SendToPI!
class ShortcutsPlugin: StreamDeckPlugin {
    
    
    //  🔷----------------------------------------------------- -----------------
    //  | deviceDidConnect: Load the user's settings, create helper deviceName. |
    //  ----------------------------------------------------- -------------------
    
    //TODO: This is currently performing this 1 x the connected amount of devices!
    override func deviceDidConnect(_ device: String, deviceInfo: DeviceInfo) {
        NSLog("Device: \(device )")
        NSLog("DeviceInfo: \(deviceInfo)")
        NSLog("DeviceInfo.type: \(deviceInfo.type)")
        NSLog("DeviceInfo.type: \(deviceInfo.type.self)")
        NSLog("DeviceInfo.type: \(deviceInfo.type.rawValue)")
        deviceName = deviceInfo.name
        //Log each device that connected.
        
        //Add the connected device to the list of known devices
        devicesX.updateValue(deviceInfo.name, forKey: device)
        devices.updateValue("\(deviceInfo.type)", forKey: device)
        
        
        
        if (!loadedPrefs) {
            Task {
                NSLog("📂 About to load files")
                await loadFiles(fileName: keysFile) //(filePath: keySettingsFilePath)
                await loadFiles(fileName: settingsFile) //(filePath: userSettingsFilePath)
            }
            
//            if (keySettingsFilePath.isFileURL)
//            {
//                NSLog("FP is Valid: \(keySettingsFilePath)")
//            }
//            else {
//                NSLog("FP Not Valid: \(keySettingsFilePath)")
//            }
//            if (newKeyIds.keys.contains("LoadingErrorKey")) {
//                newKeyIds.removeValue(forKey: "LoadingErrorKey")
//                newKeyIds.removeValue(forKey: "type")
//                savePrefrences(filePath: keySettingsFilePath)
//            }
            
            loadedPrefs = true
            //TODO: Try to get settings for each known context, if we get an error, this context no longer exists, remove it from the file!
        }
    }
    
    
    //  🔷----------------------------------------------------- ---------------
    //  | accessKeyProcess: The main logic behind the Accessbility feature... |
    //  ----------------------------------------------------- -----------------
    
    func accessKeyProcess (context: String, action: String) {
#warning("Allow for floating Numbers!     |     We also need to check/mark extra calls of the same context as stale!")
        var curTime = Int(userPrefs.accessibilityHoldDownTime)
        for _ in 0..<Int(userPrefs.accessibilityHoldDownTime) {
            if (accessKeysToProcess.keys.contains(context)) {
                curTime -= 1
                setTitle(in: context, to: "cur: \(curTime)")
                //TODO: We want to skip the first second or two, so we don't overload the audio with too much speech...
                //                Task {
                //                    let timer_X = await accessDelayHelper(timeLeft: 3)
                //                    async let shelled = shellTest("-v\(userPrefs.accessibilityVoice)", "\(timer_X) remaining") //Bugs out & causes the program to crash, after the 2nd action?
                //                }
                sleep(1)
            }
            else {
                setTitle(in: context, to: "🚨 Canceled")
                Task {
                    async let shelled = shellTest("-v\(userPrefs.accessibilityVoice)", "Canceled shortcut!") //Bugs out & causes the program to crash, after the 2nd action?
                }
                sleep (1)
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
                return
            }
        }
        
        if (accessKeysToProcess.keys.contains(context)) {
            for key in newKeyIds {
                if (key.key == context) {
                    Task {
                        async let shelled = shellTest("-v\(userPrefs.accessibilityVoice)", "Running Shortcut!") //Bugs out & causes the program to crash, after the 2nd action?
                        async let xxvd =  RunShortcut(shortcutName: key.value)
                        //TODO: Say when shortcut has been ran. We want this to be on a toggle, as we don't want to overlap a Shortcuts audio, if the user has such a thing.
                        //                                                async let iea =  runFromNewPackage(shortcutToRun: key.value)
                        Task {
                            let delay = try await delayedStartup(context: context, action: action)
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
    
    //    var timeLeft = 0
    //    func accessDelayHelper(timeLeft: Int) async -> Int{
    //        await Task.sleep(1_000_000_000)
    ////        curTime -= 1
    //        var x = timeLeft
    //        x -= 1
    //        return x
    //    }
    
    func delayedStartup(context: String, action: String) async throws {
        try await Task.sleep(nanoseconds: 1_250_000_000)
        if (userPrefs.isForcedTitle) {
            for key in newKeyIds {
                if (key.key == context) {
                    //if (listOfCuts.contains(key.value)) {
                    if (key.value == "" || !listOfCuts.contains(key.value)) { //The
                        showAlert(in: context)
                        try await Task.sleep(nanoseconds: 2_250_000_000)
                        setTitle(in: context, to: "🚨🚨🚨\nMissing!\n⚠️")
                        NSLog("We're Missing the Value for Context: \(context), with value: \(key.value)")
                    }
                    else {
                        setTitle(in: context, to: key.value)
                        NSLog("We have the title for cote3xt: \(context), with value: \(key.value)")
                    }
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
            let delay = try await delayedStartup(context: context, action: action)
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
        NSLog("DEBUG: keyDown() was pressed down!")
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
                            accessKeyProcess(context: context, action: action)
                        }
                    }
                    else {
                        Task {
                            async let xxvd =  RunShortcut(shortcutName: key.value)
                            //                            async let iea =  runFromNewPackage(shortcutToRun: key.value)
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
        NSLog("DEBUG: keyDown() finshed being running!")
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
        
        NSLog("DEBUG: Starting didRecieveSettings()!")
        var isExist = true
        //Send initial settings!
        //Get all of the shortcuts & their hiearchy.
        processShortcuts()
        listOfCuts = listOfCuts.sorted() //Sort From A-Z | Are we still using this? TODO: We should filter more of the search stuff over on the swift side.
        
        for key in newKeyIds {
            if (key.key == context) {
                //Check if the user still has this shortcut in their library! | TODO: We should move this to another function & check everywhere. For instance, we're not checking when the key appears, resulting in the old key's name being displayed to the user!
                if (listOfCuts.contains(key.value)) {
                    savedShortcut = key.value
                    NSLog("🚀 The Shortcuts Exists! \(key.value)")
                }
                else {
                    isExist = false
                    NSLog("🌻 This key has changed names!")
                    //                    savedShortcut = listOfCuts[0] //Set it to the first shortcut in the array.
                    //                    setTitle(in: context, to: savedShortcut)
                }
            }
        }
        
        if(newKeyIds.keys.contains(context)) {
            NSLog("We already have this key")
        }
        else {
            NSLog(" 🌚 This needs to be handled. We copied?.... ContexT: \(context) With new Shortcut: \(savedShortcut)")
            newKeyIds.updateValue(savedShortcut, forKey: context)
            Task {
            async let x =  saveFile(fileName: settingsFile) //(filePath: keySettingsFilePath)
            }
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
        
        var jsToSend = ""
        do {
            let r = try JSONEncoder().encode(shortcutsMapped)
            let jsonString = String(decoding: r, as: UTF8.self)
            NSLog("Mapped from backed, verifying JSON Structure: \(jsonString)")
            NSLog("Mapped from backed, verifying JSON Structure: \(jsonString.debugDescription)")
            jsToSend = jsonString
        } catch {
            SentrySDK.capture(error: error)
            SentrySDK.capture(message: "Failed to encode shortcutsMapped as json, on line 321 of streamdeck-backend.swift")
            NSLog("JSON Structure isn't vald! Error: \(error.localizedDescription)")
        }
        
        
        //Older payload
        //        var payloadToSend = ["type": "updateSettings", "shortcutName": "\(toPass)", "shortcuts": "\(listOfCuts)",
        //                            "shortcutsFolder": "\(shortcutsFolder)", "voices": "\(listOfSayVoices)",
        //                            "mappedDataFromBackend": "\(jsToSend)",
        //                            "isSayvoice": "\(userPrefs.isAccessibility)", "sayHoldTime": "\(userPrefs.accessibilityHoldDownTime)",
        //                            "sayvoice": "\(userPrefs.accessibilityVoice)", "isForcedTitle": "\(userPrefs.isForcedTitle)"
        //                           ]
        
        //        initalShortcutsMapped
//        var jsToSend_initial = ""
//        do {
//            let r = try JSONEncoder().encode(initalShortcutsMapped)
//            let jsonString = String(decoding: r, as: UTF8.self)
//            NSLog("Mapped from backed, verifying JSON Structure: \(jsonString)")
//            NSLog("Mapped from backed, verifying JSON Structure: \(jsonString.debugDescription)")
//            jsToSend_initial = jsonString
//        } catch {
//            NSLog("JSON Structure isn't vald! Error: \(error.localizedDescription)")
//        }
        
        
        //            NSLog(" XO XO About to send init payload")
        //        var payloadToSend = ["type": "updateSettings", "shortcutName": "\(toPass)", "isInitPayload": "true",
        //                                "shortcutsFolder": "\(shortcutsFolder)", "voices": "\(listOfSayVoices)",
        //                                "mappedDataFromBackend": "\(jsToSend_initial)",
        //                                "isSayvoice": "\(userPrefs.isAccessibility)", "sayHoldTime": "\(userPrefs.accessibilityHoldDownTime)",
        //                                "sayvoice": "\(userPrefs.accessibilityVoice)", "isForcedTitle": "\(userPrefs.isForcedTitle)"
        //                               ]
        //        sendToPropertyInspector(in: context, action: action, payload: payloadToSend)
        //        sleep(2)
        NSLog(" XO XO Sent init payload")
        NSLog(" XO XO About to send Whole payload")
        var payloadToSend = ["type": "updateSettings", "shortcutName": "\(toPass)", "isInitPayload": "false",
                             "shortcutsFolder": "\(shortcutsFolder)", "voices": "\(listOfSayVoices)",
                             "mappedDataFromBackend": "\(jsToSend)",
                             "isSayvoice": "\(userPrefs.isAccessibility)", "sayHoldTime": "\(userPrefs.accessibilityHoldDownTime)",
                             "sayvoice": "\(userPrefs.accessibilityVoice)", "isForcedTitle": "\(userPrefs.isForcedTitle)"
        ]
        NSLog(" XO XO Sent Whole payload")
        
        //Send Key's Data to the PI
        sendToPropertyInspector(in: context, action: action, payload: payloadToSend)
        
        //Helper Title for Debuggindg
        //        setTitle(in: context, to: "❄️ \(toPass)")
        
        //IF the .json key's value poperty doesn't match, correct that.
        //        if (listOfCuts.contains(<#T##element: String##String#>)) {
        if (toPass != savedShortcut) {
            NSLog("🟡 We've updated the shortuct, to match ELGATO's Settings! contexT: \(context), toPass: \(toPass), from staleShortcut: \(savedShortcut)")
            if (listOfCuts.contains(toPass)) {
                newKeyIds.updateValue(toPass, forKey: context)
                Task {
                async let x = saveFile(fileName: keysFile) //(filePath: keySettingsFilePath)
                }
                //            savedShortcut = listOfCuts[0] //Set it to the first shortcut in the array.
                setTitle(in: context, to: toPass)
            } else {
                NSLog("🌚 The shortcut doens't exist! We're setting it to [0] & saving this to the SD API & save!")
                savedShortcut = listOfCuts[0] //Set it to the first shortcut in the array.
                newKeyIds.updateValue(savedShortcut, forKey: context)
                Task {
                async let x = saveFile(fileName: settingsFile) //(filePath: keySettingsFilePath)
                }
                setTitle(in: context, to: savedShortcut)
                payloadToSend.updateValue(savedShortcut, forKey: "shortcutName")
                setSettings(in: context, to: payloadToSend)
            }
        }
        //        }
        //        else {
        //            NSLog("🌚 The shortcut doens't exist! We're setting it to [0] & saving this to the SD API & save!")
        //            savedShortcut = listOfCuts[0] //Set it to the first shortcut in the array.
        //            newKeyIds.updateValue(savedShortcut, forKey: context)
        //            savePrefrences(filePath: keySettingsFilePath)
        //            setTitle(in: context, to: savedShortcut)
        //            payloadToSend.updateValue(savedShortcut, forKey: "shortcutName")
        //            setSettings(in: context, to: payloadToSend)
        //        }
        NSLog("DEBUG: Finished running didRecieveSettings()!")
    }
    
    override func propertyInspectorDidAppear(action: String, context: String, device: String) {
        NSLog("DEBUG: Starting propertyInspectorDidAppear()!")
        
//        // Simulate the hard crash/Slow loading...
//        if (firstLaunch == true) {
//            sleep(20)
//            firstLaunch = false
//        }
        WebSocketDelayForcePIEvent = true
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
        NSLog("DEBUG: Finished Running propertyInspectorDidAppear()!")
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
        NSLog("DEBUG: Starting sentToPlugin()!")
        
        processShortcuts()
        listOfCuts = listOfCuts.sorted() //Sort From A-Z | Are we still using this? TODO: We should filter more of the search stuff over on the swift side.
        
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
                    NSLog("DEBUG: sentToPlugin() Check #1!")
                    if (newKeyIds.keys.contains(context) == false) {
                        NSLog("MARKTODO value: \(i.value), KEY: \(i.key)")
                        if !(String(i.value) == "requestSettings") {
                            NSLog("MARKTODO value was not RSettings")
                            newKeyIds.updateValue(i.value, forKey: i.key)
                        }
                        NSLog("DEBUG: sentToPlugin() Check #2!")
                        updateSettings(context: context, action: action, payload: payload)
                        NSLog("DEBUG: sentToPlugin() Check #3!")
                    }
                    
                    //If the WebSocket is still loading, we need to force-the propertyInspectorDidAppear event.
                    if(WebSocketDelayForcePIEvent == false) {
                        NSLog("  ⚠️ 🚨 150 : delayed Startup. Checking for X")
                        propertyInspectorDidAppear(action: action, context: context, device: "")
                    }
                    
                case "shortcutsOfFolder":
                    shortcutsFolder
                case "updateSettings":
                    updateSettings(context: context, action: action, payload: payload) //Save User's settings to disk
                    setSettings(in: context, to: payload)
                    handleForcedTitle() //TODO: Move this call & the function outside of ShortcutsPlugin. We should call this from Update Settings? This may not work due to the Instance Manager
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
        //        if (decodedPayload[0] == "requestSettings") {
        //            requestSettings()
        //            let json = """
        //            {
        //                "event": inRegisterEvent,
        //                "uuid": inPluginUUID
        //            }
        //            """
        //
        //
        //            //Whole JSON Message: {"action":"yat.increment","event":"sendToPropertyInspector","context":"89C7482603E12CA379788EFB1A6349DD","payload":{"shortcutName":"efgwe","type":"updateSettings"}}
        //            // PAYLOAD: {shortcutName: "efgwe", type: "updateSettings"}
        //            //            sendToPropertyInspector(context: context, action: action, payload: ["type": "updateSettings", "shortcutName": "This_is_from_the_Backend!"])
        //
        //        }
        //        else {
        //            NSLog("⚠️ Unknown Payload: \(decodedPayload)")
        //            NSLog("⚠️ Unknown Payload: \(decodedPayload[0])")
        //        }
        //"shortcutsOfFolder"
        if (decodedPayload[0] == "shortcutsOfFolder") {
            requestShortcutsFromFolder()
        }
        NSLog("DEBUG: Finished Running sentToPlugin()!")
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
    NSLog("DEBUG: Starting updateSettings()!")
    NSLog("❄️ Updating the settings with \(payload)")
    let decodedPayload = payload.map { $0.value} //["TestCut_New1", "Samantha", "updateSettings"]
    let decodedPayloadKey = payload.map { $0.key} //["shortcutName", "sayvoice", "type"]
    
    for i in payload {
        switch i.key {
        case "shortcutName":
            NSLog("Key's value found \(i.value)")
            newKeyIds.updateValue(i.value, forKey: context)
            Task {
                async let x = saveFile(fileName: settingsFile) //(filePath: keySettingsFilePath)
            }
            
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
            Task {
                async let x =  saveFile(fileName: settingsFile) //(filePath: userSettingsFilePath)
            }
        case "sayHoldTime":
            //            accessibilityHoldDownTime = Double(i.value)!
            userPrefs.accessibilityHoldDownTime = Float(i.value)!
            NSLog("   👻 HoldTime: \(userPrefs.accessibilityHoldDownTime)")
            Task {
                async let x = saveFile(fileName: settingsFile) //(filePath: userSettingsFilePath)
            }
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
    
    NSLog("DEBUG: Finished Running updateSettings()!")
}


func requestShortcutsFromFolder() {
    NSLog("❄️ requestShortcutsFromFolder | Not Implemented")
}

// Func inside of PI
func requestSettings() {
    NSLog("❄️ Fetching the Requested settings  | Not Implemented")
    
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


