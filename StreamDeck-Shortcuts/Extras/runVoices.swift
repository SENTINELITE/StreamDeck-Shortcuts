//
//  runVoices.swift
//  StreamDeck-Shortcuts
//
//  Created by Kirkland on 10/8/25.
//

import AVFoundation
import Foundation

//TODO: Pass Speed Parameter
var audioPlayer: AVAudioPlayer?

///Runs the specified audiio file & return the duration of the file.
func runVoices(url: URL, playbackSpeed: Float = 1.0) async -> TimeInterval {
    let durationTask = Task {
        
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
        audioPlayer?.enableRate = true
        audioPlayer?.rate = playbackSpeed
        audioPlayer?.play()
        
        guard let duration = audioPlayer?.duration else {
            return TimeInterval(0)
        }
        return duration
    }
    do {
        let result = try await durationTask.result.get()
        return result
    } catch {
        print("Error")
        return TimeInterval(0)
    }
}
