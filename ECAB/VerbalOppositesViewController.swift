//
//  VerbalOppositesViewController.swift
//  ECAB
//
//  Created by Raphaël Bertin on 13/07/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

var lmPath: String!
var dicPath: String!
var words: Array<String> = []
var currentWord: String!

class VerbalOppositesViewController: CounterpointingViewController {
    
    private struct Labels {
        let practice1 = NSLocalizedString("Practice 1 : Say the SAME animal name (either CAT or DOG)", comment: "verbal opposites")
        let practice2 = NSLocalizedString("Practice 2 : Say the OPPOSITE animal name (CAT or DOG)", comment: "verbal opposites")
        let game1 = NSLocalizedString("Game 1 : Say the SAME animal name (either CAT or DOG)", comment: "verbal opposites")
        let game2 = NSLocalizedString("Game 2 : Say the OPPOSITE animal name (either CAT or DOG)", comment: "verbal opposites")
        let game3 = NSLocalizedString("Game 3 : Say the OPPOSITE animal name (either CAT or DOG)", comment: "verbal opposites")
        let game4 = NSLocalizedString("Game 4 : Say the SAME animal name (either CAT or DOG)", comment: "verbal opposites")
        
        let gameEnd = NSLocalizedString("Stop.", comment: "verbal opposites")
        let testOver = NSLocalizedString("Test is Over", comment: "verbal opposites alert title")
        let testOverBody = NSLocalizedString("You've been running the test for %@", comment: "verbal opposites alert body")
        let testOverAction = NSLocalizedString("Stop the test", comment: "verbal opposites alert ok")
    }
    
    private let labels = Labels()
    private let speechRecognitionHelper = SpeechRecognitionHelper()
    
    // Place in array of pictures that appear on the screen.
    // There's 2 arrays: training and game.
    var indexForCurrentSequence = 0
    
    var pictureAutoPresent = false
    
    var timeToGameOver = NSTimer()
    var dateAcceptDelayStart = NSDate()
    
    var timeSinceAnimalAppeared = 0.0
    let timeGameOver = 300.0 // Default is 300 seconds eg 5 mins
    
    var imageVisibleOnScreen = UIImageView(image: UIImage(named: "white_rect"))
    let labelTagAttention = 1
    let tagChangingGamePicture = 2
    let timeWarningPromptRemainingOnScreen = 4.0
    
    override func viewDidLoad() {
        sessionType = GamesIndex.Verbal
        greeingMessage = labels.practice1
        playSound(.Practice1)
        
        super.viewDidLoad()
        
        imageVisibleOnScreen.frame = CGRectMake(0, 0, imageVisibleOnScreen.frame.size.width * 2, imageVisibleOnScreen.frame.size.height * 2)
        imageVisibleOnScreen.center = view.center;
        imageVisibleOnScreen.hidden = true
        imageVisibleOnScreen.tag = tagChangingGamePicture
        view.addSubview(imageVisibleOnScreen)
        
        timeSinceAnimalAppeared = Constants.timeNever.rawValue.doubleValue
        
        speechRecognitionHelper.startListening()
    }
    
    func startAutoPresentPictures() {
        pictureAutoPresent = true
        imageVisibleOnScreen.hidden = false
    }
    
    func stopAutoPresentPictures() {
        pictureAutoPresent = false
        imageVisibleOnScreen.hidden = true
    }
    
    // Start and stop test is enabling logic to run the game in non training mode
    func startTest() {
        trainingMode = false
        
        timeToGameOver.invalidate()
        timeToGameOver = NSTimer.scheduledTimerWithTimeInterval(timeGameOver,
                                                                target: self,
                                                                selector: #selector(VerbalOppositesViewController.gameOver),
                                                                userInfo: nil,
                                                                repeats: false)
    }
    
    func stopTest() {
        timeToGameOver.invalidate()
        // We shoudn't invalidate all timers because that will prevent
        // screen from cleaning.
    }
    
