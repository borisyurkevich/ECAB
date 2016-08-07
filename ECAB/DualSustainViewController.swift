//
//  DualSustainViewController.swift
//  ECAB
//
//  Created by Raphaël Bertin on 29/06/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import Foundation

class DualSustainViewController: CounterpointingViewController {
    
    private struct Labels {
        let practice = NSLocalizedString("Practice : Touch the screen every time\nyou see OR hear one of the animals", comment: "dual sustain")
        let gameReady = NSLocalizedString("Keep touch the screen every time\nyou see OR hear one of the animals", comment: "dual sustain")
        let reminder = NSLocalizedString("Remember, touch the screen every time you see OR hear an animal", comment: "dual sustain. Appear when subjects ignores x amount of targets")
        let gameEnd = NSLocalizedString("Stop.", comment: "dual sustain")
        let testOver = NSLocalizedString("Test is Over", comment: "dual sustain alert title")
        let testOverBody = NSLocalizedString("You've been running the test for %@", comment: "dual sustain alert body")
        let testOverAction = NSLocalizedString("Stop the test", comment: "dual sustain alert ok")
    }
    
    private let labels = Labels()
    
    // Place in array of pictures that appear on the screen.
    // There's 2 arrays: training and game.
    var indexForCurrentSequence = 0
    
    var animalType = SuccessType.Picture.rawValue
    
    var pictureAutoPresent = false
    
    let totalMissesBeforeWarningPrompt = 4
    var timeToPresentNextScreen = NSTimer()
    var timeToPresentWhiteSpace = NSTimer()
    var timeToGameOver = NSTimer()
    var dateAcceptDelayStart = NSDate()
    
    var timeToAcceptDelay = NSTimer()
    var timeAcceptDelay = 0.0 // from core data
    
    var timeSinceAnimalAppeared = 0.0
    var timeBlankSpaceVisible = 0.0
    var timePictureVisible = 0.0 // Called "exposure" in the UI and log.
    let timeGameOver = 300.0 // Default is 300 seconds eg 5 mins
    
    var countTotalMissies = 0
    var countPictureAnimals = 0
    var countSoundAnimals = 0
    var countObjects = 0
    
    var imageVisibleOnScreen = UIImageView(image: UIImage(named: "white_rect"))
    let labelTagAttention = 1
    let tagChangingGamePicture = 2
    let timeWarningPromptRemainingOnScreen = 4.0
    
    override func viewDidLoad() {
        sessionType = GamesIndex.DualSust
        greeingMessage = labels.practice
        TextToSpeechHelper.say("Practice 1")
    
        super.viewDidLoad()
        
        imageVisibleOnScreen.frame = CGRectMake(0, 0, imageVisibleOnScreen.frame.size.width * 2, imageVisibleOnScreen.frame.size.height * 2)
        imageVisibleOnScreen.center = view.center;
        imageVisibleOnScreen.hidden = true
        imageVisibleOnScreen.tag = tagChangingGamePicture
        view.addSubview(imageVisibleOnScreen)
        
        timePictureVisible = model.data.dualSustSpeed.doubleValue
        timeBlankSpaceVisible = model.data.dualSustDelay.doubleValue
        timeAcceptDelay = model.data.dualSustAcceptedDelay!.doubleValue
        
        session.speed = timePictureVisible
        session.blank = timeBlankSpaceVisible
        session.acceptedDelay = timeAcceptDelay
        
        timeSinceAnimalAppeared = Constants.timeNever.rawValue.doubleValue
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
        countObjects = 0
        countPictureAnimals = 0
        countSoundAnimals = 0

        timeToGameOver.invalidate()
        timeToGameOver = NSTimer.scheduledTimerWithTimeInterval(timeGameOver,
                                                                target: self,
                                                                selector: #selector(DualSustainViewController.gameOver),
                                                                userInfo: nil,
                                                                repeats: false)
    }
    
