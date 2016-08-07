//
//  VisualSustainViewController.swift
//  ECAB
//
//  All time here is counted in seconds. 1.0 - is one second double.
//
//  Created by Raphael Bertin on 02/07/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class VisualSustainViewController: CounterpointingViewController {
    
    private struct Labels {
        let practice1 = NSLocalizedString("Practice 1: do you know these animals?", comment: "visual sustain greeting")
        let practice2 = NSLocalizedString("Now, touch the screen\nevery time you see one of the animals", comment: "visual sustain")
        let gameReady = NSLocalizedString("Keep touch the screen\nevery time you see one of the animals", comment: "visual sustain")
        let reminder = NSLocalizedString("Remember, touch the screen every time you see an animal", comment: "Visual sustain. Appear when subjects ignores x amount of targets")
        let gameEnd = NSLocalizedString("Stop.", comment: "visual sustain")
        let testOver = NSLocalizedString("Test is Over", comment: "visual sustain alert title")
        let testOverBody = NSLocalizedString("You've been running the test for %@", comment: "visual sustain alert body")
        let testOverAction = NSLocalizedString("Stop the test", comment: "visual sustain alert ok")
    }
    private let labels = Labels()
	
	// Place in array of pictures that appear on the screen.
	// There's 2 arrays: training and game.
	var indexForCurrentSequence = 0
	
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
	var countAnimals = 0
	var countObjects = 0
	
	var imageVisibleOnScreen = UIImageView(image: UIImage(named: "white_rect"))
	let labelTagAttention = 1
	let tagChangingGamePicture = 2
	let timeWarningPromptRemainingOnScreen = 4.0
	
	override func viewDidLoad() {
		sessionType = GamesIndex.VisualSust
        greeingMessage = labels.practice1
        
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
		countAnimals = 0
		
		timeToGameOver.invalidate()
		timeToGameOver = NSTimer.scheduledTimerWithTimeInterval(timeGameOver,
			target: self,
			selector: #selector(VisualSustainViewController.gameOver),
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
			presentMessage(labels.practice1)
            TextToSpeechHelper.say("Practice 1")
			
		case 1:
			showFirstView()
			
		case 2:
			removeFirstView()
			presentMessage(labels.practice2)
            TextToSpeechHelper.say("Practice 2")
			
		case 3 ... 23:
			if !pictureAutoPresent {
				startAutoPresentPictures()
			}
			indexForCurrentSequence = currentScreenShowing - 3
			updateView(VisualSustainFactory.practiceSequence[indexForCurrentSequence].picture)
			
		case 24:
			stopAutoPresentPictures()
			presentMessage(labels.gameReady)
            TextToSpeechHelper.say("Game 1")
			
		case 25 ... 175:
			if !pictureAutoPresent {
				startTest()
				startAutoPresentPictures()
			}
			indexForCurrentSequence = currentScreenShowing - 25
			updateView(VisualSustainFactory.gameSequence[indexForCurrentSequence].picture)
			
		case 176:
			stopAutoPresentPictures()
			stopTest()
			presentMessage(labels.gameEnd)
            TextToSpeechHelper.say("End of game")
			
		case 177:
			presentPause()
			
		default:
			break
		}
	}
	
	// Called when skip button tapped
	override func skip() {
    
        // Removes 5 images on tutorial.
		removeFirstView()
        
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
			timeToAcceptDelay = NSTimer.scheduledTimerWithTimeInterval(Constants.timersScale.rawValue.doubleValue,
				target: self,
				selector: #selector(VisualSustainViewController.updateAcceptedDelay),
				userInfo: nil,
				repeats: true)
		}
		
		if (!trainingMode && pic != .Empty) {
			if isAnimal(pic) {
				countAnimals += 1
			} else {
				countObjects += 1
			}
			session.pictures = countAnimals
			session.objects = countObjects
		}
		
		if timeBlankSpaceVisible >= model.kMinDelay {
            
            timeToPresentWhiteSpace.invalidate()
            timeToPresentWhiteSpace = NSTimer.scheduledTimerWithTimeInterval(timePictureVisible,
                target: self,
                selector: #selector(VisualSustainViewController.showWhiteSpace),
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
	
	func showFirstView() {
		
		let pig = UIImage(named: Picture.Pig.rawValue)
		let dog = UIImage(named: Picture.Dog.rawValue)
		let fish = UIImage(named: Picture.Fish.rawValue)
		let horse = UIImage(named: Picture.Horse.rawValue)
		let cat = UIImage(named: Picture.Cat.rawValue)
		
		let pigImage = UIImageView(image: pig)
		let dogImage = UIImageView(image: dog)
		let fishImage = UIImageView(image: fish)
		let horseImage = UIImageView(image: horse)
		let catImage = UIImageView(image: cat)
		
		let images: [UIImageView] = [pigImage, dogImage, fishImage, horseImage, catImage]
		for image in images {
			image.frame = CGRectMake(0, 0, image.frame.width * 2, image.frame.height * 2)
		}
		
		pigImage.center = CGPointMake(200, 200)
		dogImage.center = CGPointMake(800, 200)
		fishImage.center = CGPointMake(200, 600)
		horseImage.center = CGPointMake(800, 600)
		catImage.center = view.center
		
		for image in images {
			view.addSubview(image)
		}
	}
	func removeFirstView() {
		for v in view.subviews {
			if v.tag != labelTagAttention && v.tag != tagChangingGamePicture {
				if !v.isKindOfClass(UIButton) {
					v.removeFromSuperview()
				}
			}
		}
	}
	
	override func tapHandler(touchLeft: Bool) {
		// Ignore touchLeft, whole screen is the target
		
		if timeSinceAnimalAppeared <= timeAcceptDelay {
			countTotalMissies = 0
			
            TextToSpeechHelper.positive();

            log(.Hit)
			
			// Prevents following taps to be sucesfull
			timeSinceAnimalAppeared = Constants.timeNever.rawValue.doubleValue
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
				let misses = session.miss!.integerValue
				session.miss = NSNumber(integer: (misses + 1))
			}
		}
	}
	
	private func log(action: PlayerAction) {
		let screen = CGFloat(indexForCurrentSequence + 1)
		var successfulAction = false
		
		if (action == .Hit) {
			successfulAction = true
			model.addMove(screen, positionY: 0, success: successfulAction, interval: 0.0, inverted: trainingMode, delay:timeSinceAnimalAppeared, type: SuccessType.Picture.rawValue)
			
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
			if myDelay == Constants.timeNever.rawValue.doubleValue {
				myDelay = 0
			}
			model.addMove(screen, positionY: codedSkipWarning, success: false, interval: codedMistakeType, inverted: trainingMode, delay: myDelay, type: SuccessType.Picture.rawValue)
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
	
	private func isAnimal(pic: Picture) -> Bool {
		return
                pic == .Pig ||
                pic == .Cat ||
                pic == .Dog ||
                pic == .Horse ||
                pic == .Fish ||
                pic == .Mouse
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
		
		// Removes labesls
		for v in view.subviews {
			if v.isKindOfClass(UILabel) {
				v.removeFromSuperview()
			}
		}
	}
	
	override func presentPause() {
		timeToPresentNextScreen.pause()
		timeToPresentWhiteSpace.pause()
		timeToGameOver.pause()
		timeToAcceptDelay.pause()
		
		super.presentPause()
	}
	override func resumeTest() {
		timeToPresentNextScreen.resume()
		timeToPresentWhiteSpace.resume()
		timeToGameOver.resume()
		timeToAcceptDelay.resume()
	}
}
