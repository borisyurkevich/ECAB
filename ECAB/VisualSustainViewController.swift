//
//  VisualSustainViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 02/07/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class VisualSustainViewController: CounterpointingViewController {
	
	private var screenCountSinceAnimalAppeared = -1
	private var timer = NSTimer()
	private var gameSpeed = 2.0

    override func viewDidLoad() {
		sessionType = 2
		greeingMessage = "Practice 1. Ready..."
        super.viewDidLoad()
    }
	
	enum Picture: String {
		case Empty = ""
		case BadInverse = "bad_inverse"
		case Ball = "ball"
		case Bike = "bike"
		case BoatInverse = "boat_inverse"
		case Book = "book"
		case Boot = "boot"
		case Bus = "bus"
		case Cake = "cake"
		case CarInv = "car_inverse"
		case CatInverse = "cat_inverse"
		case Chair = "chair"
		case Clock = "clock"
		case Dog = "dog"
		case Door = "door"
		case FishInverse = "fish_iverse"
		case HorseInverse = "horse_inverse"
		case Key = "key"
		case Leaf = "leaf"
		case Mouse = "mouse"
		case Pig = "pig"
		case Sock = "sock"
		case Spoon = "spoon"
		case Star = "star_yellow"
		case TrainInverse = "train_inverse"
		case Tree = "tree"
	}
	
	func updateView(pic: Picture) {
		
		// Add Image
		let image = UIImage(named: pic.rawValue)
		let imageView = UIImageView(image: image)
		imageView.frame = CGRectMake(0, 0, imageView.frame.size.width * 2, imageView.frame.size.height * 2)
		imageView.center = view.center
		view.addSubview(imageView)
		
		// Gesture
		let gesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
		view.addGestureRecognizer(gesture)
	}
	
	func showFirstView() {
		
		let pig = UIImage(named: Picture.Pig.rawValue)
		let dog = UIImage(named: Picture.Dog.rawValue)
		let fish = UIImage(named: Picture.FishInverse.rawValue)
		let horse = UIImage(named: Picture.HorseInverse.rawValue)
		let cat = UIImage(named: Picture.CatInverse.rawValue)
		
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
		
		addNextButton()
		view.addSubview(backButton!)
	}
	
	override func tapHandler(sender: UITapGestureRecognizer) {
		
		var result = false
		if screenCountSinceAnimalAppeared < 3 {
			result = true
			successSound.play()
		} else {
			failureSound.play()
		}
		
		if !trainingMode {
			model.addCounterpointingMove(0, positionY: 0, success: result, interval: screenCountSinceAnimalAppeared, inverted: false)
		}
	}
	
	override func presentPreviousScreen() { // Restarts the practice
		
		switch currentScreenShowing {
		case 2:
			currentScreenShowing -= 1
		case 15:
			currentScreenShowing -= 16
		default:
			break
		}
		
		trainingMode = true
		presentNextScreen()
	}
	
	override func presentNextScreen() {
		currentScreenShowing++
		cleanView()
		screenCountSinceAnimalAppeared += 1
		
		switch currentScreenShowing {
		case 0:
			presentMessage(greeingMessage)
		case 1:
			showFirstView()
			screenCountSinceAnimalAppeared = 0
		case 2:
			presentMessage("Practice 2. Ready")
			view.addSubview(backButton!)
		case 3:
			updateView(.Ball)
			startTheGame()
		case 4:
			updateView(.Bus)
		case 5:
			updateView(.Boot)
		case 6:
			updateView(.Pig)
		default:
			break
		}
	}
	
	func startTheGame() {
		timer = NSTimer(timeInterval: gameSpeed, target: self, selector: "presentNextScreen", userInfo: nil, repeats: true)
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
