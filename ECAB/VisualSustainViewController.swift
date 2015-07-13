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

    override func viewDidLoad() {
		sessionType = 2
		greeingMessage = "Practice 1. Ready..."
        super.viewDidLoad()
		gameSpeed = model.data.visSustSpeed.doubleValue
    }
	
	enum Picture: String {
		case Empty = ""
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
		
		addNextButton()
		view.addSubview(backButton!)
	}
	
	override func tapHandler(sender: UITapGestureRecognizer) {
		
		let screen: CGFloat = CGFloat(currentScreenShowing)
		var result = false
		if screenCountSinceAnimalAppeared < 3 {
			result = true
			successSound.play()
			model.addCounterpointingMove(screen, positionY: 0, success: result, interval: screenCountSinceAnimalAppeared, inverted: trainingMode)
			screenCountSinceAnimalAppeared = 100
		} else {
			failureSound.play()
			model.addCounterpointingMove(screen, positionY: 0, success: result, interval: 0, inverted: trainingMode)
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
		currentScreenShowing = 0
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
			screenCountSinceAnimalAppeared = 0
		case 7:
			updateView(.Sun)
		case 8:
			updateView(.Star)
		case 9:
			updateView(.Leaf)
		case 10:
			updateView(.Key)
		case 11:
			updateView(.Cat)
			screenCountSinceAnimalAppeared = 0
		case 12:
			updateView(.Bed)
		case 13:
			updateView(.Sock)
		case 14:
			updateView(.Horse)
			screenCountSinceAnimalAppeared = 0
		case 15:
			updateView(.Cake)
		case 16:
			updateView(.Boat)
		case 17:
			updateView(.Book)
		case 18:
			updateView(.Dog)
			screenCountSinceAnimalAppeared = 0
		case 19:
			updateView(.Car)
			screenCountSinceAnimalAppeared = 0
		case 20:
			updateView(.Clock)
		case 21:
			updateView(.Fish)
			screenCountSinceAnimalAppeared = 0
		case 22:
			updateView(.Train)
		case 23:
			timer.invalidate()
			presentMessage("Game!")
			trainingMode = false
			view.addSubview(backButton!)
		case 24:
			updateView(.Sun)
			startTheGame()
		case 25:
			updateView(.Key)
		case 26:
			updateView(.Sock)
		case 27:
			updateView(.Boat)
		case 28:
			updateView(.Boot)
		case 29:
			updateView(.Pig)
			screenCountSinceAnimalAppeared = 0
		case 30:
			updateView(.Clock)
		case 31:
			updateView(.Car)
		case 32:
			updateView(.Book)
		case 33:
			updateView(.Door)
		case 34:
			updateView(.Cat)
			screenCountSinceAnimalAppeared = 0
		case 35:
			updateView(.Ball)
		case 36:
			updateView(.Bed)
		case 37:
			updateView(.Bus)
		case 38:
			updateView(.Horse)
			screenCountSinceAnimalAppeared = 0
		case 39:
			updateView(.Train)
		case 40:
			updateView(.Cake)
		case 41:
			updateView(.Leaf)
		case 42:
			updateView(.Dog)
			screenCountSinceAnimalAppeared = 0
		case 43:
			updateView(.Star)
		case 44:
			updateView(.Spoon)
		case 45:
			updateView(.Chair)
		case 46:
			updateView(.Bike)
		case 47:
			updateView(.Tree)
		case 48:
			updateView(.Fish)
			screenCountSinceAnimalAppeared = 0
		case 49:
			updateView(.Door)
		case 50:
			updateView(.Bus)
		case 51:
			updateView(.Ball)
		case 52:
			updateView(.Sun)
		case 53:
			updateView(.Horse)
			screenCountSinceAnimalAppeared = 0
		case 54:
			updateView(.Spoon)
		case 55:
			updateView(.Bed)
		case 56:
			updateView(.Boot)
		case 57:
			updateView(.Fish)
			screenCountSinceAnimalAppeared = 0
		case 58:
			updateView(.Star)
		case 59:
			updateView(.Cake)
		case 60:
			updateView(.Tree)
		case 61:
			updateView(.Sock)
		case 62:
			updateView(.Sock)
		case 63:
			updateView(.Book)
		case 64:
			updateView(.Cat)
			screenCountSinceAnimalAppeared = 0
		case 65:
			updateView(.Key)
		case 66:
			updateView(.Train)
		case 67:
			updateView(.Chair)
		case 68:
			updateView(.Pig)
			screenCountSinceAnimalAppeared = 0
		case 69:
			updateView(.Boat)
		case 70:
			updateView(.Bike)
		case 71:
			updateView(.Dog)
			screenCountSinceAnimalAppeared = 0
		case 72:
			updateView(.Bus)
		case 73:
			updateView(.Bed)
		case 74:
			updateView(.Sun)
		case 75:
			updateView(.Chair)
		case 76:
			updateView(.Dog)
		case 77:
			updateView(.Train)
		case 78:
			updateView(.Ball)
		case 79:
			updateView(.Horse)
			screenCountSinceAnimalAppeared = 0
		case 80:
			updateView(.Bike)
		case 81:
			updateView(.Sock)
		case 82:
			updateView(.Cake)
		case 83:
			updateView(.Boat)
		case 84:
			updateView(.Cat)
			screenCountSinceAnimalAppeared = 0
		case 85:
			updateView(.Key)
		case 86:
			updateView(.Door)
		case 87:
			updateView(.Tree)
		case 88:
			updateView(.Pig)
			screenCountSinceAnimalAppeared = 0
		case 89:
			updateView(.Spoon)
		case 90:
			updateView(.Clock)
		case 91:
			updateView(.Boot)
		case 92:
			updateView(.Book)
		case 93:
			updateView(.Fish)
			screenCountSinceAnimalAppeared = 0
		case 94:
			updateView(.Star)
		case 95:
			updateView(.Bike)
		case 96:
			updateView(.Clock)
		case 97:
			updateView(.Car)
		case 98:
			updateView(.Pig)
			screenCountSinceAnimalAppeared = 0
		case 99:
			updateView(.Boat)
		case 100:
			updateView(.Cake)
		case 101:
			updateView(.Sock)
		case 102:
			updateView(.Bus)
		case 103:
			updateView(.Star)
		case 104:
			updateView(.Door)
		case 105:
			updateView(.Horse)
			screenCountSinceAnimalAppeared = 0
		case 106:
			updateView(.Spoon)
		case 107:
			updateView(.Ball)
		case 108:
			updateView(.Dog)
			screenCountSinceAnimalAppeared = 0
		case 109:
			updateView(.Boot)
		case 110:
			updateView(.Key)
		case 111:
			updateView(.Leaf)
		case 112:
			updateView(.Train)
		case 113:
			updateView(.Cat)
			screenCountSinceAnimalAppeared = 0
		case 114:
			updateView(.Chair)
		case 115:
			updateView(.Sun)
		case 116:
			updateView(.Bed)
		case 117:
			updateView(.Fish)
			screenCountSinceAnimalAppeared = 0
		case 118:
			updateView(.Book)
		case 119:
			updateView(.Cake)
		case 120:
			updateView(.Ball)
		case 121:
			updateView(.Star)
		case 122:
			updateView(.Bus)
		case 123:
			updateView(.Pig)
			screenCountSinceAnimalAppeared = 0
		case 124:
			updateView(.Train)
		case 125:
			updateView(.Boat)
		case 126:
			updateView(.Sun)
		case 127:
			updateView(.Fish)
			screenCountSinceAnimalAppeared = 0
		case 128:
			updateView(.Spoon)
		case 129:
			updateView(.Leaf)
		case 130:
			updateView(.Bed)
		case 131:
			updateView(.Dog)
			screenCountSinceAnimalAppeared = 0
		case 132:
			updateView(.Tree)
		case 133:
			updateView(.Door)
		case 134:
			updateView(.Boot)
		case 135:
			updateView(.Bike)
		case 136:
			updateView(.Cat)
			screenCountSinceAnimalAppeared = 0
		case 137:
			updateView(.Car)
		case 138:
			updateView(.Sock)
		case 139:
			updateView(.Chair)
		case 140:
			updateView(.Key)
		case 141:
			updateView(.Clock)
		case 142:
			updateView(.Book)
		case 143:
			updateView(.Horse)
			screenCountSinceAnimalAppeared = 0
		case 144:
			updateView(.Door)
		case 145:
			updateView(.Bike)
		case 146:
			updateView(.Car)
		case 147:
			updateView(.Leaf)
		case 148:
			updateView(.Cake)
		case 149:
			updateView(.Fish)
			screenCountSinceAnimalAppeared = 0
		case 150:
			updateView(.Bed)
		case 151:
			updateView(.Boot)
		case 152:
			updateView(.Horse)
			screenCountSinceAnimalAppeared = 0
		case 153:
			updateView(.Bus)
		case 154:
			updateView(.Sun)
		case 155:
			updateView(.Sock)
		case 156:
			updateView(.Sock)
		case 157:
			updateView(.Dog)
			screenCountSinceAnimalAppeared = 0
		case 158:
			updateView(.Star)
		case 159:
			updateView(.Ball)
		case 160:
			updateView(.Tree)
		case 161:
			updateView(.Pig)
			screenCountSinceAnimalAppeared = 0
		case 162:
			updateView(.Key)
		case 163:
			updateView(.Clock)
		case 164:
			updateView(.Spoon)
		case 165:
			updateView(.Book)
		case 166:
			updateView(.Cat)
			screenCountSinceAnimalAppeared = 0
		case 167:
			updateView(.Boat)
		case 168:
			presentMessage("...stop")
		case 169:
			quit()
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
