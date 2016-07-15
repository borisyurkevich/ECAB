//
//  SpeechRecognitionHelper.swift
//  ECAB
//
//  Created by Raphaël Bertin on 15/07/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class SpeechRecognitionHelper : NSObject, OEEventsObserverDelegate{
    
    static let THRESHOLD: Float = 3.5
    
    var openEarsEventsObserver = OEEventsObserver()
    var startupFailedDueToLackOfPermissions = Bool()
    
    override init() {
        super.init()
        
        openEarsEventsObserver = OEEventsObserver()
        openEarsEventsObserver.delegate = self
        
        let lmGenerator: OELanguageModelGenerator = OELanguageModelGenerator()
        
        addWords()
        
        let name = "LanguageModelFileStarSaver"
        lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
        dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
        
        OEPocketsphinxController.sharedInstance().vadThreshold = SpeechRecognitionHelper.THRESHOLD
    }
    
    func pocketsphinxDidStartListening() {
        print("Listening...")
    }
    
    func pocketsphinxDidDetectSpeech() {
        print("Speech detected")
    }
    
    func pocketsphinxDidDetectFinishedSpeech() {
        print("Silence detected")
    }
    
    func pocketsphinxDidStopListening() {
        print("Listening stopped")
    }
    
    func pocketsphinxDidSuspendRecognition() {
        print("Recognition suspended")
    }
    
    func pocketsphinxDidResumeRecognition() {
        print("Recognition resumed")
    }
    
    func pocketsphinxDidChangeLanguageModelToFile(newLanguageModelPathAsString: String, newDictionaryPathAsString: String) {
        print("Pocketsphinx is now using the following language model: \(newLanguageModelPathAsString) and the following dictionary: \(newDictionaryPathAsString)")
    }
    
    func pocketSphinxContinuousSetupDidFailWithReason(reasonForFailure: String) {
        print("Listening setup wasn't successful and returned the failure reason: \(reasonForFailure)")
    }
    
    func pocketSphinxContinuousTeardownDidFailWithReason(reasonForFailure: String) {
        print("Listening teardown wasn't successful and returned the failure reason: \(reasonForFailure)")
        
    }
    
    func testRecognitionCompleted() {
        print("A test file that was submitted for recognition is now complete.")
    }
    
    func startListening() {
        
        do {
            try OEPocketsphinxController.sharedInstance().setActive(true)
        } catch {
            print("Invalid Selection.")
        }
        
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
    }
    
    func stopListening() {
        OEPocketsphinxController.sharedInstance().stopListening()
    }
    
    func addWords() {
        //add any thing here that you want to be recognized. Must be in capital letters
        words.append("CAT")
        words.append("DOG")
    }
    
    func getNewWord() {
        let randomWord = Int(arc4random_uniform(UInt32(words.count)))
        currentWord = words[randomWord]
    }
    
    func pocketsphinxFailedNoMicPermissions() {
        
        NSLog("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
        self.startupFailedDueToLackOfPermissions = true
        if OEPocketsphinxController.sharedInstance().isListening {
            let error = OEPocketsphinxController.sharedInstance().stopListening() // Stop listening if we are listening.
            if(error != nil) {
                NSLog("Error while stopping listening in micPermissionCheckCompleted: %@", error);
            }
            startListening()
        }
    }
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        print(hypothesis)
    }
    
}
