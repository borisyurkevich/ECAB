//
//  CounterpointingViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/7/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import AVFoundation

class CounterpointingViewController: TestViewController {
	
	var screenPresentedDate = NSDate()
	var lastMistakeDate = NSDate().dateByAddingTimeInterval(0)
	var greeingMessage = "Practice: touch the side with the dog"
	var sessionType = 0
	let pictureHeight: CGFloat = 197
	let pictureWidth: CGFloat = 281
	var gameModeInversed = false
	var touchModeInverserd = false

	
	var leftTarget = false // first screen will be with dog on right
	var session: CounterpointingSession!
	private var totalOne = 0
	private var totalTwo = 0
	
	// MARK: Override
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		model.addCounterpointingSession(model.data.selectedPlayer, type: sessionType)
		session = model.data.counterpointingSessions.lastObject as! CounterpointingSession
		presentMessage(greeingMessage)
		addTouchTargetButtons()
	}
	
	override func skip() {
		// Not sure what screen to show because practice is mixed wit the test
	}
	
	override func presentPreviousScreen() {
		currentScreenShowing = -1
		presentNextScreen()
	}
	
	override func presentNextScreen() {
		currentScreenShowing++
	
		cleanView()
		screenPresentedDate = NSDate()
		
		switch currentScreenShowing {
		case 0:
			// This is needed when practice is restarted.
			presentMessage(greeingMessage)
		case 1:
			presentDogOnRight()
		case 2:
			presentDogOnLeft()
		case 3:
			presentMessage("Touch the side with the dog as quickly as you can!")
			trainingMode = false
		case 4:
			presentDogOnLeft()
		case 5:
			presentDogOnRight()
		case 6:
			presentDogOnLeft()
		case 7:
			presentDogOnLeft()
		case 8:
			presentDogOnRight()
		case 9:
			presentDogOnRight()
		case 10:
			presentDogOnLeft()
		case 11:
			presentDogOnRight()
		case 12:
			presentDogOnLeft()
		case 13:
			presentDogOnLeft()
		case 14:
			presentDogOnLeft()
		case 15:
			presentDogOnRight()
		case 16:
			presentDogOnLeft()
		case 17:
			presentDogOnRight()
		case 18:
			presentDogOnRight()
		case 19:
			presentDogOnRight()
		case 20:
			presentDogOnLeft()
		case 21:
			presentDogOnLeft()
		case 22:
			presentDogOnRight()
		case 23:
			presentDogOnRight()
		case 24:
			presentMessage("...stop")
		case 25:
			presentMessage("Practice: don’t touch the dog, touch the OTHER side of the screen")
			trainingMode = true
			gameModeInversed = true
			touchModeInverserd = true
		case 26:
			presentDogOnRight()
		case 27:
			presentDogOnLeft()
		case 28:
			presentMessage("When the dog comes up, touch the OTHER side of the screen as quickly as you can")
			trainingMode = false
		case 29:
			presentDogOnRight()
		case 30:
			presentDogOnLeft()
		case 31:
			presentDogOnRight()
		case 32:
			presentDogOnLeft()
		case 33:
			presentDogOnRight()
		case 34:
			presentDogOnRight()
		case 35:
			presentDogOnLeft()
		case 36:
			presentDogOnRight()
		case 37:
			presentDogOnRight()
		case 38:
			presentDogOnRight()
		case 39:
			presentDogOnLeft()
		case 40:
			presentDogOnLeft()
		case 41:
			presentDogOnRight()
		case 42:
			presentDogOnRight()
		case 43:
			presentDogOnLeft()
		case 44:
			presentDogOnLeft()
		case 45:
			presentDogOnLeft()
		case 46:
			presentDogOnRight()
		case 47:
			presentDogOnLeft()
		case 48:
			presentDogOnLeft()
		case 49:
			presentMessage("...stop")
		case 50:
			quit()
		default:
			break
		}
	}
	
	// MARK: Other	
	
	func addTouchTargetButtons() {
		
		let screen = UIScreen.mainScreen().bounds
		let screenAreaLeft = CGRectMake(0, menuBarHeight, screen.size.width/2, screen.size.height-menuBarHeight)
		let screenAreaRight = CGRectMake(screen.size.width/2, menuBarHeight, screen.size.width/2, screen.size.height-menuBarHeight)
		let buttonLeft = UIButton(frame: screenAreaLeft)
		let buttonRight = UIButton(frame: screenAreaRight)
		buttonLeft.addTarget(self, action: "handleTouchLeft", forControlEvents: UIControlEvents.TouchDown)
		buttonRight.addTarget(self, action: "handleTouchRight", forControlEvents: UIControlEvents.TouchDown)
		view.addSubview(buttonLeft)
		view.addSubview(buttonRight)
	}
	
	func presentBlueDot() {
		cleanView()
		
		let dot = UIImageView(image: UIImage(named: "Blue Dot"))
		dot.center = view.center
		view.addSubview(dot)
	}
	
	func presentMessage(message: String){
		let label = UILabel(frame: view.frame)
		label.numberOfLines = 3
		label.text = message
		label.textAlignment = NSTextAlignment.Center
		label.font = UIFont.systemFontOfSize(44)
		view.addSubview(label)
	}
	
	func presentDogOnLeft(){
		leftTarget = true;
		
		let imageView = UIImageView(image: UIImage(named: "dog"))
		imageView.frame = CGRectMake(19, 260, pictureWidth, pictureHeight)
		view.addSubview(imageView)
	}
	
	func presentDogOnRight(){
		leftTarget = false;
		
		let imageView = UIImageView(image: UIImage(named: "dog_inverse"))
		imageView.frame = CGRectMake(view.bounds.width-300, 260, pictureWidth, pictureHeight)
		view.addSubview(imageView)
	}
	
	func handleTouchLeft() {
		tapHandler(true)
	}
	func handleTouchRight() {
		tapHandler(false)
	}
	func tapHandler(touchLeft: Bool){
		// Determine Success or failure
		
		var result:Bool
		
		if touchLeft {
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
			
			let interval = currentTime.timeIntervalSinceDate(startPoint) * 1000.0
			let screen: CGFloat = CGFloat(currentScreenShowing)
			
			model.addCounterpointingMove(screen, positionY: 0, success: result, interval: abs(interval), inverted: gameModeInversed, delay:0.0)
			
			if (result) {
				// We don't want to increase time for the total if player made a mistake.
				if (!gameModeInversed) {
					totalOne += Int(interval)
				} else {
					totalTwo += Int(interval)
				}
				session.totalOne = totalOne
				session.totalTwo = totalTwo

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
	
	override func addComment(alert: UIAlertController) {
		let textField = alert.textFields![0] 
		self.session.comment = textField.text!
	}
	
	override  func getComment() -> String {
		return session.comment
	}
}
