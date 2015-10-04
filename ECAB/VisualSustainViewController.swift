//
//  VisualSustainViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 02/07/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class VisualSustainViewController: CounterpointingViewController {
	
	private var screenCountSinceAnimalAppeared = 100
	private var timer = NSTimer()
	private var gameSpeed = 2.0
	private let transitionSpeed = 1.8
	private var mistakeCounter = 0
	private var gameStarted = false
	private var index = 0
	private var testItem = UIImageView(image: UIImage(named: "white_rect"))

    override func viewDidLoad() {
		sessionType = 2
		greeingMessage = "Practice 1. Ready..."
        super.viewDidLoad()
		gameSpeed = model.data.visSustSpeed.doubleValue
		self.testItem.frame = CGRectMake(0, 0, self.testItem.frame.size.width * 2, self.testItem.frame.size.height * 2)
		self.testItem.center = self.view.center;
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
	
	private let practiceSequence: [Picture] = [.Ball, .Bus, .Boot, .Pig, .Sun, .Star, .Leaf, .Key, .Cat, .Bed, .Sock, .Horse, .Cake, .Boat, .Book, .Dog, .Car, .Clock, .Fish, .Train, .Empty];
	private let gameSequence: [Picture] = [.Sun, .Key, .Sock, .Boat, .Boot, .Pig, .Clock, .Car, .Book, .Door, .Cat, .Ball, .Bed, .Bus, .Horse, .Train, .Cake, .Leaf, .Dog, .Star, .Spoon, .Chair, .Bike, .Tree, .Fish, .Door, .Bus, .Ball, .Sun, .Horse, .Spoon, .Bed, .Leaf, .Boot, .Fish, .Star, .Cake, .Tree, .Sock, .Clock, .Book, .Cat, .Key, .Train, .Chair, .Pig,. Boat, .Car, .Bike, .Dog, .Bus, .Bed, .Sun, .Chair, .Dog, .Train, .Ball, .Horse, .Bike, .Leaf, .Sock, .Cake, .Boat, .Cat, .Key, .Door, .Tree, .Pig, .Spoon, .Clock, .Car, .Boot, .Book, .Fish, .Star, .Bike, .Clock, .Car, .Pig, .Boat, .Tree, .Cake, .Sock, .Bus, .Star, .Door, .Horse, .Spoon, .Ball, .Dog, .Boot, .Key, .Leaf, .Train, .Cat, .Chair, .Sun, .Bed, .Fish, .Book, .Cake, .Ball, .Star, .Bus, .Pig, .Train, .Boat, .Sun, .Fish, .Spoon, .Leaf, .Bed, .Dog, .Tree, .Door, .Boot, .Bike, .Cat, .Car, .Sock, .Chair, .Key, .Clock, .Book, .Horse, .Door,.Bike, .Car, .Leaf, .Cake, .Fish, .Bed, .Boot, .Horse, .Bus, .Train, .Sun, .Sock, .Chair, .Dog, .Star, .Ball, .Train, .Pig, .Key, .Clock, .Spoon, .Book, .Cat, .Boat, .Empty]
	
	func updateView(pic: Picture) {
		
		addGestures()
		
		view.addSubview(self.testItem)
		
		// Add Image
		let newImage = UIImage(named: pic.rawValue)
		let middleImage = UIImage(named: Picture.Empty.rawValue)
		
		UIView.transitionWithView(testItem, duration: transitionSpeed/2, options: .TransitionCrossDissolve, animations: {
			
			self.testItem.image = middleImage
			let newFrame = UIImageView(image: newImage)
			
			self.testItem.frame = CGRectMake(0, 0, newFrame.frame.size.width * 2, newFrame.frame.size.height * 2)
			self.testItem.center = self.view.center;
			
			} , completion: {(sucess: Bool) in
				UIView.transitionWithView(self.testItem, duration: self.transitionSpeed/2, options: .TransitionCrossDissolve, animations: {
					self.testItem.image = newImage
				}, completion: nil)
		})
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
		
		view.addSubview(nextButton!)
		view.addSubview(backButton!)
	}
	
	override func tapHandler(sender: UITapGestureRecognizer) {
		
		let screen: CGFloat = CGFloat(index + 1)
		var result = false
		if screenCountSinceAnimalAppeared < 3 {
			mistakeCounter = 0
			result = true
			successSound.play()
			model.addCounterpointingMove(screen, positionY: 0, success: result, interval: screenCountSinceAnimalAppeared, inverted: trainingMode)
			screenCountSinceAnimalAppeared = 100
		} else {
			mistakeCounter += 1
			failureSound.play()
			if mistakeCounter > 4 {
				// -100 is special indicator, player skipped 4 turns, not has to be added to the log, 
				// positionX is reserved for the screen number
				model.addCounterpointingMove(screen, positionY: -100, success: result, interval: 0, inverted: trainingMode)
				mistakeCounter = 0
			} else {
				model.addCounterpointingMove(screen, positionY: 0, success: result, interval: 0, inverted: trainingMode)
			}
		}
		
		// Count scores
		if !trainingMode {
			if result {
				let score = session.score.integerValue
				session.score = NSNumber(integer: (score + 1))
			} else {
				let errors = session.errors.integerValue
				session.errors = NSNumber(integer: (errors + 1))
			}
		}
	}
	
	override func presentPreviousScreen() { // Restarts the practice
		currentScreenShowing = -1
		trainingMode = true
		presentNextScreen()
	}
	
	override func presentNextScreen() {
		currentScreenShowing++
		
		self.cleanView()
		
		self.screenCountSinceAnimalAppeared += 1
		
		switch self.currentScreenShowing {
		case 0:
			// This is needed when practice is restarted.
			self.presentMessage(self.greeingMessage)
		case 1:
			self.showFirstView()
		case 2:
			self.presentMessage("Practice 2. Ready")
			self.view.addSubview(self.backButton!)
		case 3 ... 23:
			if !self.gameStarted {
				self.startTheGame()
				self.gameStarted = true
			}
			self.index = self.currentScreenShowing - 3
						print("practice idnex = \(self.index)")
			self.updateView(self.practiceSequence[self.index])
			if self.isAnimal(self.practiceSequence[self.index]) {
				self.screenCountSinceAnimalAppeared = 0
			}
			
		case 24:
			self.timer.invalidate()
			self.gameStarted = false
			self.presentMessage("Game!")
			self.trainingMode = false
			self.view.addSubview(self.backButton!)
		case 25 ... 175:
		
			if !self.gameStarted {
				self.startTheGame()
				self.gameStarted = true
			}
			
			self.index = self.currentScreenShowing - 25
				print("game idnex = \(self.index)")
			self.updateView(self.gameSequence[self.index])
			if self.isAnimal(self.gameSequence[self.index]) {
				self.screenCountSinceAnimalAppeared = 0
			}
			
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
		super.quit()
		timer.invalidate()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		timer.invalidate()
	}

}
