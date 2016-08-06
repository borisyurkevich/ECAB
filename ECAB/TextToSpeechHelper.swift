//
//  TextToSpeechHelper.swift
//  ECAB
//
//  Created by Raphaël Bertin on 24/07/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import AVFoundation

class TextToSpeechHelper : NSObject{
    
    static let synthesizer = AVSpeechSynthesizer()
    
    static func say(sentence: String){
        let utterance = AVSpeechUtterance(string: " " + sentence + " ")
        utterance.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.speechVoices()[Model.sharedInstance.data.voiceName.integerValue].language)
        
        // Fix bug
        utterance.rate = Model.sharedInstance.data.voiceRate.floatValue;
        utterance.pitchMultiplier = Model.sharedInstance.data.voicePitch.floatValue;

        synthesizer.speakUtterance(utterance)
    }
    
    static func positive(){
        playMP3("positive")
    }
    
    static func negative(){
        playMP3("negative")
    }
    
    static func playMP3(sound: String){
        let soundURL = NSBundle.mainBundle().URLForResource(sound, withExtension: "mp3");
        var soundID:SystemSoundID = 1;
        AudioServicesCreateSystemSoundID(soundURL!, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
}
