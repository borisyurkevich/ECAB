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
	
	private var dogPositionOnLeft = true
	private var successSound = AVAudioPlayer()
	private var failureSound = AVAudioPlayer()
	private let model: Model = Model.sharedInstance
	private var session: CounterpointingSession!
	private var pauseButton: UIButton?
	
	override func viewDidLoad() {
		
		view.backgroundColor = UIColor.whiteColor()
		
		let label = UILabel(frame: view.frame)
		label.text = "Example stimuli…"
		label.textAlignment = NSTextAlignment.Center
		label.font = UIFont.systemFontOfSize(44)
		view.addSubview(label)
		
		let gesture = UITapGestureRecognizer(target: self, action: "presentDogOnLeft")
		view.addGestureRecognizer(gesture)
		
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
	}

	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	
	func presentDogOnLeft(){
		cleanView()
		
		dogPositionOnLeft = true;
		
		let imageView = UIImageView(image: UIImage(named: "dog"))
		imageView.frame = CGRectMake(19, 260, 281, 197)
		
		view.addSubview(imageView)
		
		let gesture = UITapGestureRecognizer(target: self, action: "tapHandler:")
		view.addGestureRecognizer(gesture)
	}
	
	func presentDogOnRight(){
		cleanView()
		
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
			// tap on the left side of the screen
			if dogPositionOnLeft {
				failureSound.play()
				result = false
			} else {
				successSound.play()
				presentDogOnLeft()
				result = true
			}
		} else {
			// Tap on right
			if dogPositionOnLeft {
				successSound.play()
				presentDogOnRight()
				result = true
			} else {
				failureSound.play()
				result = false
			}
		}
		model.addCounterpointingMove(location.x, positionY: location.y, success: result)
		
		if result {
			let errors = session.errors.integerValue
			session.errors = NSNumber(integer: (errors + 1))
		} else {
			let score = session.score.integerValue
			session.score = NSNumber(integer: (score + 1))
		}
	}
	
	func cleanView() {
		for v in view.subviews {
			v.removeFromSuperview()
		}
		for g in view.gestureRecognizers! {
			if let recognizer = g as? UITapGestureRecognizer {
				view.removeGestureRecognizer(recognizer)
			}
		}
		pauseButton!.tintColor = UIColor.grayColor()
		addButtonBorder(pauseButton!)
		view.addSubview(pauseButton!)
	}
	
	func presentPause() {
		let alertView = UIAlertController(title: "Game paused", message: "You can quit the game. All progress will be lost.", preferredStyle: .Alert)
		
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
}
