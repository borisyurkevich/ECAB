//
//  GameViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/20/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import AVFoundation

class GameViewController: UIViewController {
	
	let model: Model = Model.sharedInstance
	
	var pauseButton: UIButton?
	var nextButton: UIButton?
	var backButton: UIButton?
	
	var successSound = AVAudioPlayer()
	var failureSound = AVAudioPlayer()
	
	var currentScreenShowing = 0
	var trainingMode = true

    override func viewDidLoad() {
        super.viewDidLoad()
		
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
		
		// Buttons
		let labelText: String = "Pause"
		pauseButton = UIButton.buttonWithType(UIButtonType.System) as? UIButton
		backButton = UIButton.buttonWithType(UIButtonType.System) as? UIButton
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
