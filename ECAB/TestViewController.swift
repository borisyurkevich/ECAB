//
//  GameViewController.swift
//  ECAB
//
//  Classes
//  TestVC —> Visual Search, Counterpointing
//  Counterpointing —> Flanker, Visual Sustain
//
//  Created by Boris Yurkevich on 6/20/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import AVFoundation

class TestViewController: UIViewController {
	
	let model: Model = Model.sharedInstance
	
	let standardButtonHeight:CGFloat = 30
	let marginTop:CGFloat = 16
	let margin:CGFloat = 16
	let buttonWidth:CGFloat = 100
	
	let pauseButton = UIButton(type: UIButtonType.System)
	let nextButton = UIButton(type: UIButtonType.System)
	let backButton = UIButton(type: UIButtonType.System)
	let skipTrainingButton = UIButton(type: UIButtonType.System)
	
	var successSound = AVAudioPlayer()
	var failureSound = AVAudioPlayer()
	var attentionSound = AVAudioPlayer()
	
	var currentScreenShowing = 0

	var trainingMode = true
	var gamePaused = false
	
	var menuBarHeight: CGFloat = 0.0
	// Doesnt affect Visual Search
	// Affects Y offeset for the big buttons pn left and ride side
	
	enum Side {
		case Left
		case Right
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		
		menuBarHeight = standardButtonHeight + (marginTop * 2)
		
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
		let screenSize: CGSize = UIScreen.mainScreen().bounds.size
		
		backButton.setTitle("Restart", forState: UIControlState.Normal)
		backButton.frame = CGRectMake(marginTop, marginTop, 0, 0)
		backButton.sizeToFit()
		backButton.frame.size.width = buttonWidth
		backButton.addTarget(self, action: "presentPreviousScreen", forControlEvents: UIControlEvents.TouchUpInside)
		backButton.tintColor = UIColor.grayColor()
		addButtonBorder(backButton)

		nextButton.setTitle("Next", forState: UIControlState.Normal)
		nextButton.frame = CGRectMake(backButton.frame.maxX + margin, marginTop, 0, 0)
		nextButton.sizeToFit()
		nextButton.frame.size.width = buttonWidth
		nextButton.addTarget(self, action: "presentNextScreen", forControlEvents: UIControlEvents.TouchUpInside)
		nextButton.tintColor = UIColor.grayColor()
		addButtonBorder(nextButton)
		
		skipTrainingButton.setTitle("Skip", forState: UIControlState.Normal)
		skipTrainingButton.frame = CGRectMake(nextButton.frame.maxX + margin, marginTop, 0, 0)
		skipTrainingButton.sizeToFit()
		skipTrainingButton.frame.size.width = buttonWidth
		skipTrainingButton.tintColor = UIColor.grayColor()
		skipTrainingButton.addTarget(self, action: "skip", forControlEvents: UIControlEvents.TouchUpInside)
		addButtonBorder(skipTrainingButton)
		
		pauseButton.setTitle("Pause", forState: UIControlState.Normal)
		pauseButton.frame = CGRectMake(screenSize.width - (backButton.frame.size.width + marginTop), marginTop, 0, 0)
		pauseButton.sizeToFit()
		pauseButton.frame.size.width = buttonWidth
		pauseButton.addTarget(self, action: "presentPause", forControlEvents: UIControlEvents.TouchUpInside)
		pauseButton.tintColor = UIColor.grayColor()
		addButtonBorder(pauseButton)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "guidedAccessNotificationHandler:", name: "kECABGuidedAccessNotification", object: nil)
		
		view.addSubview(backButton)
		view.addSubview(nextButton)
		view.addSubview(skipTrainingButton)
		view.addSubview(pauseButton)
    }

	func quit() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func addGestures() {
		// Clean gestures first
		if view.gestureRecognizers != nil {
			for gesture in view.gestureRecognizers! {
				view.removeGestureRecognizer(gesture)
			}
		}
	}
	// Removes everything, except, the buttons
	func cleanView() {
		for v in view.subviews {
			if !v.isKindOfClass(UIButton) {
				v.removeFromSuperview()
			}
		}
	}
	
	func addComment(alert: UIAlertController) {
		// Implement in subclassws
	}
	
	func getComment() -> String {
		return "No comment"
	}
	
	func presentPause() {
		gamePaused = true
		
		let alertView = UIAlertController(title: "Game paused", message: "You can quit the game. Add any comment", preferredStyle: .Alert)
		
		alertView.addAction(UIAlertAction(title: "Quit", style: .Default, handler: { (alertAction) -> Void in
			self.addComment(alertView)
			self.quit()
		}))
		alertView.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: {
			(okAction) -> Void in
			self.addComment(alertView)
			self.gamePaused = false
		}))
		alertView.addTextFieldWithConfigurationHandler {
			(textField: UITextField!) -> Void in
			textField.text = self.getComment()
		}
		
		presentViewController(alertView, animated: true, completion: nil)
	}
	
	func presentPreviousScreen() {
		print("❌ Implement presentPreviousScreen() in \(self.description)")
	}
	func presentNextScreen() {
		print("❌ Implement presentNextScreen() in in \(self.description)")
	}
	func skip() {
		print("❌ Implement skip() in \(self.description)")
	}
	
	func addButtonBorder(button: UIButton) {
		button.backgroundColor = UIColor.clearColor()
		button.layer.cornerRadius = 5
		button.layer.borderWidth = 1
		button.layer.borderColor = button.tintColor!.CGColor
	}
	
	func guidedAccessNotificationHandler(notification: NSNotification) {
		
		let enabled: Bool = notification.userInfo!["restriction"] as! Bool!
		pauseButton.enabled = enabled
		
		if pauseButton.enabled == true {
			pauseButton.hidden = false
		} else {
			pauseButton.hidden = true
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
