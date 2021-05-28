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

enum SessionType: Int {
    case counterpointing
    case flanker
    case visualSustain
    case flankerRandomized
}

class TestViewController: UIViewController, UITextFieldDelegate {
	
	let model: Model = Model.sharedInstance
    
    let menu = UIView()
	
	let menuHeight:CGFloat = 30
	let marginTop:CGFloat = 16
	let margin:CGFloat = 16
	let buttonWidth:CGFloat = 100
    let menuTag = 10
	
	let pauseButton = BorderedButton(type: UIButton.ButtonType.system)
	let nextButton = BorderedButton(type: UIButton.ButtonType.system)
	let backButton = BorderedButton(type: UIButton.ButtonType.system)
	let skipTrainingButton = BorderedButton(type: UIButton.ButtonType.system)
	
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
	
	enum Side {
		case left
		case right
	}
    
    enum Sound {
        case positive
        case negative
        case attention
    }
    
    func playSound(_ type: Sound) {
    
        switch type {
        case .positive:
            if let soundURL = Bundle.main.url(forResource: "slide-magic", withExtension: "aif") {
                var soundID:SystemSoundID = 1
                AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
                AudioServicesPlaySystemSound(soundID)
            } else {
                presentErrorAlert()
            }
        case .negative:
            if let soundURL = Bundle.main.url(forResource: "beep-attention", withExtension: "aif") {
                var soundID:SystemSoundID = 1
                AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
                AudioServicesPlaySystemSound(soundID)
            } else {
                presentErrorAlert()
            }
        case .attention:
            if let soundURL = Bundle.main.url(forResource: "beep-piano", withExtension: "aif") {
                var soundID:SystemSoundID = 1
                AudioServicesCreateSystemSoundID(soundURL as CFURL, &soundID)
                AudioServicesPlaySystemSound(soundID)
            } else {
                presentErrorAlert()
            }
        }
    }
    
