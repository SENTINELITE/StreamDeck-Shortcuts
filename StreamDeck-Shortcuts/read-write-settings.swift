//
//  File.swift
//
//
//  Created by Kirk Land on 11/10/21.
//

import Foundation

var newKeyIds = [String:String]()
#warning("Need to Redo the settings saving/loading!")

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}


//let filename2 = getDocumentsDirectory().appendingPathComponent("keys.json")
let keySettingsFilePath =  FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("/Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.yetanothertest.sdPlugin/keys.json")
let userSettingsFilePath =  FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("/Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.yetanothertest.sdPlugin/userSettings.json")

func savePrefrences(filePath: URL) {
    if (filePath.absoluteString == keySettingsFilePath.absoluteString) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: newKeyIds, options: .prettyPrinted)
            try jsonData.write(to: filePath)
        } catch {
            NSLog("📓 Failed to write file to location \(filePath), because of error: \(error)")
        }
    }
    else {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        //        settingX = mySettings(isX: false, xTime: 8.21, xVoice: "TestDebug")
        NSLog("   📓 About to encode new mySettings! \(userPrefs)")
        do {
            let jsonData = try encoder.encode(userPrefs)
            try jsonData.write(to: filePath)
            NSLog("   📓 Encoded new settings! \(userPrefs)")
        } catch {
            NSLog("📓 Failed to write file to location \(filePath), because of error: \(error)")
        }
    }
}

private func loadJsonPrefs(fromURLString urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
    if let url = URL(string: urlString) {
        let urlSession = URLSession(configuration: .ephemeral).dataTask(with: url) { (data, response, error) in
            if let error = error {
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
            NSLog("_SaveTest_ Error 2")
            print(error)
            if (filePath.absoluteString == keySettingsFilePath.absoluteString) {
                newKeyIds = ["LoadingErrorKey": "Dev Workaround, ignore this key/value"]
            }
            else {
                userPrefs = mySettings(isAccessibility: false, accessibilityHoldDownTime: 1.0, accessibilityVoice: "PlaceholderVoice", isForcedTitle: false, searchRefs: 0, textFieldRefs: 0, dropdownRefs: 0)
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
                newKeyIds.removeValue(forKey: "LoadingErrorKey")
            }
        } catch {}
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
            print(error)
        }
    }
}
