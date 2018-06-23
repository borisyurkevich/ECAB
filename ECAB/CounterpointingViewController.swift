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
	
	var screenPresentedDate = Date()
	var lastMistakeDate = Date().addingTimeInterval(0)
	var greeingMessage = "Practice: touch the side with the dog"
	var sessionType = SessionType.counterpointing.rawValue
	fileprivate let pictureHeight: CGFloat = 197
	fileprivate let pictureWidth: CGFloat = 281
	
    // For the log only. This inicates that's test enviroment build in a way to 
    // confuse subject. Also used in Flanker.
    var gameModeInversed = false
    
    // Responcible for success or false positive. When not inversed dog pointing 
    // to the same place subject suppost to tap.
    fileprivate var touchModeInverserd = false

	var leftTarget = false // first screen will be with dog on right
	var session: CounterpointingSession!
	fileprivate var totalOne = 0.0
	fileprivate var totalTwo = 0.0
	
	// MARK: Override
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		model.addCounterpointingSession(model.data.selectedPlayer, type: sessionType)
		session = model.data.counterpointingSessions.lastObject as! CounterpointingSession
		presentMessage(greeingMessage)
		addTouchTargetButtons()
	}
    
    override func resumeTest() {
        screenPresentedDate = Date()
    }
	
	override func skip() {
		// Skips current interval: eather practice or test
		// This constans represent the screen which appeares before
		// practice or test session
		//
		// Inverse test is the test in which player need to test the other side
		// of the screen
		let test = 2
		let practiceInverse = 24
		let testInverse = 27
		
		switch currentScreenShowing {
		case -1 ... 2:
			currentScreenShowing = test
		case 3 ... 24:
			currentScreenShowing = practiceInverse
		case 25 ... 27:
			currentScreenShowing = testInverse
		case 28 ... 49:
			return
		default:
			return
		}
		presentNextScreen()
	}
	
	override func presentPreviousScreen() {
		currentScreenShowing = -1
		presentNextScreen()
	}
	
	func presentDogOnSide(_ screenSide: Side) {
		if screenSide == .left {
			presentDogOnLeft()
		} else if screenSide == .right {
			presentDogOnRight()
		}
	}
	func presentDogOnLeft(){
		leftTarget = true;
		
		let imageView = UIImageView(image: UIImage(named: "dog"))
		imageView.frame = CGRect(x: 19, y: 260, width: pictureWidth, height: pictureHeight)
		view.addSubview(imageView)
	}
	
	func presentDogOnRight(){
		leftTarget = false;
		
		let imageView = UIImageView(image: UIImage(named: "dog_inverse"))
		imageView.frame = CGRect(x: view.bounds.width-300, y: 260, width: pictureWidth, height: pictureHeight)
		view.addSubview(imageView)
	}
	
	override func presentNextScreen() {
        toggleNavigationButtons(isEnabled: false)
        
		currentScreenShowing += 1
	
		cleanView()
		screenPresentedDate = Date()
		
		switch currentScreenShowing {
		case 0:
			// This is needed when practice is restarted.
			presentMessage(greeingMessage)
		case 1 ... 2:
			presentDogOnSide(dogSequence[currentScreenShowing]!)
		case 3:
			trainingMode = false
			presentMessage("Touch the side with the dog as quickly as you can!")
            model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
		case 4 ... 23:
			presentDogOnSide(dogSequence[currentScreenShowing]!)
		case 24:
			presentMessage("...stop")
		case 25:
			trainingMode = true
			gameModeInversed = true
			touchModeInverserd = true
			presentMessage("Practice: don’t touch the dog, touch the OTHER side of the screen")
            model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
		case 26 ... 27:
			presentDogOnSide(dogSequence[currentScreenShowing]!)
		case 28:
			trainingMode = false
			presentMessage("When the dog comes up, touch the OTHER side of the screen as quickly as you can")
            model.addCounterpointingMove(blankSpaceTag, positionY: 0, success: false, interval: 0.0, inverted: false, delay:0.0)
		case 29 ... 48:
			presentDogOnSide(dogSequence[currentScreenShowing]!)
		case 49:
			presentMessage("...stop")
		case 50:
			presentPause()
		default:
			break
		}
	}
	
	// MARK: Other	
	
	func addTouchTargetButtons() {
		
		let screen = UIScreen.main.bounds
		let screenAreaLeft = CGRect(x: 0, y: menuBarHeight, width: screen.size.width/2, height: screen.size.height-menuBarHeight)
		let screenAreaRight = CGRect(x: screen.size.width/2, y: menuBarHeight, width: screen.size.width/2, height: screen.size.height-menuBarHeight)
		let buttonLeft = UIButton(frame: screenAreaLeft)
		let buttonRight = UIButton(frame: screenAreaRight)
		buttonLeft.addTarget(self, action: #selector(CounterpointingViewController.handleTouchLeft), for: UIControlEvents.touchDown)
		buttonRight.addTarget(self, action: #selector(CounterpointingViewController.handleTouchRight), for: UIControlEvents.touchDown)
		view.addSubview(buttonLeft)
		view.addSubview(buttonRight)
	}
    
    func toggleNavigationButtons(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        backButton.isEnabled = isEnabled
        skipTrainingButton.isEnabled = isEnabled
    }
	
	func presentBlueDot() {
		cleanView()
				
		let dot = UIImageView(image: UIImage(named: "Blue Dot"))
		dot.center = view.center
		view.addSubview(dot)
        
        self.playerInteractionsDisabled = true
        toggleNavigationButtons(isEnabled: true)
	}
	
	func presentMessage(_ message: String){
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 450, height: 0))
        
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.systemFont(ofSize: 44)
        label.text = message
        label.sizeToFit()
        label.center = view.center

        view.addSubview(label)
        
        self.playerInteractionsDisabled = true
        toggleNavigationButtons(isEnabled: true)
	}
	
	@objc func handleTouchLeft() {
		tapHandler(true)
	}
	@objc func handleTouchRight() {
		tapHandler(false)
	}
	func tapHandler(_ touchLeft: Bool){
		// Determine Success or failure
		
        if playerInteractionsDisabled {
            return
        }
		
		var result:Bool
		
		if touchLeft {
			if !touchModeInverserd {
				// tap on the left side of the screen
				if leftTarget {
					playSound(.positive)
					result = true
				} else {
					playSound(.negative)
					result = false
				}
			} else {
				// tap on the left side of the screen
				if leftTarget {
					playSound(.negative)
					result = false
				} else {
					playSound(.positive)
					result = true
				}
			}
		} else {
			// Tap on right
			if !touchModeInverserd {
				if leftTarget {
					playSound(.negative)
					result = false
				} else {
					playSound(.positive)
					result = true
				}
			} else {
				if leftTarget {
					playSound(.positive)
					result = true
				} else {
					playSound(.negative)
					result = false
				}
			}
		}
		
        let currentTime = Date()
        
        var startPoint = screenPresentedDate
        
        if !result {
            startPoint = (screenPresentedDate as NSDate).laterDate(lastMistakeDate)
            lastMistakeDate = currentTime
        }
        
        let interval: TimeInterval
        let intervalSinceScreenChanged = currentTime.timeIntervalSince(startPoint)
        let lastMistakeInterval = currentTime.timeIntervalSince(lastMistakeDate)
        if result && intervalSinceScreenChanged > lastMistakeInterval {
            interval = lastMistakeInterval
        } else {
            interval = intervalSinceScreenChanged
        }
        let screen: CGFloat = CGFloat(currentScreenShowing)
        model.addCounterpointingMove(screen,
                                     positionY: 0,
                                     success: result,
                                     interval: interval,
                                     inverted: gameModeInversed,
                                     delay:0.0)
        
		if !trainingMode {
        
			if (result) {
				// We don't want to increase time for the total if player made a mistake.
				if (!gameModeInversed) {
					totalOne += intervalSinceScreenChanged
				} else {
					totalTwo += intervalSinceScreenChanged
				}
				session.totalOne = NSNumber(value: totalOne)
				session.totalTwo = NSNumber(value: totalTwo)

				let score = session.score.intValue
				session.score = NSNumber(value: (score + 1) as Int)
			} else {
				let errors = session.errors.intValue
				session.errors = NSNumber(value: (errors + 1) as Int)
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
	
	override func addComment(_ alert: UIAlertController) {
        if let fields = alert.textFields {
            let textField = fields[0]
            if let existingComment = textField.text {
                self.session.comment = existingComment
            }
        }
	}
	override  func getComment() -> String {
		return session.comment
	}
	
	// Shows on which side of the screen dog are
	fileprivate let dogSequence: [Side?] =
	    [nil,
		.right,
		.left,
		nil,
		.left,
		.right,
		.left,
		.left,
		.right,
		.right,
		.left,
		.right,
		.left,
		.left,
		.left,
		.right,
		.left,
		.right,
		.right,
		.right,
		.left,
		.left,
		.right,
		.right,
		nil,
		nil,
		.right,
		.left,
		nil,
		.right,
		.left,
		.right,
		.left,
		.right,
		.right,
		.left,
		.right,
		.right,
		.right,
		.left,
		.left,
		.right,
		.right,
		.left,
		.left,
		.left,
		.right,
		.left,
		.left,
		nil,
		nil]
}
