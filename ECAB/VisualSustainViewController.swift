//
//  VisualSustainViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 02/07/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class VisualSustainViewController: CounterpointingViewController {
	
	private var screenCountSinceAnimalAppeared = 0.0
	private var timer = NSTimer()
	private var gameSpeed = 0.2
	private let transitionSpeed = 1.8
	private var mistakeCounter = 0
	private var gameStarted = false
	private var index = 0
	private var testItem = UIImageView(image: UIImage(named: "white_rect"))
	private var stopwatch = NSTimer()
	private let stopwatchScale = 0.1
	private var stopwatchStartDate = NSDate()
	private var resetTimerValue = 0.0
	
	let attentionLabelTag = 1
	let secondsAttentionLabelRemainingOnScreen = 3.0

    override func viewDidLoad() {
		sessionType = 2
		greeingMessage = "Practice 1. Ready..."
        super.viewDidLoad()
		
		gameSpeed = model.data.visSustSpeed.doubleValue
		testItem.frame = CGRectMake(0, 0, testItem.frame.size.width * 2, testItem.frame.size.height * 2)
		testItem.center = view.center;
		session.speed = model.data.visSustSpeed.doubleValue
		
		resetTimerValue = Double(model.data.visSustAcceptedDelay!) + 1
		screenCountSinceAnimalAppeared = resetTimerValue
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
		
		view.addSubview(self.testItem)
		
		// Add Image
		let newImage = UIImage(named: pic.rawValue)
		let middleImage = UIImage(named: Picture.Empty.rawValue)
			
		self.testItem.image = middleImage
		let newFrame = UIImageView(image: newImage)
		
		self.testItem.frame = CGRectMake(0, 0, newFrame.frame.size.width * 2, newFrame.frame.size.height * 2)
		self.testItem.center = self.view.center;
		
		delay(transitionSpeed) {
			self.testItem.image = newImage
			
			var currentSuequence: [Picture]
			if self.trainingMode {
				currentSuequence = self.practiceSequence
			} else {
				currentSuequence = self.gameSequence
			}
			if self.isAnimal(currentSuequence[self.index]) {
				
				let timePassed = self.screenCountSinceAnimalAppeared
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
	
	override func tapHandler(sender: UITapGestureRecognizer) {
		
		let screen: CGFloat = CGFloat(index + 1)
		let result = true
		if screenCountSinceAnimalAppeared <= Double(model.data.visSustAcceptedDelay!) {
			mistakeCounter = 0
			
			successSound.play()
			model.addCounterpointingMove(screen, positionY: 0, success: result, interval: 0.0, inverted: trainingMode, delay:screenCountSinceAnimalAppeared)
			
			// Prevents following taps to be sucesfull
			screenCountSinceAnimalAppeared = resetTimerValue
			stopwatch.invalidate()
			
			if !trainingMode {
				let score = session.score.integerValue
				session.score = NSNumber(integer: (score + 1))
			}
		} else {
			noteMistake(.FalsePositive)
		}
	}
	
	func noteMistake(mistakeType: Mistake) {
		let screen: CGFloat = CGFloat(index + 1)
		let result = false
		mistakeCounter += 1
		
		//To avoid changing data model we will use interval to store mistake type
		var codedMistakeType = VisualSustainMistakeType.Unknown.rawValue
		if (mistakeType == .Miss) {
			codedMistakeType = VisualSustainMistakeType.Miss.rawValue
		} else if (mistakeType == .FalsePositive) {
			codedMistakeType = VisualSustainMistakeType.FalsePositive.rawValue
		}
		
		// -100 is special indicator, player skipped 4 turns, not has to be added to the log
		var codedSkipWarning = VisualSustainSkip.NoSkip.rawValue
		if mistakeCounter > Constants.kTolerateMistakes {
			codedSkipWarning = VisualSustainSkip.FourSkips.rawValue
			attentionSound.play()
			mistakeCounter = 0
			let label = UILabel()
			label.text = "Remember, touch the screen every time you see an animal"
			label.font = UIFont.systemFontOfSize(32.0)
			label.frame = CGRectMake(120, 480, 0, 0)
			label.sizeToFit()
			label.tag = attentionLabelTag
			view.addSubview(label)
			
			delay(secondsAttentionLabelRemainingOnScreen) {
				for v in self.view.subviews {
					if v.tag == self.attentionLabelTag {
						if !v.isKindOfClass(UIButton) {
							v.removeFromSuperview()
						}
					}
				}
			}
		}

		model.addCounterpointingMove(screen, positionY: codedSkipWarning, success: result, interval: codedMistakeType, inverted: trainingMode, delay: screenCountSinceAnimalAppeared)

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
		
		switch self.currentScreenShowing {
		case 0:
			// This is needed when practice is restarted.
			self.presentMessage(self.greeingMessage)
		case 1:
			self.showFirstView()
		case 2:
			self.presentMessage("Practice 2. Ready")
		case 3 ... 23:
			if !self.gameStarted {
				self.startTheGame()
				self.gameStarted = true
			}
			self.index = self.currentScreenShowing - 3
			
			self.updateView(self.practiceSequence[self.index])
			
		case 24:
			self.timer.invalidate()
			self.gameStarted = false
			self.presentMessage("Game!")
			mistakeCounter = 0
			self.trainingMode = false
		case 25 ... 175:
		
			if !self.gameStarted {
				self.startTheGame()
				self.gameStarted = true
			}
			
			self.index = self.currentScreenShowing - 25
			self.updateView(self.gameSequence[self.index])
			
		case 176:
			self.presentMessage("...stop")
			self.timer.invalidate()
			self.gameStarted = false
		case 177:
			self.quit()
		default:
			break
		}
	}
	
	func startDelayTimer() {
		stopwatch.invalidate()
		stopwatchStartDate = NSDate()
		stopwatch = NSTimer.scheduledTimerWithTimeInterval(stopwatchScale, target: self, selector: "updateDelayTimer", userInfo: nil, repeats: true)
		self.screenCountSinceAnimalAppeared = 0
	}
	
	func updateDelayTimer() {
		let timePassedAfterAnimal: NSTimeInterval = stopwatchStartDate.timeIntervalSinceNow
		screenCountSinceAnimalAppeared = abs(timePassedAfterAnimal)
		if screenCountSinceAnimalAppeared > Double(model.data.visSustAcceptedDelay!) {
			stopwatch.invalidate()
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
		timer = NSTimer(timeInterval: gameSpeed + transitionSpeed, target: self, selector: "presentNextScreen", userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
	}
	
	override func quit() {
		
		if screenCountSinceAnimalAppeared != resetTimerValue {
			// Last animal was missed
			noteMistake(.Miss)
		}
		
		super.quit()
		timer.invalidate()
		stopwatch.invalidate()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		timer.invalidate()
	}
	
	override func cleanView() {
		
		if view.gestureRecognizers != nil {
			for g in view.gestureRecognizers! {
				if let recognizer = g as? UITapGestureRecognizer {
					view.removeGestureRecognizer(recognizer)
				}
			}
		}
		
		for v in view.subviews {
		
			if v.tag != attentionLabelTag {
				if !v.isKindOfClass(UIButton) {
					v.removeFromSuperview()
				}
			}
		}
	}

}
