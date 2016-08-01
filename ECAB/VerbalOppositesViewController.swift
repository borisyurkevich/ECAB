//
//  VerbalOppositesViewController.swift
//  ECAB
//
//  Created by Raphaël Bertin on 13/07/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import Foundation

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
    
    var indexForCurrentSequence = 0
    var pictureAutoPresent = false
    
    var imageVisibleOnScreen = UIImageView(image: UIImage(named: "white_rect"));
    
    var timeToAcceptDelay = NSTimer()
    var timeToGameOver = NSTimer()
    var dateAcceptDelayStart = NSDate()
    var timeSinceAnimalAppeared = 0.0
    let timeGameOver = 300.0 // Default is 300 seconds eg 5 mins
    
    let timeWarningPromptRemainingOnScreen = 4.0
    
    let number1 = VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + VerbalOppositesFactory.gameSequence1.count + 4;
    let number2 = VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + VerbalOppositesFactory.gameSequence1.count + 4 + VerbalOppositesFactory.gameSequence2.count + VerbalOppositesFactory.gameSequence3.count + 2;
    
    override func viewDidLoad() {
        sessionType = GamesIndex.Verbal
        greeingMessage = labels.practice1
        playSound(.Practice1)
        
        super.viewDidLoad()
        
        imageVisibleOnScreen.frame = CGRectMake(0, 0, imageVisibleOnScreen.frame.size.width * 2, imageVisibleOnScreen.frame.size.height * 2)
        imageVisibleOnScreen.center = view.center;
        imageVisibleOnScreen.hidden = true
        view.addSubview(imageVisibleOnScreen)
        
        timeSinceAnimalAppeared = Constants.timeNever.rawValue.doubleValue
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(VerbalOppositesViewController.speakAnimalName(_:)),
                                                         name: "speakAnimalName",
                                                         object: nil)
        
        SpeechRecognitionHelper.engine().setThreshold(model.data.threshold.floatValue)
    }
    
    func speakAnimalName(notification: NSNotification) {
        
        // Get animal name from speech recognition
        let userInfo: Dictionary<String,String!> = notification.userInfo as! Dictionary<String,String!>
        var animalName = userInfo["hypothesis"]
        _ = userInfo["recognitionScore"]
        animalName = animalName!.componentsSeparatedByString(" ").first!
        
        print(animalName)
        
        var hit: Bool = false;
    
        switch currentScreenShowing {
            
        // Practice 1
        case 1 ... VerbalOppositesFactory.practiceSequence1.count:
            indexForCurrentSequence = currentScreenShowing - 1
            hit = (VerbalOppositesFactory.practiceSequence1[indexForCurrentSequence].picture == Picture.Dog && animalName == "DOG") ||
                    (VerbalOppositesFactory.practiceSequence1[indexForCurrentSequence].picture == Picture.Cat && animalName == "CAT")
            
        // Practice 2
        case VerbalOppositesFactory.practiceSequence1.count + 2 ... VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + 1:
            indexForCurrentSequence = currentScreenShowing - (VerbalOppositesFactory.practiceSequence1.count + 2)
            hit = (VerbalOppositesFactory.practiceSequence2[indexForCurrentSequence].picture == Picture.Dog && animalName == "CAT") ||
                    (VerbalOppositesFactory.practiceSequence2[indexForCurrentSequence].picture == Picture.Cat && animalName == "DOG")
            
        // Game 1
        case VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + 3 ... VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + VerbalOppositesFactory.gameSequence1.count + 2:
            indexForCurrentSequence = currentScreenShowing - (VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + 3 )
            hit = (VerbalOppositesFactory.gameSequence1[indexForCurrentSequence].picture == Picture.Dog && animalName == "DOG") ||
                    (VerbalOppositesFactory.gameSequence1[indexForCurrentSequence].picture == Picture.Cat && animalName == "CAT")
            
        // Game 2
        case number1 ... number1 + VerbalOppositesFactory.gameSequence2.count:
            indexForCurrentSequence = currentScreenShowing - number1
            hit = (VerbalOppositesFactory.gameSequence2[indexForCurrentSequence].picture == Picture.Dog && animalName == "CAT") ||
                    (VerbalOppositesFactory.gameSequence2[indexForCurrentSequence].picture == Picture.Cat && animalName == "DOG")
            
            
        // Game 3
        case number1 + VerbalOppositesFactory.gameSequence2.count + 1 ... number1 + VerbalOppositesFactory.gameSequence2.count + VerbalOppositesFactory.gameSequence3.count:
            indexForCurrentSequence = currentScreenShowing - (number1 + VerbalOppositesFactory.gameSequence2.count + 1)
            hit = (VerbalOppositesFactory.gameSequence3[indexForCurrentSequence].picture == Picture.Dog && animalName == "CAT") ||
                    (VerbalOppositesFactory.gameSequence3[indexForCurrentSequence].picture == Picture.Cat && animalName == "DOG")
            
        // Game 4
        case number2 ... number2 + VerbalOppositesFactory.gameSequence4.count - 1:
            indexForCurrentSequence = currentScreenShowing - number2
            hit = (VerbalOppositesFactory.gameSequence4[indexForCurrentSequence].picture == Picture.Dog && animalName == "DOG") ||
                    (VerbalOppositesFactory.gameSequence4[indexForCurrentSequence].picture == Picture.Cat && animalName == "CAT")
            
        default:
            break
        }
        
        if(hit){
            
            if(!trainingMode){
                log(.Hit, hitType: SuccessType.Picture.rawValue.integerValue)
                session.score = NSNumber(integer: (session.score.integerValue + 1))
            }
            
            timeSinceAnimalAppeared = 0
            timeToAcceptDelay.invalidate()
            timeToAcceptDelay = NSTimer.scheduledTimerWithTimeInterval(Constants.timersScale.rawValue.doubleValue,
                                                                       target: self,
                                                                       selector: #selector(VerbalOppositesViewController.updateDelay),
                                                                       userInfo: nil,
                                                                       repeats: true)
            
            presentNextScreen();
        }
    }
    
    func updateDelay() {
        timeSinceAnimalAppeared += Constants.timersScale.rawValue.doubleValue
    }
    
    func startAutoPresentPictures() {
        if(!trainingMode){
            model.addMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0, type: SuccessType.Picture.rawValue)
        }
        pictureAutoPresent = true
        imageVisibleOnScreen.hidden = false
        SpeechRecognitionHelper.engine().startListening()
    }
    
    func stopAutoPresentPictures() {
        pictureAutoPresent = false
        imageVisibleOnScreen.hidden = true
        SpeechRecognitionHelper.engine().stopListening()
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
        SpeechRecognitionHelper.engine().stopListening()

        timeToGameOver.invalidate()
        timeToAcceptDelay.invalidate()
        // We shoudn't invalidate all timers because that will prevent
        // screen from cleaning.
    }
    
    // Called eather from timer or from Next button in the menu bar
    override func presentNextScreen() {
        currentScreenShowing += 1
        
        self.cleanView() // Removes labels only
        
        print("Test \(currentScreenShowing)")

        switch currentScreenShowing {
            
            // Practice 1 introduction
            case 0:
                // Switching trainingMode bool needed when practice is restarted.
                trainingMode = true
                presentMessage(labels.practice1)
            
            // Practice 1
            case 1 ... VerbalOppositesFactory.practiceSequence1.count:
                if !pictureAutoPresent {
                    startAutoPresentPictures()
                }
                indexForCurrentSequence = currentScreenShowing - 1
                updateView(VerbalOppositesFactory.practiceSequence1[indexForCurrentSequence])
            
            // Practice 2 introduction
            case VerbalOppositesFactory.practiceSequence1.count + 1:
                stopAutoPresentPictures()
                presentMessage(labels.practice2)
            
             // Practice 2
            case VerbalOppositesFactory.practiceSequence1.count + 2 ... VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + 1:
                if !pictureAutoPresent {
                    startAutoPresentPictures()
                }
                indexForCurrentSequence = currentScreenShowing - (VerbalOppositesFactory.practiceSequence1.count + 2)
                updateView(VerbalOppositesFactory.practiceSequence2[indexForCurrentSequence])
            
            // Game 1 introduction
            case VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + 2:
                stopAutoPresentPictures()
                presentMessage(labels.game1)
            
            // Game 1
            case VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + 3 ... VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + VerbalOppositesFactory.gameSequence1.count + 2:
                if !pictureAutoPresent {
                    startTest()
                    startAutoPresentPictures()
                }
                indexForCurrentSequence = currentScreenShowing - (VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + 3)
                updateView(VerbalOppositesFactory.gameSequence1[indexForCurrentSequence])
            
            // Game 2 introduction
            case VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + VerbalOppositesFactory.gameSequence1.count + 3:
                stopAutoPresentPictures()
                presentMessage(labels.game2)
            
            // Game 2
            case number1 ... number1 + VerbalOppositesFactory.gameSequence2.count - 1:
                if !pictureAutoPresent {
                    startTest()
                    startAutoPresentPictures()

                }
                indexForCurrentSequence = currentScreenShowing - number1
                updateView(VerbalOppositesFactory.gameSequence2[indexForCurrentSequence])
            
            // Game 3 introduction
            case number1 + VerbalOppositesFactory.gameSequence2.count:
                stopAutoPresentPictures()
                presentMessage(labels.game3)
                
            // Game 3
            case number1 + VerbalOppositesFactory.gameSequence2.count + 1 ... number1 + VerbalOppositesFactory.gameSequence2.count + VerbalOppositesFactory.gameSequence3.count:
                
                if !pictureAutoPresent {
                    startTest()
                    startAutoPresentPictures()
                }
                indexForCurrentSequence = currentScreenShowing - (number1 + VerbalOppositesFactory.gameSequence2.count + 1)
                updateView(VerbalOppositesFactory.gameSequence3[indexForCurrentSequence])
            
            // Game 4 introduction
            case number1 + VerbalOppositesFactory.gameSequence2.count + VerbalOppositesFactory.gameSequence3.count + 1:
                stopAutoPresentPictures()
                presentMessage(labels.game4)
            
            // Game 4 
            case number2 ... number2 + VerbalOppositesFactory.gameSequence4.count - 1:
                
                if !pictureAutoPresent {
                    startTest()
                    startAutoPresentPictures()
                }
                indexForCurrentSequence = currentScreenShowing - (number2)
                updateView(VerbalOppositesFactory.gameSequence4[indexForCurrentSequence])
            
            // Stop message
            case number2 + VerbalOppositesFactory.gameSequence4.count:
                stopAutoPresentPictures()
                stopTest()
                presentMessage(labels.gameEnd)
            
            // Alert dialog to save results
            case number2 + VerbalOppositesFactory.gameSequence4.count + 1:
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
        currentScreenShowing = VerbalOppositesFactory.practiceSequence1.count + VerbalOppositesFactory.practiceSequence2.count + 2;
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
    
    private func log(action: PlayerAction, hitType: NSNumber) {
        let screen = CGFloat(indexForCurrentSequence + 1)
        model.addMove(screen, positionY: 0, success: true, interval: 0.0, inverted: trainingMode, delay:timeSinceAnimalAppeared, type: hitType.integerValue)
    }
    
    func gameOver() {
        gamePaused = true
        timeToAcceptDelay.invalidate()
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