    // Called eather from timer or from Next button in the menu bar
    override func presentNextScreen() {
        currentScreenShowing += 1
        
        self.cleanView() // Removes labels only
        
        switch currentScreenShowing {
        case 0:
            // Swithing trainingMode bool needed when practice is restarted.
            trainingMode = true
            presentMessage(labels.practice1)
            playSound(.Practice1)
            
        case 1 ... VerbalOppositesFactory.practiceSequence1.count:
            if !pictureAutoPresent {
                startAutoPresentPictures()
            }
            indexForCurrentSequence = currentScreenShowing - 1
            updateView(VerbalOppositesFactory.practiceSequence1[indexForCurrentSequence])
            
        case VerbalOppositesFactory.practiceSequence1.count + 1:
            stopAutoPresentPictures()
            presentMessage(labels.game1)
            playSound(Sound.EndOfPractice)
            
        case VerbalOppositesFactory.practiceSequence1.count + 2:
            playSound(Sound.Game1)
            
        case VerbalOppositesFactory.practiceSequence1.count + 3 ... (VerbalOppositesFactory.gameSequence1.count + (VerbalOppositesFactory.practiceSequence1.count + 1)):
            if !pictureAutoPresent {
                startTest()
                startAutoPresentPictures()
            }
            indexForCurrentSequence = currentScreenShowing - (VerbalOppositesFactory.practiceSequence1.count + 2)
            updateView(VerbalOppositesFactory.gameSequence1[indexForCurrentSequence])
            
        case VerbalOppositesFactory.gameSequence1.count + (VerbalOppositesFactory.practiceSequence1.count + 2):
            stopAutoPresentPictures()
            stopTest()
            presentMessage(labels.gameEnd)
            
        case VerbalOppositesFactory.gameSequence1.count + (VerbalOppositesFactory.practiceSequence1.count + 3):
            presentPause()
            
        default:
            break
        }
    }
    
    // Called when skip button tapped
    override func skip() {
        
        // Removes 5 images on tutorial.
        for v in view.subviews {
            if v.isKindOfClass(UIImageView) {
                v.removeFromSuperview()
            }
        }
        
        stopTest()
        currentScreenShowing = AuditorySustainFactory.practiceSequence.count + 2;
        presentNextScreen()
    }
    
    // Called when Restart button tapped
    override func presentPreviousScreen() {
        
        if trainingMode {
            stopAutoPresentPictures()
            currentScreenShowing = -1
            presentNextScreen()
        } else {
            stopTest()
            skip()
        }
    }
    
    private func updateView(gameSequence: GameSequence) {
        
        if !gamePaused {
            let newImage = UIImage(named: gameSequence.picture.rawValue)
            let newFrame = UIImageView(image: newImage)
            
            imageVisibleOnScreen.frame = CGRectMake(0, 0, newFrame.frame.size.width * 2, newFrame.frame.size.height * 2)
            imageVisibleOnScreen.center = view.center;
            imageVisibleOnScreen.image = newImage
            
            timeSinceAnimalAppeared = 0
        }
    }
    
    override func tapHandler(touchLeft: Bool) {
        // Ignore touchLeft, whole screen is the target

        playSound(.Positive)
        log(.Hit, hitType: SuccessType.Sound.rawValue.integerValue)
        
        // Prevents following taps to be sucesfull
        timeSinceAnimalAppeared = Constants.timeNever.rawValue.doubleValue
        
        presentNextScreen();
    }
    
    private func log(action: PlayerAction, hitType: NSNumber) {
        let screen = CGFloat(indexForCurrentSequence + 1)
        
        model.addMove(screen, positionY: 0, success: true, interval: 0.0, inverted: trainingMode, delay:timeSinceAnimalAppeared, type: hitType.integerValue)
    }
    
    func gameOver() {
        gamePaused = true
        timeToGameOver.invalidate()
        
        let secondsPlayed = timeGameOver
        var valueToDisplay = "\(Int(secondsPlayed)) seconds"
        if secondsPlayed >= 60 {
            valueToDisplay = "\(Int(secondsPlayed / 60)) minutes"
        }
        let bodyString = String.localizedStringWithFormat(labels.testOverBody, valueToDisplay)
        let alertView = UIAlertController(title: labels.testOver, message: bodyString, preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: labels.testOverAction, style: .Default, handler: {
            (okAction) -> Void in
            self.presentPause()
        }))
        presentViewController(alertView, animated: true, completion: nil)
    }
    
    override func getComment() -> String {
        return session.comment
    }
    
    override func quit() {
        gamePaused = true
        
        if !trainingMode {
            stopTest()
        }
        if pictureAutoPresent {
            stopAutoPresentPictures()
        }
        
        super.quit()
    }
    
    override func cleanView() {
        
        // Removes labels
        for v in view.subviews {
            if v.isKindOfClass(UILabel) {
                v.removeFromSuperview()
            }
        }
    }
}