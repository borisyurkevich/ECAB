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

class TestViewController: UIViewController, UITextFieldDelegate {
	
	let model: Model = Model.sharedInstance
	
	let standardButtonHeight:CGFloat = 30
	let marginTop:CGFloat = 16
	let margin:CGFloat = 16
	let buttonWidth:CGFloat = 100
	
	let pauseButton = UIButton(type: UIButtonType.System)
	let nextButton = UIButton(type: UIButtonType.System)
	let backButton = UIButton(type: UIButtonType.System)
	let skipTrainingButton = UIButton(type: UIButtonType.System)
	
	var currentScreenShowing = 0

	var trainingMode = true
	var gamePaused = false
    
    // For cases when information on the screen, for example,
    // blue dot or title label. In this case app should not 
    // accept players interactions.
    var playerInteractionsDisabled = false
	
	var menuBarHeight: CGFloat = 0.0
	// Doesnt affect Visual Search
	// Affects Y offeset for the big buttons pn left and ride side
    
    func playSound(sound: Sound) {
        let soundURL = NSBundle.mainBundle().URLForResource(sound.rawValue, withExtension: "mp3");
        var soundID:SystemSoundID = 1;
        AudioServicesCreateSystemSoundID(soundURL!, &soundID);
        AudioServicesPlaySystemSound(soundID);
    }
    
    func presentErrorAlert() {
        let errorAlert = UIAlertController(title: nil,
            message: "Couldn't play a sound.",
            preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        errorAlert.addAction(okayAction)
        presentViewController(errorAlert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = UIColor.whiteColor()
		
		menuBarHeight = standardButtonHeight + (marginTop * 2)
		
		// Buttons
		let screenSize: CGSize = UIScreen.mainScreen().bounds.size
		
		backButton.setTitle("Restart", forState: UIControlState.Normal)
		backButton.frame = CGRectMake(marginTop, marginTop, 0, 0)
		backButton.sizeToFit()
		backButton.frame.size.width = buttonWidth
		backButton.addTarget(self, action: #selector(TestViewController.presentPreviousScreen), forControlEvents: UIControlEvents.TouchUpInside)
		backButton.tintColor = UIColor.grayColor()
		addButtonBorder(backButton)

		nextButton.setTitle("Next", forState: UIControlState.Normal)
		nextButton.frame = CGRectMake(backButton.frame.maxX + margin, marginTop, 0, 0)
		nextButton.sizeToFit()
		nextButton.frame.size.width = buttonWidth
		nextButton.addTarget(self, action: #selector(TestViewController.presentNextScreen), forControlEvents: UIControlEvents.TouchUpInside)
		nextButton.tintColor = UIColor.grayColor()
		addButtonBorder(nextButton)
		
		skipTrainingButton.setTitle("Skip", forState: UIControlState.Normal)
		skipTrainingButton.frame = CGRectMake(nextButton.frame.maxX + margin, marginTop, 0, 0)
		skipTrainingButton.sizeToFit()
		skipTrainingButton.frame.size.width = buttonWidth
		skipTrainingButton.tintColor = UIColor.grayColor()
		skipTrainingButton.addTarget(self, action: #selector(TestViewController.skip), forControlEvents: UIControlEvents.TouchUpInside)
		addButtonBorder(skipTrainingButton)
		
		pauseButton.setTitle("Pause", forState: UIControlState.Normal)
		pauseButton.frame = CGRectMake(screenSize.width - (backButton.frame.size.width + marginTop), marginTop, 0, 0)
		pauseButton.sizeToFit()
		pauseButton.frame.size.width = buttonWidth
		pauseButton.addTarget(self, action: #selector(TestViewController.presentPause), forControlEvents: UIControlEvents.TouchUpInside)
		pauseButton.tintColor = UIColor.grayColor()
		addButtonBorder(pauseButton)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(TestViewController.guidedAccessNotificationHandler(_:)), name: "kECABGuidedAccessNotification", object: nil)
		
		view.addSubview(backButton)
		view.addSubview(nextButton)
		view.addSubview(skipTrainingButton)
		view.addSubview(pauseButton)
    }
    
    // MARK: Presentation
	
	func presentPreviousScreen() {
		print("❌ Implement presentPreviousScreen() in \(self.description)")
	}
    
	func presentNextScreen() {
		print("❌ Implement presentNextScreen() in in \(self.description)")
	}
    
	func skip() {
		print("❌ Implement skip() in \(self.description)")
	}
	
	func delay(delay:Double, closure:()->()) {
		dispatch_after(
			dispatch_time(
				DISPATCH_TIME_NOW,
				Int64(delay * Double(NSEC_PER_SEC))
			),
			dispatch_get_main_queue(), closure)
	}
    
    // MARK: GUI
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func addButtonBorder(button: UIButton) {
        button.backgroundColor = UIColor.clearColor()
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = button.tintColor!.CGColor
    }
    
    // Removes everything, except, the buttons
    func cleanView() {
        for v in view.subviews {
            if !v.isKindOfClass(UIButton) {
                v.removeFromSuperview()
            }
        }
        playerInteractionsDisabled = false
    }
    
    // MARK: Quit, pause, and comment
    func presentPause() {
        gamePaused = true
        
        let activity = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        pauseButton.setTitle("", forState: .Normal)
        pauseButton.addSubview(activity)
        activity.startAnimating()
        
        // For some reason it takes long time, need to show something in UI.
        if #available(iOS 9.0, *) {
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.centerYAnchor.constraintEqualToAnchor(pauseButton.centerYAnchor).active = true
            activity.centerXAnchor.constraintEqualToAnchor(pauseButton.centerXAnchor).active = true
            
        } else {
            // Fallback on earlier versions
            // In this case inidcator is not centered in the button, not a big deal.
        }
        
        let alertView = UIAlertController(title: "Pause", message: "Quit this test or add a comment.", preferredStyle: .Alert)
        
        let quit = UIAlertAction(title: "Quit", style: .Default, handler: { (alertAction) -> Void in
            self.addComment(alertView)
            self.quit()
        })
        let continueAction = UIAlertAction(title: "Continue", style: .Cancel, handler: {
            (okAction) -> Void in
            self.addComment(alertView)
            self.gamePaused = false
        })
        
        alertView.addAction(quit)
        alertView.addAction(continueAction)

        alertView.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            
            textField.delegate = self
            textField.clearButtonMode = .Always
            textField.placeholder = "Your comment"
            textField.autocapitalizationType = .Sentences
            textField.text = self.getComment()
        }
        
        presentViewController(alertView, animated: true) { 
            activity.removeFromSuperview()
            self.pauseButton.setTitle("Pause", forState: .Normal)
        }
    }
    
    func addComment(alert: UIAlertController) {
        // Implement in subclassws
    }
    
    func getComment() -> String? {
        return ""
    }
    
    func quit() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: Other
    
    func addGestures() {
        // Clean gestures first
        if view.gestureRecognizers != nil {
            for gesture in view.gestureRecognizers! {
                view.removeGestureRecognizer(gesture)
            }
        }
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
}
