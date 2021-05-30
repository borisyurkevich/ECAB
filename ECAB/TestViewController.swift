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
import os


class TestViewController: UIViewController, UITextFieldDelegate, GameMenuDelegate {

    enum Side {
        case left
        case right
    }

    enum Sound {
        case positive
        case negative
        case attention
    }
	
	let model: Model = Model.sharedInstance

    var currentScreenShowing = 0
    var trainingMode = true
    var gamePaused = false
    var gameMenuViewController: GameMenuViewController?

    /// For cases when information on the screen, for example,
    /// blue dot or title label. In this case app should not
    /// accept players interactions.
    var playerInteractionsDisabled = false

    /// Doesnt affect Visual Search
    /// Affects Y offeset for the big buttons pn left and ride side
    let menuBarHeight: CGFloat = 36.0

    let menuTag = 10 // Set in Menu.storyboard

    override var prefersStatusBarHidden : Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		
		view.backgroundColor = UIColor.white

		NotificationCenter.default.addObserver(self, selector: #selector(Self.guidedAccessNotificationHandler(_:)), name: NSNotification.Name(rawValue: "kECABGuidedAccessNotification"), object: nil)
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

    func addMenu() {
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        guard let initialViewController = storyboard.instantiateInitialViewController() as? GameMenuViewController else {
            fatalError("Storyboard error")
        }
        gameMenuViewController = initialViewController
        guard let gameMenuViewController = gameMenuViewController else {
            fatalError("Failed to initialize the menu")
        }
        addChild(gameMenuViewController)
        view.addSubview(gameMenuViewController.view)
        layoutMenu()
        gameMenuViewController.didMove(toParent: self)
        gameMenuViewController.delelgate = self
    }
    
    // MARK: Presentation

    /// Helper function to delay closure execution
    func delay(_ delay: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),
            execute: closure
        )
    }
    
    /// Removes everything except the menu
    func cleanView() {
        for v in view.subviews {
            if !v.isKind(of: UIButton.self) && v.tag != menuTag {
                v.removeFromSuperview()
            }
        }
        playerInteractionsDisabled = false
    }
    
    // MARK: Other
    
    @objc func guidedAccessNotificationHandler(_ notification: Notification) {
        guard let enabled: Bool = notification.userInfo!["restriction"] as? Bool else {
            return
        }
        gameMenuViewController?.updatePauseButtonState(isHidden: !enabled)
    }

    // MARK: - GameMenuDelegate

    @objc func presentPreviousScreen() {
        os_log(.error, "❌ Implement presentPreviousScreen() in %@", self.description)
    }
    @objc func presentNextScreen() {
        os_log(.error, "❌ Implement presentNextScreen() in in %@", self.description)
    }
    @objc func skip() {
        os_log(.error, "❌ Implement skip() in %@", self.description)
    }
    func resumeTest() {
        os_log(.error, "❌ Override in subclass and resume timers")
    }

    @objc func presentPause() {
        gamePaused = true
        DispatchQueue.main.async { [unowned self] in
            gameMenuViewController?.startAnimatingPauseButton()
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

        present(alertView, animated: true) { [unowned self] in
            DispatchQueue.main.async {
                self.gameMenuViewController?.stopAnimatingPauseButton()
            }
        }
    }

    // MARK: Quit, pause, and comment

    func addComment(_ alert: UIAlertController) {
        // Implement in subclassws
    }
    func getComment() -> String? {
        return ""
    }
    func quit() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private

    private func layoutMenu() {
        guard let menu = gameMenuViewController?.view else {
            fatalError("Failed to initialize the menu")
        }
        menu.translatesAutoresizingMaskIntoConstraints = false

        let screen = view.layoutMarginsGuide

        let constraints = [
            menu.topAnchor.constraint(equalTo: screen.topAnchor, constant: 0),
            menu.heightAnchor.constraint(equalToConstant: menuBarHeight),
            menu.leadingAnchor.constraint(equalTo: screen.leadingAnchor),
            menu.trailingAnchor.constraint(equalTo: screen.trailingAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
}
