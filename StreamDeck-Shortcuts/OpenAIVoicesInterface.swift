//
//  OpenAIVoicesInterface.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirk Land on 11/10/23.
//

import Foundation
import OSLog

let audioDir = NSHomeDirectory().appending("/Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.sds-2.sdPlugin/audio")
//var selectedVoice: Voice = .alloy

enum Voice: String, CaseIterable, Identifiable, Codable {
    case system
    case alloy
    case echo
    case fable
    case onyx
    case nova
    case shimmer
    
    var id: Voice { self }
}

func getTextToSpeechAsync(text: String, shortcutUUID: String, voice: Voice) async throws -> URL {
    let loggerOpenAi = Logger(subsystem: "subsystem", category: "openAi")
    // Create URL
    guard let url = URL(string: "https://api.openai.com/v1/audio/speech") else {
        throw URLError(.badURL)
    }
    
    // Create request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    
    // Set headers
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(openAiToken)", forHTTPHeaderField: "Authorization")
    
    // Create JSON data and pass in body
    let jsonData = try JSONSerialization.data(withJSONObject: [
        "input": text,
        "model": "tts-1",
        "voice": voice.rawValue,
        "response_format": "aac",
        "speed": "1.0",
    ])
    request.httpBody = jsonData
    
    // Make the request
    let (data, response) = try await URLSession.shared.data(for: request)
    
    // Check response
    guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        loggerOpenAi.error("Bad Server Response")
        throw URLError(.badServerResponse)
    }
    
    loggerOpenAi.log("Response: \(response)")
    
    loggerOpenAi.log("about to save file...")
    
    
    
    
    
//    let audioDir = NSHomeDirectory().appending("/Library/Application Support/com.elgato.StreamDeck/Plugins/com.sentinelite.sds-2.sdPlugin/audio/Shortcuts")
    let fileName = "/Shortcuts/\(shortcutUUID)_\(voice.rawValue).aac"
    let heifa = audioDir.appending(fileName)
    
    let fileUrl = URL(fileURLWithPath: heifa)
    
    
    
    
    
    loggerOpenAi.log("about to write file")
    do {
        try data.write(to: fileUrl)
        loggerOpenAi.log("File saved successfully to: \(fileUrl.path)")
    } catch {
        loggerOpenAi.error("File saving failed with error: \(error)")
        throw error
    }
    
    loggerOpenAi.log("about to saved file")
    
    print(fileUrl.description)
    
    return fileUrl
}
