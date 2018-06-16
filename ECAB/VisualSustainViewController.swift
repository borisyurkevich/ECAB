//
//  VisualSustainViewController.swift
//  ECAB
//
//  All time here is counted in seconds. 1.0 - is one second double.
//
//  Created by Boris Yurkevich on 02/07/2015.
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
	let timeNever = 86400.0 // Seconds in a day. Assuming that accepted dealy will be no longer than a day.
	let timersScale = 0.01 // Hundreds of a second
    var timeToPresentNextScreen = Timer()
    var timeToPresentWhiteSpace = Timer()
	var timeToGameOver = Timer()
	var dateAcceptDelayStart = Date()
	
	var timeToAcceptDelay = Timer()
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
    
    private var isReactionLogged = false

	private enum Picture: String {
		case Empty = "white_rect"
		case Bed = "bed_inverse"
		case Ball = "ball"
		case Bike = "bike_inverse"
		case Boat = "boat_inverse"
		case Book = "book"
		case Boot = "boot"
		case Bus = "bus"
		case Cake = "cake"
		case Car = "car_inverse"
		case Cat = "cat_inverse"
		case Chair = "chair"
		case Clock = "clock"
		case Dog = "dog"
		case Door = "door"
		case Fish = "fish_iverse"
		case Horse = "horse_inverse"
		case Key = "key"
		case Leaf = "leaf"
		case Mouse = "mouse"
		case Pig = "pig"
		case Sock = "sock"
		case Spoon = "spoon"
		case Sun = "sun"
		case Star = "star_yellow"
		case Train = "train_inverse"
		case Tree = "tree"
	}
	
	private enum PlayerAction {
		case miss
		case falsePositive
		case hit
        case repeatedTouch
	}
	
	private let practiceSequence: [Picture] = [.Ball, .Bus, .Boot, .Pig, .Sun, .Star, .Leaf, .Key, .Cat, .Bed, .Sock, .Horse, .Cake, .Boat, .Book, .Dog, .Car, .Clock, .Fish, .Train, .Empty];
	private let gameSequence: [Picture] = [.Sun, .Key, .Sock, .Boat, .Boot, .Pig, .Clock, .Car, .Book, .Door, .Cat, .Ball, .Bed, .Bus, .Horse, .Train, .Cake, .Leaf, .Dog, .Star, .Spoon, .Chair, .Bike, .Tree, .Fish, .Door, .Bus, .Ball, .Sun, .Horse, .Spoon, .Bed, .Leaf, .Boot, .Fish, .Star, .Cake, .Tree, .Sock, .Clock, .Book, .Cat, .Key, .Train, .Chair, .Pig,. Boat, .Car, .Bike, .Dog, .Bus, .Bed, .Sun, .Chair, .Dog, .Train, .Ball, .Horse, .Bike, .Leaf, .Sock, .Cake, .Boat, .Cat, .Key, .Door, .Tree, .Pig, .Spoon, .Clock, .Car, .Boot, .Book, .Fish, .Star, .Bike, .Clock, .Car, .Pig, .Boat, .Tree, .Cake, .Sock, .Bus, .Star, .Door, .Horse, .Spoon, .Ball, .Dog, .Boot, .Key, .Leaf, .Train, .Cat, .Chair, .Sun, .Bed, .Fish, .Book, .Cake, .Ball, .Star, .Bus, .Pig, .Train, .Boat, .Sun, .Fish, .Spoon, .Leaf, .Bed, .Dog, .Tree, .Door, .Boot, .Bike, .Cat, .Car, .Sock, .Chair, .Key, .Clock, .Book, .Horse, .Door,.Bike, .Car, .Leaf, .Cake, .Fish, .Bed, .Boot, .Horse, .Bus, .Train, .Sun, .Sock, .Chair, .Dog, .Star, .Ball, .Train, .Pig, .Key, .Clock, .Spoon, .Book, .Cat, .Boat, .Empty]
	
	override func viewDidLoad() {
		sessionType = 2
        greeingMessage = labels.practice1
        
		super.viewDidLoad()
		
		imageVisibleOnScreen.frame = CGRect(x: 0, y: 0, width: imageVisibleOnScreen.frame.size.width * 2, height: imageVisibleOnScreen.frame.size.height * 2)
		imageVisibleOnScreen.center = view.center;
		imageVisibleOnScreen.isHidden = true
		imageVisibleOnScreen.tag = tagChangingGamePicture
		view.addSubview(imageVisibleOnScreen)
		
		timePictureVisible = model.data.visSustSpeed.doubleValue
		timeBlankSpaceVisible = model.data.visSustDelay.doubleValue
		timeAcceptDelay = model.data.visSustAcceptedDelay!.doubleValue
		
		session.speed = NSNumber(value: timePictureVisible)
		session.vsustBlank = timeBlankSpaceVisible as NSNumber
		session.vsustAcceptedDelay = timeAcceptDelay as NSNumber
		
		timeSinceAnimalAppeared = timeNever
	}
	
	func startAutoPresentPictures() {
		pictureAutoPresent = true
		imageVisibleOnScreen.isHidden = false
	}
	func stopAutoPresentPictures() {
		pictureAutoPresent = false
		imageVisibleOnScreen.isHidden = true
	}
	
	// Start and stop test is enabling logic to run the game in non training mode
	func startTest() {
		trainingMode = false
		countObjects = 0
		countAnimals = 0
		
		timeToGameOver.invalidate()
		timeToGameOver = Timer.scheduledTimer(timeInterval: timeGameOver,
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
			
		case 1:
			showFirstView()
			
		case 2:
			removeFirstView()
			presentMessage(labels.practice2)
			
		case 3 ... 23:
			if !pictureAutoPresent {
				startAutoPresentPictures()
			}
			indexForCurrentSequence = currentScreenShowing - 3
			updateView(practiceSequence[indexForCurrentSequence])
			
		case 24:
			stopAutoPresentPictures()
			presentMessage(labels.gameReady)
			
		case 25 ... 175:
			if !pictureAutoPresent {
				startTest()
				startAutoPresentPictures()
			}
			indexForCurrentSequence = currentScreenShowing - 25
			updateView(gameSequence[indexForCurrentSequence])
			
		case 176:
			stopAutoPresentPictures()
			stopTest()
			presentMessage(labels.gameEnd)
			
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
	
	private func updateView(_ pic: Picture) {
		
		if gamePaused {
			return
		}
		
		let newImage = UIImage(named: pic.rawValue)
		let newFrame = UIImageView(image: newImage)
		
		imageVisibleOnScreen.frame = CGRect(x: 0, y: 0, width: newFrame.frame.size.width * 2, height: newFrame.frame.size.height * 2)
		imageVisibleOnScreen.center = view.center;
		imageVisibleOnScreen.image = newImage
        
        isReactionLogged = false
        
        if isAnimal(pic) {
			timeSinceAnimalAppeared = 0
			timeToAcceptDelay.invalidate()
			timeToAcceptDelay = Timer.scheduledTimer(timeInterval: timersScale,
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
			session.vsustAnimals = countAnimals as NSNumber
			session.vsustObjects = countObjects as NSNumber
		}
		
		if timeBlankSpaceVisible >= model.kMinDelay {
            
            timeToPresentWhiteSpace.invalidate()
            timeToPresentWhiteSpace = Timer.scheduledTimer(timeInterval: timePictureVisible,
                target: self,
                selector: #selector(VisualSustainViewController.showWhiteSpace),
                userInfo: nil,
                repeats: false)
		}
        
        timeToPresentNextScreen.invalidate()
        timeToPresentNextScreen = Timer.scheduledTimer(timeInterval: timePictureVisible + timeBlankSpaceVisible,
            target: self,
            selector: #selector(TestViewController.presentNextScreen),
            userInfo: nil,
            repeats: false)
	}
    
    @objc func showWhiteSpace() {
        let whiteSpace = UIImage(named: Picture.Empty.rawValue)
        self.imageVisibleOnScreen.image = whiteSpace
    }
	
	@objc func updateAcceptedDelay() {
		timeSinceAnimalAppeared += timersScale
		if timeSinceAnimalAppeared > timeAcceptDelay {
			timeToAcceptDelay.invalidate()
			timeSinceAnimalAppeared = timeNever
			// Because stopwatch was alive long enough to reach its limit, 
			// we know that animal was missed.
			noteMistake(.miss)
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
			image.frame = CGRect(x: 0, y: 0, width: image.frame.width * 2, height: image.frame.height * 2)
		}
		
		pigImage.center = CGPoint(x: 200, y: 200)
		dogImage.center = CGPoint(x: 800, y: 200)
		fishImage.center = CGPoint(x: 200, y: 600)
		horseImage.center = CGPoint(x: 800, y: 600)
		catImage.center = view.center
		
		for image in images {
			view.addSubview(image)
		}
	}
	func removeFirstView() {
		for v in view.subviews {
			if v.tag != labelTagAttention && v.tag != tagChangingGamePicture {
				if !v.isKind(of: UIButton.self) {
					v.removeFromSuperview()
				}
			}
		}
	}
	
	override func tapHandler(_ touchLeft: Bool) {
		// Ignore touchLeft, whole screen is the target
		
		if timeSinceAnimalAppeared <= timeAcceptDelay {
			countTotalMissies = 0
			
			playSound(.positive)
			log(.hit)
			
			// Prevents following taps to be sucesfull
			timeSinceAnimalAppeared = timeNever
			timeToAcceptDelay.invalidate()
			
			if !trainingMode {
				let score = session.score.intValue
				session.score = NSNumber(value: (score + 1) as Int)
                isReactionLogged = true
			}
			
		} else {
            // Not an animal
            if !isReactionLogged {
                noteMistake(.falsePositive)
                isReactionLogged = true
            } else {
                log(.repeatedTouch)
            }
		}
	}
	
	private func noteMistake(_ mistakeType: PlayerAction) {
		
		log(mistakeType)

		if !trainingMode {
			if mistakeType == .falsePositive {
				let falsePositives = session.errors.intValue
				session.errors = NSNumber(value: (falsePositives + 1) as Int)
			} else if mistakeType == .miss {
				let misses = session.vsustMiss!.intValue
				session.vsustMiss = NSNumber(value: (misses + 1) as Int)
			}
		}
	}
	
	private func log(_ action: PlayerAction) {
		let screen = CGFloat(indexForCurrentSequence + 1)
		
		if (action == .hit) {
			model.addCounterpointingMove(screen, positionY: 0, success: true,
                                         interval: 0.0, inverted: trainingMode,
                                         delay:timeSinceAnimalAppeared)
			
		} else {
			// To avoid changing data model we will use interval to store mistake type
			var codedMistakeType = VisualSustainMistakeType.unknown.rawValue

            switch action {
            case .miss:
                codedMistakeType = VisualSustainMistakeType.miss.rawValue
                countTotalMissies += 1 // for warning prompt
            case .falsePositive:
                codedMistakeType = VisualSustainMistakeType.falsePositive.rawValue
            case .repeatedTouch:
                codedMistakeType = VisualSustainMistakeType.repeated.rawValue
            case .hit:
                fatalError()
            }
			
			// -100 is special indicator, player skipped 4 turns, not has to be added to the log
			var codedSkipWarning = VisualSustainSkip.noSkip.rawValue
			if countTotalMissies == totalMissesBeforeWarningPrompt {
				codedSkipWarning = VisualSustainSkip.fourSkips.rawValue
				showWarningPrompt()
			}
			
			var myDelay = timeSinceAnimalAppeared
			if myDelay == timeNever {
				myDelay = 0
			}
			model.addCounterpointingMove(screen, positionY: codedSkipWarning,
                                         success: false,
                                         interval: codedMistakeType,
                                         inverted: trainingMode, delay: myDelay)
		}
	}
	
	func showWarningPrompt() {
    
		playSound(.negative)
        
		countTotalMissies = 0
		let label = UILabel()
		label.text = labels.reminder
		label.font = UIFont.systemFont(ofSize: 32.0)
		label.frame = CGRect(x: 120, y: 610, width: 0, height: 0)
		label.sizeToFit()
		label.tag = labelTagAttention
		view.addSubview(label)
		
		delay(timeWarningPromptRemainingOnScreen) {
			for v in self.view.subviews {
				if v.tag == self.labelTagAttention {
					if !v.isKind(of: UIButton.self) {
						v.removeFromSuperview()
					}
				}
			}
		}
	}
	
	private func isAnimal(_ pic: Picture) -> Bool {
		var returnValue = false
		if pic == .Pig || pic == .Cat || pic == .Dog || pic == .Horse || pic == .Fish || pic == .Mouse {
			returnValue = true
		}
		return returnValue
	}
	
	@objc func gameOver() {
		gamePaused = true
		timeToAcceptDelay.invalidate()
		timeToGameOver.invalidate()
		
		let secondsPlayed = timeGameOver
		var valueToDisplay = "\(Int(secondsPlayed)) seconds"
		if secondsPlayed >= 60 {
			valueToDisplay = "\(Int(secondsPlayed / 60)) minutes"
		}
		let bodyString = String.localizedStringWithFormat(labels.testOverBody, valueToDisplay)
		let alertView = UIAlertController(title: labels.testOver, message: bodyString, preferredStyle: .alert)
		alertView.addAction(UIAlertAction(title: labels.testOverAction, style: .default, handler: {
			(okAction) -> Void in
			self.presentPause()
		}))
		present(alertView, animated: true, completion: nil)
	}
    
    override  func getComment() -> String {
        return session.comment
    }
	
	override func quit() {
		gamePaused = true
		
		if timeSinceAnimalAppeared != timeNever {
			// Last animal was missed
			noteMistake(.miss)
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
			if v.isKind(of: UILabel.self) {
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