    func presentErrorAlert() {
        let errorAlert = UIAlertController(title: nil,
            message: "Couldn't play a sound.",
            preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(okayAction)
        present(errorAlert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = UIColor.white
		
		menuBarHeight = menuHeight + (marginTop * 2)
		
		// Buttons
		
		backButton.setTitle("Restart", for: UIControl.State())
		backButton.sizeToFit()
		backButton.addTarget(self, action: #selector(presentPreviousScreen), for: .touchUpInside)

		backButton.tintColor = UIColor.gray

		nextButton.setTitle("Next", for: UIControl.State())
		nextButton.sizeToFit()
        nextButton.addTarget(self, action: #selector(presentNextScreen), for: .touchUpInside)

		nextButton.tintColor = UIColor.gray

		skipTrainingButton.setTitle("Skip", for: UIControl.State())
		skipTrainingButton.sizeToFit()
		skipTrainingButton.tintColor = UIColor.gray
        skipTrainingButton.addTarget(self, action: #selector(skip), for: .touchUpInside)

		pauseButton.setTitle("Pause", for: UIControl.State())
		pauseButton.sizeToFit()
		pauseButton.addTarget(self, action: #selector(presentPause), for: .touchUpInside)
		pauseButton.tintColor = UIColor.gray

		NotificationCenter.default.addObserver(self, selector: #selector(TestViewController.guidedAccessNotificationHandler(_:)), name: NSNotification.Name(rawValue: "kECABGuidedAccessNotification"), object: nil)
                
        menu.translatesAutoresizingMaskIntoConstraints = false
        backButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        skipTrainingButton.translatesAutoresizingMaskIntoConstraints = false
        pauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Tag the menu view to preserve it during Visual Sustain test.
        menu.tag = menuTag
    }
    
    func layoutMenu() {
        menu.addSubview(backButton)
        menu.addSubview(nextButton)
        menu.addSubview(skipTrainingButton)
        menu.addSubview(pauseButton)
        
        let screen = view.layoutMarginsGuide
        
        let constraints = [
            menu.topAnchor.constraint(equalTo: screen.topAnchor, constant: margin),
            menu.heightAnchor.constraint(equalToConstant: menuHeight),
            menu.leftAnchor.constraint(equalTo: screen.leftAnchor),
            menu.rightAnchor.constraint(equalTo: screen.rightAnchor),
            menu.centerXAnchor.constraint(equalTo: screen.centerXAnchor),
            
            backButton.leftAnchor.constraint(equalTo: menu.leftAnchor),
            backButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            
            nextButton.leftAnchor.constraint(equalTo: backButton.rightAnchor, constant: margin),
            nextButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            
            skipTrainingButton.leftAnchor.constraint(equalTo: nextButton.rightAnchor, constant: margin),
            skipTrainingButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            
            pauseButton.rightAnchor.constraint(equalTo: screen.rightAnchor),
            pauseButton.widthAnchor.constraint(equalToConstant: buttonWidth)
            
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: Presentation

	@objc func presentPreviousScreen() {
		print("❌ Implement presentPreviousScreen() in \(self.description)")
	}
	@objc func presentNextScreen() {
		print("❌ Implement presentNextScreen() in in \(self.description)")
	}
	@objc func skip() {
		print("❌ Implement skip() in \(self.description)")
	}
	
	func delay(_ delay: Double, closure: @escaping () -> Void) {
		DispatchQueue.main.asyncAfter(
			deadline: DispatchTime.now() + Double(Int(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
	}
    
    // MARK: GUI
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // Removes everything, except, the buttons
    func cleanView() {
        for v in view.subviews {
            if !v.isKind(of: UIButton.self) && v.tag != menuTag {
                v.removeFromSuperview()
            }
        }
        playerInteractionsDisabled = false
    }
    
    // MARK: Quit, pause, and comment
    
    func resumeTest() {
        // Override in subclass and resume timers
    }
    
    @objc func presentPause() {
        gamePaused = true
        
        let activity = UIActivityIndicatorView(style: .gray)
        pauseButton.setTitle("", for: UIControl.State())
        pauseButton.addSubview(activity)
        activity.startAnimating()
        
        // For some reason it takes long time, need to show something in UI.
        if #available(iOS 9.0, *) {
            activity.translatesAutoresizingMaskIntoConstraints = false
            activity.centerYAnchor.constraint(equalTo: pauseButton.centerYAnchor).isActive = true
            activity.centerXAnchor.constraint(equalTo: pauseButton.centerXAnchor).isActive = true
            
        } else {
            // Fallback on earlier versions
            // In this case inidcator is not centered in the button, not a big deal.
        }
        
        let alertView = UIAlertController(title: "Pause", message: "Quit this test and add a comment.", preferredStyle: .alert)
        
        let quit = UIAlertAction(title: "Quit", style: .default, handler: { (alertAction) -> Void in
            self.addComment(alertView)
            self.quit()
        })
        let continueAction = UIAlertAction(title: "Continue", style: .cancel, handler: {
            (okAction) -> Void in
            self.addComment(alertView)
            self.gamePaused = false
            self.resumeTest()
        })
        
        alertView.addAction(quit)
        alertView.addAction(continueAction)

        alertView.addTextField {
            (textField: UITextField!) -> Void in
            
            textField.delegate = self
            textField.clearButtonMode = .always
            textField.placeholder = "Your comment"
            textField.autocapitalizationType = .sentences
            textField.text = self.getComment()
        }
        
        present(alertView, animated: true) { 
            activity.removeFromSuperview()
            self.pauseButton.setTitle("Pause", for: UIControl.State())
        }
    }
    func addComment(_ alert: UIAlertController) {
        // Implement in subclassws
    }
    func getComment() -> String? {
        return ""
    }
    func quit() {
        self.dismiss(animated: true, completion: nil)
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
    
    @objc func guidedAccessNotificationHandler(_ notification: Notification) {
        
        guard let enabled: Bool = notification.userInfo!["restriction"] as? Bool else {
            return
        }
        pauseButton.isEnabled = enabled
        
        if pauseButton.isEnabled == true {
            pauseButton.isHidden = false
        } else {
            pauseButton.isHidden = true
        }
        // Hide button completly
    }
}

final class BorderedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)

        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 5

        contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func tintColorDidChange() {
        super.tintColorDidChange()

        layer.borderColor = UIColor.gray.cgColor
    }

    override var isHighlighted: Bool {
        didSet {
            let fadedColor = tintColor.withAlphaComponent(0.2).cgColor

            if isHighlighted {
                layer.borderColor = fadedColor
            } else {
                layer.borderColor = UIColor.gray.cgColor

                let animation = CABasicAnimation(keyPath: "borderColor")
                animation.fromValue = fadedColor
                animation.toValue = UIColor.gray.cgColor
                animation.duration = 0.4
                layer.add(animation, forKey: nil)
            }
        }
    }
}
