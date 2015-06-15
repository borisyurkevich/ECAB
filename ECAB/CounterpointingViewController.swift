//
//  CounterpointingViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/7/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import AVFoundation

class CounterpointingViewController: UIViewController {
	
	private var dogPositionOnLeft = false // first screen will be with dog on right
	private var gameModeInversed = false
	private var successSound = AVAudioPlayer()
	private var failureSound = AVAudioPlayer()
	private let model: Model = Model.sharedInstance
	private var session: CounterpointingSession!
	private var pauseButton: UIButton?
	private var nextButton: UIButton?
	private let screensTotal = 10
	private let transitionPointScreen = 5
	private var currentScreenShowing = 0
	private var trainingMode = true
	private var screenPresentedDate = NSDate()
	
	override func viewDidLoad() {
		
		view.backgroundColor = UIColor.whiteColor()
		
		// Sounds
		let successSoundPath = NSBundle.mainBundle().pathForResource("slide-magic", ofType: "aif")
		let successSoundURL = NSURL(fileURLWithPath: successSoundPath!)
		var error: NSError?
		successSound = AVAudioPlayer(contentsOfURL: successSoundURL, error: &error)
		successSound.prepareToPlay()
		
		let failureSoundPath = NSBundle.mainBundle().pathForResource("beep-attention", ofType: "aif")
		let failureSoundURL = NSURL(fileURLWithPath: failureSoundPath!)
		var errorFailure: NSError?
		failureSound = AVAudioPlayer(contentsOfURL: failureSoundURL, error: &errorFailure)
		failureSound.prepareToPlay()
		
		// Data
		model.addCounterpointingSession(model.data.selectedPlayer)
		session = model.data.counterpointingSessions.lastObject as! CounterpointingSession
		
		// Add pause button
		let labelText: String = "Pause"
		pauseButton = UIButton.buttonWithType(UIButtonType.System) as? UIButton
		let size: CGSize = labelText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(28.0)])
		let screen: CGSize = UIScreen.mainScreen().bounds.size
		pauseButton!.setTitle(labelText, forState: UIControlState.Normal)
		pauseButton!.frame = CGRectMake(screen.width - (size.width*2), 16, size.width + 2, size.height)
		pauseButton!.addTarget(self, action: "presentPause", forControlEvents: UIControlEvents.TouchUpInside)
		
		presentMessage("Practice: touch the side with the dog")
	}
	
	func presentNextScreen() {
		currentScreenShowing++
	
		cleanView()
		screenPresentedDate = NSDate()
		
		switch currentScreenShowing {
		case 1:
			presentDogOnRight()
			break
		case 2:
			presentDogOnLeft()
			break
		case 3:
			presentMessage("Touch the side with the dog as quickly as you can!")
			trainingMode = false
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
		dogPositionOnLeft = true;
		
		let imageView = UIImageView(image: UIImage(named: "dog"))
		imageView.frame = CGRectMake(19, 260, 281, 197)
		
		view.addSubview(imageView)
		
		let gesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
		view.addGestureRecognizer(gesture)
	}
	
	func presentDogOnRight(){
		dogPositionOnLeft = false;
		
		let imageView = UIImageView(image: UIImage(named: "dog_inverse"))
		imageView.frame = CGRectMake(view.bounds.width-300, 260, 281, 197)
		
		view.addSubview(imageView)
		
		let gesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
		view.addGestureRecognizer(gesture)
	}
	
	func tapHandler(sender: UITapGestureRecognizer){
		// Determine Success or failure
		let location = sender.locationInView(view)
		let screenWidth = view.bounds.size.width
		let middlePoint = screenWidth/2
		
		var result:Bool
		
		if location.x < middlePoint {
			if !gameModeInversed {
				// tap on the left side of the screen
				if dogPositionOnLeft {
					successSound.play()
					result = true
				} else {
					failureSound.play()
					result = false
				}
			} else {
				// tap on the left side of the screen
				if dogPositionOnLeft {
					failureSound.play()
					result = false
				} else {
					successSound.play()
					result = true
				}
			}
		} else {
			// Tap on right
			if !gameModeInversed {
				if dogPositionOnLeft {
					failureSound.play()
					result = false
				} else {
					successSound.play()
					result = true
				}
			} else {
				if dogPositionOnLeft {
					successSound.play()
					result = true
				} else {
					failureSound.play()
					result = false
				}
			}
		}
		let currentTime = NSDate()
		var interval = currentTime.timeIntervalSinceDate(screenPresentedDate) * 1000.0
		if (!trainingMode) {
			model.addCounterpointingMove(location.x, positionY: location.y, success: result, interval: Int(interval))
		}
		
		if result {
			let score = session.score.integerValue
			session.score = NSNumber(integer: (score + 1))
			if !trainingMode {
				presentBlueDot()
			} else {
				presentNextScreen()
			}
		} else {
			let errors = session.errors.integerValue
			session.errors = NSNumber(integer: (errors + 1))
		}
	}
	
	func cleanView() {
		for v in view.subviews {
			v.removeFromSuperview()
		}
		
		if view.gestureRecognizers != nil {
			for g in view.gestureRecognizers! {
				if let recognizer = g as? UITapGestureRecognizer {
					view.removeGestureRecognizer(recognizer)
				}
			}
		}
		pauseButton!.tintColor = UIColor.grayColor()
		addButtonBorder(pauseButton!)
		view.addSubview(pauseButton!)
	}
	
	func presentPause() {
		let alertView = UIAlertController(title: "Game paused", message: "You can quit the game.", preferredStyle: .Alert)
		
		alertView.addAction(UIAlertAction(title: "Quit", style: .Default, handler: { (alertAction) -> Void in
			self.quit()
		}))
		alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
		
		presentViewController(alertView, animated: true, completion: nil)
	}
	
	func quit() {
		self.dismissViewControllerAnimated(true, completion: nil)
		
		println("Result: \(session.score)")
	}
	
	func addButtonBorder(button: UIButton) {
		button.backgroundColor = UIColor.clearColor()
		button.layer.cornerRadius = 5
		button.layer.borderWidth = 1
		button.layer.borderColor = button.tintColor!.CGColor
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
}
