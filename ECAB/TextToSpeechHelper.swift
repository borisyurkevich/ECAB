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
    
    static let engine: TextToSpeechHelper = TextToSpeechHelper()
    let synthesizer = AVSpeechSynthesizer()
    
    func say(sentence: String){
        let utterance = AVSpeechUtterance(string: " " + sentence + " ")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-IE")
        
        // Fix bug
        utterance.rate = 0.4;
        utterance.pitchMultiplier = 1.1;

        synthesizer.speakUtterance(utterance)
    }
}
