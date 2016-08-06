//
//  SpeechRecognitionHelper.swift
//  ECAB
//
//  Created by Raphaël Bertin on 15/07/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class SpeechRecognitionHelper : NSObject, OEEventsObserverDelegate{
    
    var openEarsEventsObserver = OEEventsObserver();
    var startupFailedDueToLackOfPermissions = Bool()
    
    var lmPath: String!
    var dicPath: String!
    var words: Array<String> = []
    var currentWord: String!
    
    static var helper = SpeechRecognitionHelper();
    
    static func sharedInstance() -> SpeechRecognitionHelper {
        return helper;
    }

    override init() {
        super.init()
        
        openEarsEventsObserver.delegate = self
        
        let lmGenerator: OELanguageModelGenerator = OELanguageModelGenerator()
        
        addWords()
        
        let name = "LanguageModelFileStarSaver"
        
        lmGenerator.generateLanguageModelFromArray(words, withFilesNamed: name, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"))
        lmPath = lmGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
        dicPath = lmGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
    }
    
    func setThreshold(th: Float) {
        do {
            try OEPocketsphinxController.sharedInstance().setActive(true)
            OEPocketsphinxController.sharedInstance().vadThreshold = th
            OEPocketsphinxController.sharedInstance().secondsOfSilenceToDetect = 0.1
        } catch _ { }
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
        if(!OEPocketsphinxController.sharedInstance().isListening){
            
            do {
                try OEPocketsphinxController.sharedInstance().setActive(true)
            } catch {
                print("Invalid Selection.")
            }
            
            OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(lmPath, dictionaryAtPath: dicPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false)
        }
    }
    
    func stopListening() {
        if(OEPocketsphinxController.sharedInstance().isListening){
            OEPocketsphinxController.sharedInstance().stopListening()
        }
    }
    
    func addWords() {
        //add any thing here that you want to be recognized. Must be in capital letters
        words.append("CAT")
        words.append("DOG")
    }
    
    func pocketsphinxFailedNoMicPermissions() {
        
        if (AVAudioSession.sharedInstance().respondsToSelector(#selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    self.startListening()
                } else{
                    NSLog("Local callback: The user has never set mic permissions or denied permission to this app's mic, so listening will not start.")
                    self.startupFailedDueToLackOfPermissions = true
                    if OEPocketsphinxController.sharedInstance().isListening {
                        let error = OEPocketsphinxController.sharedInstance().stopListening() // Stop listening if we are listening.
                        if(error != nil) {
                            NSLog("Error while stopping listening in micPermissionCheckCompleted: %@", error);
                        }
                    }
                }
            })
        }
        
        
    }
    
    func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
        
        // Send notification to the controller with the animal name and the score
        NSNotificationCenter.defaultCenter().postNotificationName("speakAnimalName",
                                                                    object:nil,
                                                                    userInfo:[
                                                                    "hypothesis": hypothesis,
                                                                    "recognitionScore": recognitionScore
                                                                    ])

    }
    
}
