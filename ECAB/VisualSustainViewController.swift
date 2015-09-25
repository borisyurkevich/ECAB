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
	private let transitionSpeed = 0.9

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
		
		view.addSubview(nextButton!)
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
		let coverView = UIView()
		coverView.frame = view.frame
		coverView.backgroundColor = UIColor.clearColor()
		view.addSubview(coverView)
		
		UIView.transitionWithView(view, duration: transitionSpeed, options: .AllowUserInteraction, animations: {
			
			coverView.backgroundColor = UIColor.whiteColor()
			
		}, completion: { (fininshed: Bool) -> () in
			
			self.cleanView()
			
			self.screenCountSinceAnimalAppeared += 1
			
			switch self.currentScreenShowing {
			case 0:
				self.presentMessage(self.greeingMessage)
			case 1:
				self.showFirstView()
			case 2:
				self.presentMessage("Practice 2. Ready")
				self.view.addSubview(self.backButton!)
			case 3:
				self.updateView(.Ball)
				self.startTheGame()
			case 4:
				self.updateView(.Bus)
			case 5:
				self.updateView(.Boot)
			case 6:
				self.updateView(.Pig)
				self.screenCountSinceAnimalAppeared = 0
			case 7:
				self.updateView(.Sun)
			case 8:
				self.updateView(.Star)
			case 9:
				self.updateView(.Leaf)
			case 10:
				self.updateView(.Key)
			case 11:
				self.updateView(.Cat)
				self.screenCountSinceAnimalAppeared = 0
			case 12:
				self.updateView(.Bed)
			case 13:
				self.updateView(.Sock)
			case 14:
				self.updateView(.Horse)
				self.screenCountSinceAnimalAppeared = 0
			case 15:
				self.updateView(.Cake)
			case 16:
				self.updateView(.Boat)
			case 17:
				self.updateView(.Book)
			case 18:
				self.updateView(.Dog)
				self.screenCountSinceAnimalAppeared = 0
			case 19:
				self.updateView(.Car)
				self.screenCountSinceAnimalAppeared = 0
			case 20:
				self.updateView(.Clock)
			case 21:
				self.updateView(.Fish)
				self.screenCountSinceAnimalAppeared = 0
			case 22:
				self.updateView(.Train)
			case 23:
				self.timer.invalidate()
				self.presentMessage("Game!")
				self.trainingMode = false
				self.view.addSubview(self.backButton!)
			case 24:
				self.updateView(.Sun)
				self.startTheGame()
			case 25:
				self.updateView(.Key)
			case 26:
				self.updateView(.Sock)
			case 27:
				self.updateView(.Boat)
			case 28:
				self.updateView(.Boot)
			case 29:
				self.updateView(.Pig)
				self.screenCountSinceAnimalAppeared = 0
			case 30:
				self.updateView(.Clock)
			case 31:
				self.updateView(.Car)
			case 32:
				self.updateView(.Book)
			case 33:
				self.updateView(.Door)
			case 34:
				self.updateView(.Cat)
				self.screenCountSinceAnimalAppeared = 0
			case 35:
				self.updateView(.Ball)
			case 36:
				self.updateView(.Bed)
			case 37:
				self.updateView(.Bus)
			case 38:
				self.updateView(.Horse)
				self.screenCountSinceAnimalAppeared = 0
			case 39:
				self.updateView(.Train)
			case 40:
				self.updateView(.Cake)
			case 41:
				self.updateView(.Leaf)
			case 42:
				self.updateView(.Dog)
				self.screenCountSinceAnimalAppeared = 0
			case 43:
				self.updateView(.Star)
			case 44:
				self.updateView(.Spoon)
			case 45:
				self.updateView(.Chair)
			case 46:
				self.updateView(.Bike)
			case 47:
				self.updateView(.Tree)
			case 48:
				self.updateView(.Fish)
				self.screenCountSinceAnimalAppeared = 0
			case 49:
				self.updateView(.Door)
			case 50:
				self.updateView(.Bus)
			case 51:
				self.updateView(.Ball)
			case 52:
				self.updateView(.Sun)
			case 53:
				self.updateView(.Horse)
				self.screenCountSinceAnimalAppeared = 0
			case 54:
				self.updateView(.Spoon)
			case 55:
				self.updateView(.Bed)
			case 56:
				self.updateView(.Boot)
			case 57:
				self.updateView(.Fish)
				self.screenCountSinceAnimalAppeared = 0
			case 58:
				self.updateView(.Star)
			case 59:
				self.updateView(.Cake)
			case 60:
				self.updateView(.Tree)
			case 61:
				self.updateView(.Sock)
			case 62:
				self.updateView(.Sock)
			case 63:
				self.updateView(.Book)
			case 64:
				self.updateView(.Cat)
				self.screenCountSinceAnimalAppeared = 0
			case 65:
				self.updateView(.Key)
			case 66:
				self.updateView(.Train)
			case 67:
				self.updateView(.Chair)
			case 68:
				self.updateView(.Pig)
				self.screenCountSinceAnimalAppeared = 0
			case 69:
				self.updateView(.Boat)
			case 70:
				self.updateView(.Bike)
			case 71:
				self.updateView(.Dog)
				self.screenCountSinceAnimalAppeared = 0
			case 72:
				self.updateView(.Bus)
			case 73:
				self.updateView(.Bed)
			case 74:
				self.updateView(.Sun)
			case 75:
				self.updateView(.Chair)
			case 76:
				self.updateView(.Dog)
			case 77:
				self.updateView(.Train)
			case 78:
				self.updateView(.Ball)
			case 79:
				self.updateView(.Horse)
				self.screenCountSinceAnimalAppeared = 0
			case 80:
				self.updateView(.Bike)
			case 81:
				self.updateView(.Sock)
			case 82:
				self.updateView(.Cake)
			case 83:
				self.updateView(.Boat)
			case 84:
				self.updateView(.Cat)
				self.screenCountSinceAnimalAppeared = 0
			case 85:
				self.updateView(.Key)
			case 86:
				self.updateView(.Door)
			case 87:
				self.updateView(.Tree)
			case 88:
				self.updateView(.Pig)
				self.screenCountSinceAnimalAppeared = 0
			case 89:
				self.updateView(.Spoon)
			case 90:
				self.updateView(.Clock)
			case 91:
				self.updateView(.Boot)
			case 92:
				self.updateView(.Book)
			case 93:
				self.updateView(.Fish)
				self.screenCountSinceAnimalAppeared = 0
			case 94:
				self.updateView(.Star)
			case 95:
				self.updateView(.Bike)
			case 96:
				self.updateView(.Clock)
			case 97:
				self.updateView(.Car)
			case 98:
				self.updateView(.Pig)
				self.screenCountSinceAnimalAppeared = 0
			case 99:
				self.updateView(.Boat)
			case 100:
				self.updateView(.Cake)
			case 101:
				self.updateView(.Sock)
			case 102:
				self.updateView(.Bus)
			case 103:
				self.updateView(.Star)
			case 104:
				self.updateView(.Door)
			case 105:
				self.updateView(.Horse)
				self.screenCountSinceAnimalAppeared = 0
			case 106:
				self.updateView(.Spoon)
			case 107:
				self.updateView(.Ball)
			case 108:
				self.updateView(.Dog)
				self.screenCountSinceAnimalAppeared = 0
			case 109:
				self.updateView(.Boot)
			case 110:
				self.updateView(.Key)
			case 111:
				self.updateView(.Leaf)
			case 112:
				self.updateView(.Train)
			case 113:
				self.updateView(.Cat)
				self.screenCountSinceAnimalAppeared = 0
			case 114:
				self.updateView(.Chair)
			case 115:
				self.updateView(.Sun)
			case 116:
				self.updateView(.Bed)
			case 117:
				self.updateView(.Fish)
				self.screenCountSinceAnimalAppeared = 0
			case 118:
				self.updateView(.Book)
			case 119:
				self.updateView(.Cake)
			case 120:
				self.updateView(.Ball)
			case 121:
				self.updateView(.Star)
			case 122:
				self.updateView(.Bus)
			case 123:
				self.updateView(.Pig)
				self.screenCountSinceAnimalAppeared = 0
			case 124:
				self.updateView(.Train)
			case 125:
				self.updateView(.Boat)
			case 126:
				self.updateView(.Sun)
			case 127:
				self.updateView(.Fish)
				self.screenCountSinceAnimalAppeared = 0
			case 128:
				self.updateView(.Spoon)
			case 129:
				self.updateView(.Leaf)
			case 130:
				self.updateView(.Bed)
			case 131:
				self.updateView(.Dog)
				self.screenCountSinceAnimalAppeared = 0
			case 132:
				self.updateView(.Tree)
			case 133:
				self.updateView(.Door)
			case 134:
				self.updateView(.Boot)
			case 135:
				self.updateView(.Bike)
			case 136:
				self.updateView(.Cat)
				self.screenCountSinceAnimalAppeared = 0
			case 137:
				self.updateView(.Car)
			case 138:
				self.updateView(.Sock)
			case 139:
				self.updateView(.Chair)
			case 140:
				self.updateView(.Key)
			case 141:
				self.updateView(.Clock)
			case 142:
				self.updateView(.Book)
			case 143:
				self.updateView(.Horse)
				self.screenCountSinceAnimalAppeared = 0
			case 144:
				self.updateView(.Door)
			case 145:
				self.updateView(.Bike)
			case 146:
				self.updateView(.Car)
			case 147:
				self.updateView(.Leaf)
			case 148:
				self.updateView(.Cake)
			case 149:
				self.updateView(.Fish)
				self.screenCountSinceAnimalAppeared = 0
			case 150:
				self.updateView(.Bed)
			case 151:
				self.updateView(.Boot)
			case 152:
				self.updateView(.Horse)
				self.screenCountSinceAnimalAppeared = 0
			case 153:
				self.updateView(.Bus)
			case 154:
				self.updateView(.Sun)
			case 155:
				self.updateView(.Sock)
			case 156:
				self.updateView(.Sock)
			case 157:
				self.updateView(.Dog)
				self.screenCountSinceAnimalAppeared = 0
			case 158:
				self.updateView(.Star)
			case 159:
				self.updateView(.Ball)
			case 160:
				self.updateView(.Tree)
			case 161:
				self.updateView(.Pig)
				self.screenCountSinceAnimalAppeared = 0
			case 162:
				self.updateView(.Key)
			case 163:
				self.updateView(.Clock)
			case 164:
				self.updateView(.Spoon)
			case 165:
				self.updateView(.Book)
			case 166:
				self.updateView(.Cat)
				self.screenCountSinceAnimalAppeared = 0
			case 167:
				self.updateView(.Boat)
			case 168:
				self.presentMessage("...stop")
			case 169:
				self.quit()
			default:
				break
			}
			
			self.view.addSubview(coverView)
			
			UIView.transitionWithView(self.view, duration: self.transitionSpeed, options: .AllowUserInteraction, animations: {
				
				coverView.backgroundColor = UIColor.clearColor()
			
			}, completion: { (fininshed: Bool) -> () in
				coverView.removeFromSuperview()
			})
		})
	}
	
	func startTheGame() {
		timer = NSTimer(timeInterval: gameSpeed + 1.8, target: self, selector: "presentNextScreen", userInfo: nil, repeats: true)
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
