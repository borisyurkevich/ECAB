//
//  CounterpointingViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/7/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import AVFoundation

class CounterpointingViewController: GameViewController {
	
	var screenPresentedDate = NSDate()
	var lastMistakeDate = NSDate().dateByAddingTimeInterval(0)
	var greeingMessage = "Practice: touch the side with the dog"
	var sessionType = 0
	let pictureHeight: CGFloat = 197
	let pictureWidth: CGFloat = 281
	var gameModeInversed = false
	var touchModeInverserd = false

	
	var leftTarget = false // first screen will be with dog on right
	private var session: CounterpointingSession!
	private var totalOne = 0
	private var totalTwo = 0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		model.addCounterpointingSession(model.data.selectedPlayer, type: sessionType)
		session = model.data.counterpointingSessions.lastObject as! CounterpointingSession
		presentMessage(greeingMessage)
	}
	
	func presentPreviousScreen() {
		currentScreenShowing -= 4
		trainingMode = true
		presentNextScreen()
	}
	
	func presentNextScreen() {
		currentScreenShowing++
	
		cleanView()
		screenPresentedDate = NSDate()
		
		switch currentScreenShowing {
		case 0:
			presentMessage(greeingMessage)
			break
		case 1:
			presentDogOnRight()
			break
		case 2:
			presentDogOnLeft()
			break
		case 3:
			presentMessage("Touch the side with the dog as quickly as you can!")
			trainingMode = false
			view.addSubview(backButton!)
			break
		case 4:
			presentDogOnLeft()
			break
		case 5:
			presentDogOnRight()
			break
		case 6:
			presentDogOnLeft()
			break
		case 7:
			presentDogOnLeft()
			break
		case 8:
			presentDogOnRight()
			break
		case 9:
			presentDogOnRight()
			break
		case 10:
			presentDogOnLeft()
			break
		case 11:
			presentDogOnRight()
			break
		case 12:
			presentDogOnLeft()
			break
		case 13:
			presentDogOnLeft()
			break
		case 14:
			presentDogOnLeft()
			break
		case 15:
			presentDogOnRight()
			break
		case 16:
			presentDogOnLeft()
			break
		case 17:
			presentDogOnRight()
			break
		case 18:
			presentDogOnRight()
			break
		case 19:
			presentDogOnRight()
			break
		case 20:
			presentDogOnLeft()
			break
		case 21:
			presentDogOnLeft()
			break
		case 22:
			presentDogOnRight()
			break
		case 23:
			presentDogOnRight()
			break
		case 24:
			presentMessage("...stop")
			break
		case 25:
			presentMessage("Practice: don’t touch the dog, touch the OTHER side of the screen")
			trainingMode = true
			gameModeInversed = true
			touchModeInverserd = true
			break
		case 26:
			presentDogOnRight()
			break
		case 27:
			presentDogOnLeft()
			break
		case 28:
			presentMessage("When the dog comes up, touch the OTHER side of the screen as quickly as you can")
			trainingMode = false
			view.addSubview(backButton!)
			break
		case 29:
			presentDogOnRight()
			break
		case 30:
			presentDogOnLeft()
			break
		case 31:
			presentDogOnRight()
			break
		case 32:
			presentDogOnLeft()
			break
		case 33:
			presentDogOnRight()
			break
		case 34:
			presentDogOnRight()
			break
		case 35:
			presentDogOnLeft()
			break
		case 36:
			presentDogOnRight()
			break
		case 37:
			presentDogOnRight()
			break
		case 38:
			presentDogOnRight()
			break
		case 39:
			presentDogOnLeft()
			break
		case 40:
			presentDogOnLeft()
			break
		case 41:
			presentDogOnRight()
			break
		case 42:
			presentDogOnRight()
			break
		case 43:
			presentDogOnLeft()
			break
		case 44:
			presentDogOnLeft()
			break
		case 45:
			presentDogOnLeft()
			break
		case 46:
			presentDogOnRight()
			break
		case 47:
			presentDogOnLeft()
			break
		case 48:
			presentDogOnLeft()
			break
		case 49:
			presentMessage("...stop")
			break
		case 50:
			quit()
			break
		default:
			break
		}
	}
	
	func presentBlueDot() {
		cleanView()
		
		let dot = UIImageView(image: UIImage(named: "Blue Dot"))
		dot.center = view.center
		view.addSubview(dot)
	
		addNextButton()
	}
	
	func addNextButton() {
		let labelText: String = "Next"
		let size: CGSize = labelText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(28.0)])
		nextButton = UIButton.buttonWithType(UIButtonType.System) as? UIButton
		nextButton!.setTitle("Next", forState: UIControlState.Normal)
		nextButton!.frame = CGRectMake(160, 16, size.width + 2, size.height)
		nextButton!.addTarget(self, action: "presentNextScreen", forControlEvents: UIControlEvents.TouchUpInside)
		nextButton!.tintColor = UIColor.grayColor()
		addButtonBorder(nextButton!)
		view.addSubview(nextButton!)
	}

	
	func presentMessage(message: String){
		let label = UILabel(frame: view.frame)
		label.numberOfLines = 3
		label.text = message
		label.textAlignment = NSTextAlignment.Center
		label.font = UIFont.systemFontOfSize(44)
		view.addSubview(label)
		
		addNextButton()
	}
	
	func presentDogOnLeft(){
		leftTarget = true;
		
		let imageView = UIImageView(image: UIImage(named: "dog"))
		imageView.frame = CGRectMake(19, 260, pictureWidth, pictureHeight)
		
		view.addSubview(imageView)
		
		let gesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
		view.addGestureRecognizer(gesture)
	}
	
	func presentDogOnRight(){
		leftTarget = false;
		
		let imageView = UIImageView(image: UIImage(named: "dog_inverse"))
		imageView.frame = CGRectMake(view.bounds.width-300, 260, pictureWidth, pictureHeight)
		
		view.addSubview(imageView)
		
		let gesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
		view.addGestureRecognizer(gesture)
	}
	
	func tapHandler(sender: UITapGestureRecognizer){
		// Determine Success or failure
		let location = sender.locationInView(view)
		let screenWidth = UIScreen.mainScreen().bounds.width
		let middlePoint = screenWidth / 2
		
		var result:Bool
		
		if location.x < middlePoint {
			if !touchModeInverserd {
				// tap on the left side of the screen
				if leftTarget {
					successSound.play()
					result = true
				} else {
					failureSound.play()
					result = false
				}
			} else {
				// tap on the left side of the screen
				if leftTarget {
					failureSound.play()
					result = false
				} else {
					successSound.play()
					result = true
				}
			}
		} else {
			// Tap on right
			if !touchModeInverserd {
				if leftTarget {
					failureSound.play()
					result = false
				} else {
					successSound.play()
					result = true
				}
			} else {
				if leftTarget {
					successSound.play()
					result = true
				} else {
					failureSound.play()
					result = false
				}
			}
		}
		
		if !trainingMode {
		
			let currentTime = NSDate()
			var startPoint = screenPresentedDate
			if !result {
				startPoint = screenPresentedDate.laterDate(lastMistakeDate)
				lastMistakeDate = currentTime
			}
			
			var interval = currentTime.timeIntervalSinceDate(startPoint) * 1000.0
			
			model.addCounterpointingMove(location.x, positionY: location.y, success: result, interval: abs(Int(interval)), inverted: gameModeInversed)
			if (!gameModeInversed) {
				totalOne += Int(interval)
			} else {
				totalTwo += Int(interval)
			}
			session.totalOne = totalOne
			session.totalTwo = totalTwo
			
			if result {
				let score = session.score.integerValue
				session.score = NSNumber(integer: (score + 1))
			} else {
				let errors = session.errors.integerValue
				session.errors = NSNumber(integer: (errors + 1))
			}
		}
		
		if result {
			if !trainingMode {
				presentBlueDot()
			} else {
				presentNextScreen()
			}
		}
	}
}