    func stopTest() {
        timeToGameOver.invalidate()
        timeToAcceptDelay.invalidate()
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
                presentMessage(labels.practice)
                TextToSpeechHelper.say("Practice 1")
            
            case 1 ... DualSustainFactory.practiceSequence.count:
                if !pictureAutoPresent {
                    startAutoPresentPictures()
                }
                indexForCurrentSequence = currentScreenShowing - 1
                updateView(DualSustainFactory.practiceSequence[indexForCurrentSequence])
                TextToSpeechHelper.say(DualSustainFactory.practiceSequence[indexForCurrentSequence].sound)
            
            case DualSustainFactory.practiceSequence.count + 1:
                stopAutoPresentPictures()
                presentMessage(labels.gameReady)
                TextToSpeechHelper.say("Game 1")
            
            case DualSustainFactory.practiceSequence.count + 2 ... (DualSustainFactory.gameSequence.count + (DualSustainFactory.practiceSequence.count + 1)):
                if !pictureAutoPresent {
                    startTest()
                    startAutoPresentPictures()
                }
                indexForCurrentSequence = currentScreenShowing - (DualSustainFactory.practiceSequence.count + 2)
                updateView(DualSustainFactory.gameSequence[indexForCurrentSequence])
                TextToSpeechHelper.say(DualSustainFactory.gameSequence[indexForCurrentSequence].sound)
            
            case DualSustainFactory.gameSequence.count + (DualSustainFactory.practiceSequence.count + 2):
                stopAutoPresentPictures()
                stopTest()
                presentMessage(labels.gameEnd)
                TextToSpeechHelper.say("End of game")
            
            case DualSustainFactory.gameSequence.count + (DualSustainFactory.practiceSequence.count + 3):
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
        
        timeToPresentWhiteSpace.invalidate()
        timeToPresentNextScreen.invalidate()
        stopTest()
        currentScreenShowing = DualSustainFactory.practiceSequence.count + 2;
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
        
        if gamePaused {
            return
        }
        
        let newImage = UIImage(named: gameSequence.picture.rawValue)
        let newFrame = UIImageView(image: newImage)
        
        imageVisibleOnScreen.frame = CGRectMake(0, 0, newFrame.frame.size.width * 2, newFrame.frame.size.height * 2)
        imageVisibleOnScreen.center = view.center;
        imageVisibleOnScreen.image = newImage
        
        if pictureIsAnimal(gameSequence) || soundIsAnimal(gameSequence) {
            timeSinceAnimalAppeared = 0
            timeToAcceptDelay.invalidate()
            timeToAcceptDelay = NSTimer.scheduledTimerWithTimeInterval(Constants.timersScale.rawValue.doubleValue,
                                                                       target: self,
                                                                       selector: #selector(DualSustainViewController.updateAcceptedDelay),
                                                                       userInfo: nil,
                                                                       repeats: true)
        }
        
        if (!trainingMode) {
            if pictureIsAnimal(gameSequence) {
                countPictureAnimals += 1
                NSLog("Animal picture")
            } else if soundIsAnimal(gameSequence){
                countSoundAnimals += 1
                NSLog("Animal sound")
            }else {
                countObjects += 1
            }
            
            session.pictures = countPictureAnimals
            session.sounds = countSoundAnimals
            session.objects = countObjects
        }
        
        if timeBlankSpaceVisible >= model.kMinDelay {
            
            timeToPresentWhiteSpace.invalidate()
            timeToPresentWhiteSpace = NSTimer.scheduledTimerWithTimeInterval(timePictureVisible,
                                                                             target: self,
                                                                             selector: #selector(DualSustainViewController.showWhiteSpace),
                                                                             userInfo: nil,
                                                                             repeats: false)
        }
        
        timeToPresentNextScreen.invalidate()
        timeToPresentNextScreen = NSTimer.scheduledTimerWithTimeInterval(timePictureVisible + timeBlankSpaceVisible,
                                                                         target: self,
                                                                         selector: #selector(TestViewController.presentNextScreen),
                                                                         userInfo: nil,
                                                                         repeats: false)
    }
    
    func showWhiteSpace() {
        let whiteSpace = UIImage(named: Picture.Empty.rawValue)
        self.imageVisibleOnScreen.image = whiteSpace
    }
    
    func updateAcceptedDelay() {
        timeSinceAnimalAppeared += Constants.timersScale.rawValue.doubleValue
        if timeSinceAnimalAppeared > timeAcceptDelay {
            timeToAcceptDelay.invalidate()
            timeSinceAnimalAppeared = Constants.timeNever.rawValue.doubleValue
            // Because stopwatch was alive long enough to reach its limit,
            // we know that animal was missed.
            noteMistake(.Miss)
        }
    }
    
