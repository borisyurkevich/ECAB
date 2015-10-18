//
//  GameViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/20/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import AVFoundation

class TestViewController: UIViewController {
	
	let model: Model = Model.sharedInstance
	
	var pauseButton: UIButton?
	var nextButton: UIButton?
	var backButton: UIButton?
	var skipTrainingButton: UIButton?
	
	var successSound = AVAudioPlayer()
	var failureSound = AVAudioPlayer()
	var attentionSound = AVAudioPlayer()
	
	var currentScreenShowing = 0
	var trainingMode = true

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		
		// Sounds
		let successSoundPath = NSBundle.mainBundle().pathForResource("slide-magic", ofType: "aif")
		let successSoundURL = NSURL(fileURLWithPath: successSoundPath!)
		var error: NSError?
		do {
			successSound = try AVAudioPlayer(contentsOfURL: successSoundURL)
		} catch let error1 as NSError {
			error = error1
			print("Error \(error)")
		}
		successSound.prepareToPlay()
		let failureSoundPath = NSBundle.mainBundle().pathForResource("beep-attention", ofType: "aif")
		let failureSoundURL = NSURL(fileURLWithPath: failureSoundPath!)
		do {
			failureSound = try AVAudioPlayer(contentsOfURL: failureSoundURL)
		} catch let error as NSError {
			print("Error \(error)")
		}
		failureSound.prepareToPlay()
		let attentionSoundPath = NSBundle.mainBundle().pathForResource("beep-piano", ofType: "aif")
		let attentionSoundIRL = NSURL(fileURLWithPath: attentionSoundPath!)
		do {
			attentionSound = try AVAudioPlayer(contentsOfURL: attentionSoundIRL)
		} catch let error as NSError {
			print("Error \(error)")
		}
		
		// Buttons
		let labelText: String = "Pause"
		pauseButton = UIButton(type: UIButtonType.System)
		backButton = UIButton(type: UIButtonType.System)
		let size: CGSize = labelText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(28.0)])
		let screen: CGSize = UIScreen.mainScreen().bounds.size
		pauseButton!.setTitle(labelText, forState: UIControlState.Normal)
		pauseButton!.frame = CGRectMake(screen.width - (size.width*2), 16, size.width + 2, size.height)
		pauseButton!.addTarget(self, action: "presentPause", forControlEvents: UIControlEvents.TouchUpInside)
		pauseButton!.tintColor = UIColor.grayColor()
		addButtonBorder(pauseButton!)
		let backText = "Restart training"
		let backLabelSize: CGSize = backText.sizeWithAttributes([NSFontAttributeName: UIFont.systemFontOfSize(28.0)])
		backButton!.setTitle(backText, forState: UIControlState.Normal)
		backButton!.frame = CGRectMake(16, 16, 140, backLabelSize.height)
		backButton!.addTarget(self, action: "presentPreviousScreen", forControlEvents: UIControlEvents.TouchUpInside)
		backButton!.tintColor = UIColor.grayColor()
		addButtonBorder(backButton!)

		nextButton = UIButton(type: UIButtonType.System)
		nextButton!.setTitle("Next", forState: UIControlState.Normal)
		nextButton!.frame = CGRectMake(160, 16, size.width + 2, size.height)
		nextButton!.addTarget(self, action: "presentNextScreen", forControlEvents: UIControlEvents.TouchUpInside)
		nextButton!.tintColor = UIColor.grayColor()
		addButtonBorder(nextButton!)
		
		skipTrainingButton = UIButton(type: UIButtonType.System)
		skipTrainingButton?.setTitle("Skip", forState: UIControlState.Normal)
		skipTrainingButton?.frame = backButton!.frame
		skipTrainingButton?.tintColor = UIColor.grayColor()
		skipTrainingButton?.addTarget(self, action: "skip", forControlEvents: UIControlEvents.TouchUpInside)
		addButtonBorder(skipTrainingButton!)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "guidedAccessNotificationHandler:", name: "kECABGuidedAccessNotification", object: nil)
		
		view.addSubview(skipTrainingButton!)
    }

	func quit() {
		self.dismissViewControllerAnimated(true, completion: nil)
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
		view.addSubview(pauseButton!)
	}
	
	func addComment(alert: UIAlertController) {
		// Implement in subclassws
	}
	
	func getComment() -> String {
		return "No comment"
	}
	
	func presentPause() {
		let alertView = UIAlertController(title: "Game paused", message: "You can quit the game. Add any comment", preferredStyle: .Alert)
		
		alertView.addAction(UIAlertAction(title: "Quit", style: .Default, handler: { (alertAction) -> Void in
			self.addComment(alertView)
			self.quit()
		}))
		alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: {
			(okAction) -> Void in
			self.addComment(alertView)
		}))
		alertView.addTextFieldWithConfigurationHandler {
			(textField: UITextField!) -> Void in
			textField.text = self.getComment()
		}
		
		presentViewController(alertView, animated: true, completion: nil)
	}
	
	func skip() {
		// To be implemented in subclasses
		print("Please implement skip() in this class")
	}
	
	func addButtonBorder(button: UIButton) {
		button.backgroundColor = UIColor.clearColor()
		button.layer.cornerRadius = 5
		button.layer.borderWidth = 1
		button.layer.borderColor = button.tintColor!.CGColor
	}
	
	func guidedAccessNotificationHandler(notification: NSNotification) {
		
		let enabled: Bool = notification.userInfo!["restriction"] as! Bool!
		pauseButton?.enabled = enabled
		
		if pauseButton?.enabled == true {
			pauseButton?.hidden = false
		} else {
			pauseButton?.hidden = true
		}
		// Hide button completly
	}
	
	override func prefersStatusBarHidden() -> Bool {
		return true
	}
	
	func delay(delay:Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delay * Double(NSEC_PER_SEC))
			),
			dispatch_get_main_queue(), closure)
	}
}
