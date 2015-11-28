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
	
	// When false, test in traning mode, when true — game mode
	private var gameStarted = false
	
	// Place in array of pictures that appear on the screen.
	// There's 2 arrays: training and game.
	private var indexForCurrentSequence = 0
	
	private let timeNever = -1.0
	private let timersScale = 0.1 // Tenth of a second
	private var timeToPresentNextScreen = NSTimer()
	private var timeToGameOver = NSTimer()
	private var timeToAcceptDelay = NSTimer()
	private var dateAcceptDelayStart = NSDate()
	
	private var timeSinceAnimalAppeared = 0.0
	private var timeBlankSpaceVisible = 0.0
	private var timePictureVisible = 0.0 // Called "exposure" in the UI and log.
	private let timeGameOver = 300.0

	private var countTotalMissies = 0
	private var countAnimal = 0
	private var countObjects = 0
	
	private var imageVisibleOnScreen = UIImageView(image: UIImage(named: "white_rect"))
	private let labelTagAttention = 1
	private let timeAttentionLabelRemainingOnScreen = 3.0

    override func viewDidLoad() {
		sessionType = 2
		greeingMessage = "Practice 1. Ready..."
        super.viewDidLoad()
		
		imageVisibleOnScreen.frame = CGRectMake(0, 0, imageVisibleOnScreen.frame.size.width * 2, imageVisibleOnScreen.frame.size.height * 2)
		imageVisibleOnScreen.center = view.center;
		
		timePictureVisible = model.data.visSustSpeed.doubleValue
		timeBlankSpaceVisible = model.data.visSustDelay.doubleValue
		session.speed = timePictureVisible
		session.vsustBlank = timeBlankSpaceVisible
		
		timeSinceAnimalAppeared = timeNever
	}
	
	struct Constants {
		static let kTolerateMistakes = 3
	}
	
	enum Picture: String {
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
	
	enum Mistake {
		case Miss
		case FalsePositive
	}
	
	private let practiceSequence: [Picture] = [.Ball, .Bus, .Boot, .Pig, .Sun, .Star, .Leaf, .Key, .Cat, .Bed, .Sock, .Horse, .Cake, .Boat, .Book, .Dog, .Car, .Clock, .Fish, .Train, .Empty];
	private let gameSequence: [Picture] = [.Sun, .Key, .Sock, .Boat, .Boot, .Pig, .Clock, .Car, .Book, .Door, .Cat, .Ball, .Bed, .Bus, .Horse, .Train, .Cake, .Leaf, .Dog, .Star, .Spoon, .Chair, .Bike, .Tree, .Fish, .Door, .Bus, .Ball, .Sun, .Horse, .Spoon, .Bed, .Leaf, .Boot, .Fish, .Star, .Cake, .Tree, .Sock, .Clock, .Book, .Cat, .Key, .Train, .Chair, .Pig,. Boat, .Car, .Bike, .Dog, .Bus, .Bed, .Sun, .Chair, .Dog, .Train, .Ball, .Horse, .Bike, .Leaf, .Sock, .Cake, .Boat, .Cat, .Key, .Door, .Tree, .Pig, .Spoon, .Clock, .Car, .Boot, .Book, .Fish, .Star, .Bike, .Clock, .Car, .Pig, .Boat, .Tree, .Cake, .Sock, .Bus, .Star, .Door, .Horse, .Spoon, .Ball, .Dog, .Boot, .Key, .Leaf, .Train, .Cat, .Chair, .Sun, .Bed, .Fish, .Book, .Cake, .Ball, .Star, .Bus, .Pig, .Train, .Boat, .Sun, .Fish, .Spoon, .Leaf, .Bed, .Dog, .Tree, .Door, .Boot, .Bike, .Cat, .Car, .Sock, .Chair, .Key, .Clock, .Book, .Horse, .Door,.Bike, .Car, .Leaf, .Cake, .Fish, .Bed, .Boot, .Horse, .Bus, .Train, .Sun, .Sock, .Chair, .Dog, .Star, .Ball, .Train, .Pig, .Key, .Clock, .Spoon, .Book, .Cat, .Boat, .Empty]
	
	func updateView(pic: Picture) {
		
		addGestures()
		
		let newImage = UIImage(named: pic.rawValue)
		let whiteSpace = UIImage(named: Picture.Empty.rawValue)
		let newFrame = UIImageView(image: newImage)
		
		imageVisibleOnScreen.frame = CGRectMake(0, 0, newFrame.frame.size.width * 2, newFrame.frame.size.height * 2)
		imageVisibleOnScreen.center = view.center;
		imageVisibleOnScreen.image = newImage
		
		view.addSubview(imageVisibleOnScreen)
		
		if (!trainingMode && isAnimal(pic)) {
			countAnimal++
		} else if (!trainingMode) {
			countObjects++
		}
		session.vsustAnimals = countAnimal
		session.vsustObjects = countObjects
		
		
		delay(timePictureVisible) {
			self.imageVisibleOnScreen.image = whiteSpace
			
			var currentSuequence: [Picture]
			if self.trainingMode {
				currentSuequence = self.practiceSequence
			} else {
				currentSuequence = self.gameSequence
			}
			if self.isAnimal(currentSuequence[self.indexForCurrentSequence]) {
				
				let timePassed = self.timeSinceAnimalAppeared
				let acceptedDelay = self.model.data.visSustAcceptedDelay!.doubleValue + 1
				
				if timePassed != acceptedDelay {
					// New animal appeared on the screen and player didn't reset the counter
					// by tapping on the screen
					self.noteMistake(.Miss)
				}
				self.startDelayTimer()
			}
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
	
	override func tapHandler(touchLeft: Bool) {
		// Ignore touchLeft, whole screen is the target
		
		let screen: CGFloat = CGFloat(indexForCurrentSequence + 1)
		let result = true
		if timeSinceAnimalAppeared <= Double(model.data.visSustAcceptedDelay!) {
			countTotalMissies = 0
			
			successSound.play()
			model.addCounterpointingMove(screen, positionY: 0, success: result, interval: 0.0, inverted: trainingMode, delay:timeSinceAnimalAppeared)
			
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
	
	func noteMistake(mistakeType: Mistake) {
		let screen: CGFloat = CGFloat(indexForCurrentSequence + 1)
		let result = false
		
		//To avoid changing data model we will use interval to store mistake type
		var codedMistakeType = VisualSustainMistakeType.Unknown.rawValue
		if (mistakeType == .Miss) {
			codedMistakeType = VisualSustainMistakeType.Miss.rawValue
			countTotalMissies += 1
		} else if (mistakeType == .FalsePositive) {
			codedMistakeType = VisualSustainMistakeType.FalsePositive.rawValue
		}
		
		// -100 is special indicator, player skipped 4 turns, not has to be added to the log
		var codedSkipWarning = VisualSustainSkip.NoSkip.rawValue
		if countTotalMissies > Constants.kTolerateMistakes {
			codedSkipWarning = VisualSustainSkip.FourSkips.rawValue
			attentionSound.play()
			countTotalMissies = 0
			let label = UILabel()
			label.text = "Remember, touch the screen every time you see an animal"
			label.font = UIFont.systemFontOfSize(32.0)
			label.frame = CGRectMake(120, 480, 0, 0)
			label.sizeToFit()
			label.tag = labelTagAttention
			view.addSubview(label)
			
			delay(timeAttentionLabelRemainingOnScreen) {
				for v in self.view.subviews {
					if v.tag == self.labelTagAttention {
						if !v.isKindOfClass(UIButton) {
							v.removeFromSuperview()
						}
					}
				}
			}
		}

		model.addCounterpointingMove(screen, positionY: codedSkipWarning, success: result, interval: codedMistakeType, inverted: trainingMode, delay: timeSinceAnimalAppeared)

		if !trainingMode {
			if mistakeType == .FalsePositive {
				let errors = session.errors.integerValue
				session.errors = NSNumber(integer: (errors + 1))
			} else if mistakeType == .Miss {
				let errors = session.vsustMiss!.integerValue
				session.vsustMiss = NSNumber(integer: (errors + 1))
			}
		}
	}
	
	override func skip() {
		currentScreenShowing = 23
		presentNextScreen()
	}
	
	override func presentNextScreen() {
		currentScreenShowing++
		
		self.cleanView()
		
		switch currentScreenShowing {
		case 0:
			// This is needed when practice is restarted.
			presentMessage(greeingMessage)
		case 1:
			showFirstView()
		case 2:
			presentMessage("Practice 2. Ready")
		case 3 ... 23:
			if !gameStarted {
				startTheGame()
				gameStarted = true
				trainingMode = true
			}
			indexForCurrentSequence = currentScreenShowing - 3
			
			updateView(practiceSequence[indexForCurrentSequence])
			
		case 24:
			timeToPresentNextScreen.invalidate()
			gameStarted = false
			presentMessage("Game!")
			countTotalMissies = 0
			trainingMode = false
		case 25 ... 175:
		
			if !gameStarted {
				startTheGame()
				gameStarted = true
			}
			
			indexForCurrentSequence = currentScreenShowing - 25
			updateView(gameSequence[indexForCurrentSequence])
			
		case 176:
			presentMessage("...stop")
			timeToPresentNextScreen.invalidate()
			gameStarted = false
		case 177:
			quit()
		default:
			break
		}
	}
	
	func startDelayTimer() {
		timeToAcceptDelay.invalidate()
		dateAcceptDelayStart = NSDate()
		timeToAcceptDelay = NSTimer.scheduledTimerWithTimeInterval(timersScale, target: self, selector: "updateDelayTimer", userInfo: nil, repeats: true)
		self.timeSinceAnimalAppeared = 0
	}
	
	func updateDelayTimer() {
		let timePassedAfterAnimal: NSTimeInterval = dateAcceptDelayStart.timeIntervalSinceNow
		timeSinceAnimalAppeared = abs(timePassedAfterAnimal)
		if timeSinceAnimalAppeared > Double(model.data.visSustAcceptedDelay!) {
			timeToAcceptDelay.invalidate()
		}
	}
	
	func isAnimal(pic: Picture) -> Bool {
		var returnValue = false
		if pic == .Pig || pic == .Cat || pic == .Dog || pic == .Horse || pic == .Fish || pic == .Mouse {
			returnValue = true
		}
		return returnValue
	}
	
	func startTheGame() {
		timeToPresentNextScreen.invalidate()
		timeToPresentNextScreen = NSTimer(timeInterval: timePictureVisible + timeBlankSpaceVisible, target: self, selector: "presentNextScreen", userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(timeToPresentNextScreen, forMode: NSRunLoopCommonModes)
		
		timeToGameOver = NSTimer(timeInterval: timeGameOver, target: self, selector: "gameOver", userInfo: nil, repeats: false)
		NSRunLoop.currentRunLoop().addTimer(timeToGameOver, forMode: NSRunLoopCommonModes)
	}
	
	func gameOver() {
		timeToPresentNextScreen.invalidate()
		timeToAcceptDelay.invalidate()
		timeToGameOver.invalidate()
		
		let alertView = UIAlertController(title: "Test is Over", message: "You've been running the test for \(timeGameOver / 60) minutes", preferredStyle: .Alert)
		alertView.addAction(UIAlertAction(title: "Stop the test", style: .Default, handler: {
			(okAction) -> Void in
			self.presentPause()
		}))
		presentViewController(alertView, animated: true, completion: nil)
	}
	
	override func quit() {
		
		if timeSinceAnimalAppeared != timeNever {
			// Last animal was missed
			noteMistake(.Miss)
		}
		
		super.quit()
		timeToPresentNextScreen.invalidate()
		timeToAcceptDelay.invalidate()
		timeToGameOver.invalidate()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		timeToPresentNextScreen.invalidate()
	}
	
	override func cleanView() {
		
		for v in view.subviews {
		
			if v.tag != labelTagAttention {
				if !v.isKindOfClass(UIButton) {
					v.removeFromSuperview()
				}
			}
		}
	}

}
