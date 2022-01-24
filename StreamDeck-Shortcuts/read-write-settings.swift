//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation
import Sentry

var newKeyIds = [String:String]()
#warning("Need to Redo the settings saving/loading!")

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}


let keySettingsFilePath =  FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.streamdeckshortcuts.sdPlugin/keys.json")
let userSettingsFilePath =  FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.streamdeckshortcuts.sdPlugin/userSettings.json")

//Used for debugging their stats
let debugShortcuts =  FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.streamdeckshortcuts.sdPlugin/debugShortcuts.json")

func savePrefrences(filePath: URL) {
    if (filePath.absoluteString == keySettingsFilePath.absoluteString) {
        if (newKeyIds.keys.contains("type"))
        {
            newKeyIds.removeValue(forKey: "type")
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: newKeyIds, options: .prettyPrinted)
            try jsonData.write(to: filePath)
        } catch {
            SentrySDK.capture(error: error)
            NSLog("📓 Failed to write file to location \(filePath), because of error: \(error)")
        }
    }
    else if (filePath.absoluteString == userSettingsFilePath.absoluteString){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        //        settingX = mySettings(isX: false, xTime: 8.21, xVoice: "TestDebug")
        NSLog("   📓 About to encode new mySettings! \(userPrefs)")
        do {
            let jsonData = try encoder.encode(userPrefs)
            try jsonData.write(to: filePath)
            NSLog("   📓 Encoded new settings! \(userPrefs)")
        } catch {
            SentrySDK.capture(error: error)
            NSLog("📓 Failed to write file to location \(filePath), because of error: \(error)")
        }
    }
    else {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: shortcutsMapped, options: .prettyPrinted)
            try jsonData.write(to: filePath)
        } catch {
            SentrySDK.capture(error: error)
            NSLog("📓 Failed to write file to location \(filePath), because of error: \(error)")
        }
    }
}

private func loadJsonPrefs(fromURLString urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
    if let url = URL(string: urlString) {
        let urlSession = URLSession(configuration: .ephemeral).dataTask(with: url) { (data, response, error) in
            if let error = error {
                SentrySDK.capture(error: error)
                NSLog("_SaveTest_ Error")
                completion(.failure(error))
            }
            if let data = data {
                NSLog("_SaveTest_Success")
                completion(.success(data))
            }
        }
        urlSession.resume()
    }
}

func loadPrefrences(filePath: URL) async {
    
    loadJsonPrefs(fromURLString: filePath.absoluteString) { (result) in
        switch result {
        case .success(let data):
            //            parseJsonPrefs(jsonData: data)
            NSLog("_SaveTest_ Success 2")
            LogData(data: data, settingsType: filePath.absoluteString)
            //        NSLog("DATA: ", data)
        case .failure(let error):
            SentrySDK.capture(error: error)
            NSLog("_SaveTest_ Error 2")
            print(error)
            if (filePath.absoluteString == keySettingsFilePath.absoluteString) {
//                newKeyIds = ["LoadingErrorKey": "Dev Workaround, ignore this key/value"]
            }
            else {
                userPrefs = mySettings(isAccessibility: false, accessibilityHoldDownTime: 5.0, accessibilityVoice: "Samantha", isForcedTitle: false, searchRefs: 0, textFieldRefs: 0, dropdownRefs: 0)
//                accessibilityHoldDownTime = Double(userPrefs.xTime)
//                accessibilityVoice = userPrefs.xVoice
            }
        }
    }
    do {
        //        let decodedJson = try JSONSerialization.jsonObject(with: <#T##InputStream#>, options: <#T##JSONSerialization.ReadingOptions#>)
        //            .data(withJSONObject: newKeyIds, options: .prettyPrinted)
        //        try jsonData.write(to: filename2)
    } catch {
        SentrySDK.capture(error: error)
        NSLog("_SaveTest_ Error 3 ")
    }
}


//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



//func loadSettings() async throws {
//    guard let settingsUrl = URL(string: userSettingsFilePath.absoluteString) else {
//        return
//    }
//    let (data, _) = try await URLSession.shared.data(from: settingsUrl)
//
//    let settingsResult = try JSONDecoder().decode(mySettings.self, from: data)
//}


//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



func LogData(data: Data, settingsType: String) {
    NSLog("    ❄️ ❄️ ❄️  Data: \(data)")
    if (settingsType == keySettingsFilePath.absoluteString) {
        do {
            let decodedData = try JSONDecoder().decode([String : String].self, from: data)
            NSLog("DecodedData: \(decodedData)")
            let dd = decodedData
            newKeyIds = decodedData
            if (newKeyIds.count > 1) {
//                newKeyIds.removeValue(forKey: "LoadingErrorKey")
//                newKeyIds.removeValue(forKey: "type")
            }
        } catch {
            SentrySDK.capture(error: error)
        }
    }
    else {
        NSLog("   📓 About to DECODE new mySettings!")
        do {
            let decodedData = try JSONDecoder().decode(mySettings.self, from: data)
            NSLog("DecodedData mySettings: \(decodedData)")
            let dd = decodedData
            userPrefs = dd
//            isAccessibility = userPrefs.isX
//            accessibilityHoldDownTime = Double(userPrefs.xTime)
//            accessibilityVoice = userPrefs.xVoice
        } catch {
            SentrySDK.capture(error: error)
            print(error)
        }
    }
}
