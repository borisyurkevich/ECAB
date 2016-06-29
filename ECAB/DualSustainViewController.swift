//
//  DualSustainViewController.swift
//  ECAB
//
//  Created by Raphaël Bertin on 29/06/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

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
    
    var pictureAutoPresent = false
    
    let totalMissesBeforeWarningPrompt = 4
    let timeNever = 86400.0 // Seconds in a day. Assuming that accepted dealy will be no longer than a day.
    let timersScale = 0.01 // Hundreds of a second
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
    var countAnimals = 0
    var countObjects = 0
    
    var imageVisibleOnScreen = UIImageView(image: UIImage(named: "white_rect"))
    let labelTagAttention = 1
    let tagChangingGamePicture = 2
    let timeWarningPromptRemainingOnScreen = 4.0
    
    
    
    private enum PlayerAction {
        case Miss
        case FalsePositive
        case Hit
    }
    
    
    
    override func viewDidLoad() {
        sessionType = 2
        greeingMessage = labels.practice
        playSound(.Practice1)
    
        super.viewDidLoad()
        
        imageVisibleOnScreen.frame = CGRectMake(0, 0, imageVisibleOnScreen.frame.size.width * 2, imageVisibleOnScreen.frame.size.height * 2)
        imageVisibleOnScreen.center = view.center;
        imageVisibleOnScreen.hidden = true
        imageVisibleOnScreen.tag = tagChangingGamePicture
        view.addSubview(imageVisibleOnScreen)
        
        timePictureVisible = model.data.visSustSpeed.doubleValue
        timeBlankSpaceVisible = model.data.visSustDelay.doubleValue
        timeAcceptDelay = model.data.visSustAcceptedDelay!.doubleValue
        
        session.speed = timePictureVisible
        session.vsustBlank = timeBlankSpaceVisible
        session.vsustAcceptedDelay = timeAcceptDelay
        
        timeSinceAnimalAppeared = timeNever
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
        countAnimals = 0
        
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
                playSound(.Practice1)
                
            case 1 ... DualSustainFactory.practiceSequence.count:
                if !pictureAutoPresent {
                    startAutoPresentPictures()
                }
                indexForCurrentSequence = currentScreenShowing - 1
                updateView(DualSustainFactory.practiceSequence[indexForCurrentSequence].picture)
                playSound(DualSustainFactory.practiceSequence[indexForCurrentSequence].sound)
                
            case DualSustainFactory.practiceSequence.count + 1:
                stopAutoPresentPictures()
                presentMessage(labels.gameReady)
                
            case DualSustainFactory.practiceSequence.count + 2 ... (DualSustainFactory.gameSequence.count + (DualSustainFactory.practiceSequence.count + 1)):
                if !pictureAutoPresent {
                    startTest()
                    startAutoPresentPictures()
                }
                indexForCurrentSequence = currentScreenShowing - (DualSustainFactory.practiceSequence.count + 2)
                updateView(DualSustainFactory.gameSequence[indexForCurrentSequence].picture)
                playSound(DualSustainFactory.gameSequence[indexForCurrentSequence].sound)
            
            case DualSustainFactory.gameSequence.count + (DualSustainFactory.practiceSequence.count + 2):
                stopAutoPresentPictures()
                stopTest()
                presentMessage(labels.gameEnd)
                
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
        currentScreenShowing = 23
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
    
    private func updateView(pic: Picture) {
        
        if gamePaused {
            return
        }
        
        let newImage = UIImage(named: pic.rawValue)
        let newFrame = UIImageView(image: newImage)
        
        imageVisibleOnScreen.frame = CGRectMake(0, 0, newFrame.frame.size.width * 2, newFrame.frame.size.height * 2)
        imageVisibleOnScreen.center = view.center;
        imageVisibleOnScreen.image = newImage
        
        if isAnimal(pic) {
            timeSinceAnimalAppeared = 0
            timeToAcceptDelay.invalidate()
            timeToAcceptDelay = NSTimer.scheduledTimerWithTimeInterval(timersScale,
                                                                       target: self,
                                                                       selector: #selector(DualSustainViewController.updateAcceptedDelay),
                                                                       userInfo: nil,
                                                                       repeats: true)
        }
        
        if (!trainingMode) {
            if isAnimal(pic) {
                countAnimals += 1
            } else {
                countObjects += 1
            }
            session.vsustAnimals = countAnimals
            session.vsustObjects = countObjects
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
        timeSinceAnimalAppeared += timersScale
        if timeSinceAnimalAppeared > timeAcceptDelay {
            timeToAcceptDelay.invalidate()
            timeSinceAnimalAppeared = timeNever
            // Because stopwatch was alive long enough to reach its limit,
            // we know that animal was missed.
            noteMistake(.Miss)
        }
    }
    
    override func tapHandler(touchLeft: Bool) {
        // Ignore touchLeft, whole screen is the target
        
        if timeSinceAnimalAppeared <= timeAcceptDelay {
            countTotalMissies = 0
            
            playSound(.Positive)
            log(.Hit)
            
            // Prevents following taps to be sucesfull
            timeSinceAnimalAppeared = timeNever
            timeToAcceptDelay.invalidate()
            
            if !trainingMode {
                let score = session.score.integerValue
                session.score = NSNumber(integer: (score + 1))
            }
            
        } else {
            noteMistake(.FalsePositive)
        }
    }
    
    private func noteMistake(mistakeType: PlayerAction) {
        
        log(mistakeType)
        
        if !trainingMode {
            if mistakeType == .FalsePositive {
                let falsePositives = session.errors.integerValue
                session.errors = NSNumber(integer: (falsePositives + 1))
            } else if mistakeType == .Miss {
                let misses = session.vsustMiss!.integerValue
                session.vsustMiss = NSNumber(integer: (misses + 1))
            }
        }
    }
    
    private func log(action: PlayerAction) {
        let screen = CGFloat(indexForCurrentSequence + 1)
        var successfulAction = false
        
        if (action == .Hit) {
            successfulAction = true
            model.addCounterpointingMove(screen, positionY: 0, success: successfulAction, interval: 0.0, inverted: trainingMode, delay:timeSinceAnimalAppeared)
            
        } else {
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
            
            var myDelay = timeSinceAnimalAppeared
            if myDelay == timeNever {
                myDelay = 0
            }
            model.addCounterpointingMove(screen, positionY: codedSkipWarning, success: false, interval: codedMistakeType, inverted: trainingMode, delay: myDelay)
        }
    }
    
    func showWarningPrompt() {
        
        playSound(.Negative)
        
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
    
    private func isAnimal(pic: Picture) -> Bool {
        var returnValue = false
        if pic == .Pig || pic == .Cat || pic == .Dog || pic == .Horse || pic == .Fish || pic == .Mouse {
            returnValue = true
        }
        return returnValue
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
        
        if timeSinceAnimalAppeared != timeNever {
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
        
        // Removes labesls
        for v in view.subviews {
            if v.isKindOfClass(UILabel) {
                v.removeFromSuperview()
            }
        }
    }
    
}