    override func tapHandler(touchLeft: Bool) {
        // Ignore touchLeft, whole screen is the target
        
        if timeSinceAnimalAppeared <= timeAcceptDelay {
            countTotalMissies = 0
            
            log(.Hit, hitType: animalType.integerValue)
            
            // Prevents following taps to be sucesfull
            timeSinceAnimalAppeared = Constants.timeNever.rawValue.doubleValue
            timeToAcceptDelay.invalidate()
            
            if !trainingMode {
                session.score = NSNumber(integer: (session.score.integerValue + 1))
            }
            
        } else {
            noteMistake(.FalsePositive)
        }
    }
    
    private func noteMistake(mistakeType: PlayerAction) {
        
        log(mistakeType, hitType: SuccessType.Picture.rawValue)
        
        if !trainingMode {
            if mistakeType == .FalsePositive {
                let falsePositives = session.errors.integerValue
                session.errors = NSNumber(integer: (falsePositives + 1))
            } else if mistakeType == .Miss {
                let misses = session.miss!.integerValue
                session.miss = NSNumber(integer: (misses + 1))
            }
        }
    }
    
    private func log(action: PlayerAction, hitType: NSNumber) {
        let screen = CGFloat(indexForCurrentSequence + 1)
        var successfulAction = false
        
        if (action == .Hit) {
            successfulAction = true
            model.addMove(screen, positionY: 0, success: successfulAction, interval: 0.0, inverted: trainingMode, delay:timeSinceAnimalAppeared, type: hitType.integerValue)
            
            TextToSpeechHelper.positive()
        } else {
            
            TextToSpeechHelper.negative()

            // To avoid changing data model we will use interval to store mistake type
            var codedMistakeType = VisualSustainMistakeType.Unknown.rawValue
            if (action == .Miss) {
                codedMistakeType = VisualSustainMistakeType.Miss.rawValue
                countTotalMissies += 1 // for warning prompt
                
            } else if (action == .FalsePositive) {
                codedMistakeType = VisualSustainMistakeType.FalsePositive.rawValue
            }
            
            // -100 is special indicator, player skipped 4 turns, not has to be added to the log
            var codedSkipWarning = VisualSustainSkip.NoSkip.rawValue
            if countTotalMissies == totalMissesBeforeWarningPrompt {
                codedSkipWarning = VisualSustainSkip.FourSkips.rawValue
                showWarningPrompt()
            }
            
            let delay = (timeSinceAnimalAppeared == Constants.timeNever.rawValue.doubleValue) ? 0 : timeSinceAnimalAppeared;
            
            model.addMove(screen, positionY: codedSkipWarning, success: false, interval: codedMistakeType, inverted: trainingMode, delay: delay, type: hitType.integerValue)
        }
    }
    
    func showWarningPrompt() {
        
        TextToSpeechHelper.negative()
        
        countTotalMissies = 0
        let label = UILabel()
        label.text = labels.reminder
        label.font = UIFont.systemFontOfSize(32.0)
        label.frame = CGRectMake(120, 610, 0, 0)
        label.sizeToFit()
        label.tag = labelTagAttention
        view.addSubview(label)
        
        delay(timeWarningPromptRemainingOnScreen) {
            for v in self.view.subviews {
                if v.tag == self.labelTagAttention {
                    if !v.isKindOfClass(UIButton) {
                        v.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    private func pictureIsAnimal(gameSequence: GameSequence) -> Bool {
        animalType = SuccessType.Picture.rawValue
        return
            gameSequence.picture == Picture.Pig ||
            gameSequence.picture == Picture.Cat ||
            gameSequence.picture == Picture.Dog ||
            gameSequence.picture == Picture.Horse ||
            gameSequence.picture == Picture.Fish ||
            gameSequence.picture == Picture.Mouse
    }
    
    private func soundIsAnimal(gameSequence: GameSequence) -> Bool {
        animalType = SuccessType.Sound.rawValue
        return
                gameSequence.sound.lowercaseString == "pig" ||
                gameSequence.sound.lowercaseString == "cat" ||
                gameSequence.sound.lowercaseString == "dog" ||
                gameSequence.sound.lowercaseString == "horse" ||
                gameSequence.sound.lowercaseString == "fish"
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
    
    override  func getComment() -> String {
        return session.comment
    }
    
    override func quit() {
        gamePaused = true
        
        if timeSinceAnimalAppeared != Constants.timeNever.rawValue.doubleValue {
            // Last animal was missed
            noteMistake(.Miss)
        }
        
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
