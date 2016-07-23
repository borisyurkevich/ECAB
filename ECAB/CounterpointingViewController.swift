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
	var sessionType = SessionType.Counterpointing.rawValue
	private let pictureHeight: CGFloat = 197
	private let pictureWidth: CGFloat = 281
	var gameModeInversed = false
	var touchModeInverserd = false

	var leftTarget = false // first screen will be with dog on right
	var session: CounterpointingSession!
	private var totalOne = 0.0
	private var totalTwo = 0.0
    
    var pauseDate: NSDate?
    var pauseLength: NSTimeInterval?
	
	// MARK: Override
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		model.addCounterpointingSession(model.data.selectedPlayer, type: sessionType)
		session = model.data.counterpointingSessions.lastObject as! CounterpointingSession
		presentMessage(greeingMessage)
		addTouchTargetButtons()
	}
    
    override func presentPause() {
        
        pauseDate = NSDate()
        super.presentPause()
    }
    override func resumeTest() {
        
        pauseLength = NSDate().timeIntervalSinceDate(pauseDate!)
        pauseDate = nil
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
	
	func presentDogOnSide(screenSide: Side) {
		if screenSide == .Left {
			presentDogOnLeft()
		} else if screenSide == .Right {
			presentDogOnRight()
		}
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
	
	override func presentNextScreen() {
		currentScreenShowing += 1
	
		cleanView()
		screenPresentedDate = NSDate()
		
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
		
		let screen = UIScreen.mainScreen().bounds
		let screenAreaLeft = CGRectMake(0, menuBarHeight, screen.size.width/2, screen.size.height-menuBarHeight)
		let screenAreaRight = CGRectMake(screen.size.width/2, menuBarHeight, screen.size.width/2, screen.size.height-menuBarHeight)
		let buttonLeft = UIButton(frame: screenAreaLeft)
		let buttonRight = UIButton(frame: screenAreaRight)
		buttonLeft.addTarget(self, action: #selector(CounterpointingViewController.handleTouchLeft), forControlEvents: UIControlEvents.TouchDown)
		buttonRight.addTarget(self, action: #selector(CounterpointingViewController.handleTouchRight), forControlEvents: UIControlEvents.TouchDown)
		view.addSubview(buttonLeft)
		view.addSubview(buttonRight)
	}
	
	func presentBlueDot() {
		cleanView()
				
		let dot = UIImageView(image: UIImage(named: "Blue Dot"))
		dot.center = view.center
		view.addSubview(dot)
        
        self.playerInteractionsDisabled = true
	}
	
	func presentMessage(message: String){
		let label = UILabel(frame: view.frame)
		label.numberOfLines = 3
		label.text = message
		label.textAlignment = NSTextAlignment.Center
		label.font = UIFont.systemFontOfSize(44)
		view.addSubview(label)
        
        self.playerInteractionsDisabled = true
	}
	
	func handleTouchLeft() {
		tapHandler(true)
	}
	func handleTouchRight() {
		tapHandler(false)
	}
	func tapHandler(touchLeft: Bool){
		// Determine Success or failure
		
        if playerInteractionsDisabled {
            return
        }
		
		var result:Bool
		
		if touchLeft {
			if !touchModeInverserd {
				// tap on the left side of the screen
				if leftTarget {
					playSound(.Positive)
					result = true
				} else {
					playSound(.Negative)
					result = false
				}
			} else {
				// tap on the left side of the screen
				if leftTarget {
					playSound(.Negative)
					result = false
				} else {
					playSound(.Positive)
					result = true
				}
			}
		} else {
			// Tap on right
			if !touchModeInverserd {
				if leftTarget {
					playSound(.Negative)
					result = false
				} else {
					playSound(.Positive)
					result = true
				}
			} else {
				if leftTarget {
					playSound(.Positive)
					result = true
				} else {
					playSound(.Negative)
					result = false
				}
			}
		}
		
        let currentTime = NSDate()
        
        var startPoint = screenPresentedDate
        
        if let pauseInterval = pauseLength {
            startPoint = screenPresentedDate.dateByAddingTimeInterval(pauseInterval)
        }
        
        if !result {
            startPoint = screenPresentedDate.laterDate(lastMistakeDate)
            lastMistakeDate = currentTime
        }
        let interval = currentTime.timeIntervalSinceDate(startPoint)
        let screen: CGFloat = CGFloat(currentScreenShowing)
        model.addCounterpointingMove(screen, positionY: 0, success: result, interval: interval, inverted: gameModeInversed, delay:0.0)
        
		if !trainingMode {
        
			if (result) {
				// We don't want to increase time for the total if player made a mistake.
				if (!gameModeInversed) {
					totalOne += interval
				} else {
					totalTwo += interval
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
	private let dogSequence: [Side?] =
	    [nil,
		.Right,
		.Left,
		nil,
		.Left,
		.Right,
		.Left,
		.Left,
		.Right,
		.Right,
		.Left,
		.Right,
		.Left,
		.Left,
		.Left,
		.Right,
		.Left,
		.Right,
		.Right,
		.Right,
		.Left,
		.Left,
		.Right,
		.Right,
		nil,
		nil,
		.Right,
		.Left,
		nil,
		.Right,
		.Left,
		.Right,
		.Left,
		.Right,
		.Right,
		.Left,
		.Right,
		.Right,
		.Right,
		.Left,
		.Left,
		.Right,
		.Right,
		.Left,
		.Left,
		.Left,
		.Right,
		.Left,
		.Left,
		nil,
		nil]
}
