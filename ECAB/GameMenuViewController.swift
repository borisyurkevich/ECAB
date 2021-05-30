//
//  GameMenuViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 29/05/2021.
//  Copyright © 2021 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import os


final class GameMenuViewController: UIViewController {

    weak var delelgate: GameMenuDelegate?

    @IBOutlet private weak var menuView: MenuView!
    @IBOutlet private weak var menuStrip: UIView!
    @IBOutlet private weak var backLabel: UILabel!
    @IBOutlet private weak var forwardLabel: UILabel!
    @IBOutlet private weak var skipLabel: UILabel!
    @IBOutlet private weak var pauseLabel: UILabel!

    private let borderWidth: CGFloat = 1.0
    private let borderColor: CGColor = UIColor.darkGray.cgColor
    private var buttonColor: UIColor?
    private var activity: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        addMenuBorders()
        setTextColor()
        menuView.delegate = self
        buttonColor = backLabel.backgroundColor
    }

    func toggleNavigationButtons(isEnabled: Bool) {
        forwardLabel.isEnabled = isEnabled
        backLabel.isEnabled = isEnabled
        skipLabel.isEnabled = isEnabled
    }

    func updatePauseButtonState(isHidden: Bool) {
        pauseLabel.isHidden = isHidden
    }

    func updateBackButtonTitle(_ title: String) {
        backLabel.text = title
    }

    func startAnimatingPauseButton() {
        pauseLabel.text = ""
        activity = UIActivityIndicatorView(style: .medium)

        guard let activity = activity else {
            return
        }

        activity.startAnimating()
        pauseLabel.addSubview(activity)

        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.centerYAnchor.constraint(equalTo: pauseLabel.centerYAnchor).isActive = true
        activity.centerXAnchor.constraint(equalTo: pauseLabel.centerXAnchor).isActive = true
    }

    func stopAnimatingPauseButton() {
        activity?.removeFromSuperview()
        self.pauseLabel.text = "Pause"
        self.pauseLabel.textColor = UIColor.label
    }

    // MARK: - Private

    private func addMenuBorders() {
        backLabel.layer.borderWidth = borderWidth
        backLabel.layer.borderColor = borderColor

        forwardLabel.layer.borderWidth = borderWidth
        forwardLabel.layer.borderColor = borderColor

        skipLabel.layer.borderWidth = borderWidth
        skipLabel.layer.borderColor = borderColor

        pauseLabel.layer.borderWidth = borderWidth
        pauseLabel.layer.borderColor = borderColor
    }

    private func setTextColor() {
        backLabel.textColor = UIColor.label
        forwardLabel.textColor = UIColor.label
        skipLabel.textColor = UIColor.label
        pauseLabel.textColor = UIColor.label
    }
}

extension GameMenuViewController: MenuViewDelegate {

    func reset(location: CGPoint) {
        DispatchQueue.main.async { [unowned self] in
            if location.x < forwardLabel.frame.origin.x {
                backLabel.backgroundColor = buttonColor
                backLabel.textColor = UIColor.label

            } else if location.x < skipLabel.frame.origin.x {
                forwardLabel.backgroundColor = buttonColor
                forwardLabel.textColor = UIColor.label

            } else if location.x <= skipLabel.frame.origin.x + skipLabel.frame.width {
                skipLabel.backgroundColor = buttonColor
                skipLabel.textColor = UIColor.label

            } else if location.x >= pauseLabel.frame.origin.x {
                pauseLabel.backgroundColor = buttonColor
                pauseLabel.textColor = UIColor.label

            } else {
                os_log(.debug, "touch outise buttons area: %@", location.debugDescription)
            }
        }
    }

    func highlight(location: CGPoint) {
        DispatchQueue.main.async { [unowned self] in
            if location.x < forwardLabel.frame.origin.x {
                if backLabel.isEnabled {
                    backLabel.backgroundColor = view.tintColor
                    backLabel.textColor = UIColor.lightText
                }

            } else if location.x < skipLabel.frame.origin.x {
                if forwardLabel.isEnabled {
                    forwardLabel.backgroundColor = view.tintColor
                    forwardLabel.textColor = UIColor.lightText
                }

            } else if location.x <= skipLabel.frame.origin.x + skipLabel.frame.width {
                if skipLabel.isEnabled {
                    skipLabel.backgroundColor = view.tintColor
                    skipLabel.textColor = UIColor.lightText
                }

            } else if location.x >= pauseLabel.frame.origin.x {
                if pauseLabel.isEnabled {
                    pauseLabel.backgroundColor = view.tintColor
                    pauseLabel.textColor = UIColor.lightText
                }

            } else {
                os_log(.debug, "touch outise buttons area: %@", location.debugDescription)
            }
        }
    }

    func handleTouch(location: CGPoint) {
        DispatchQueue.main.async { [unowned self] in
            if location.x < forwardLabel.frame.origin.x {
                if backLabel.isEnabled {
                    backLabel.backgroundColor = buttonColor
                    backLabel.textColor = UIColor.label
                    delelgate?.presentPreviousScreen()
                }
            } else if location.x < skipLabel.frame.origin.x {
                if forwardLabel.isEnabled {
                    forwardLabel.backgroundColor = buttonColor
                    forwardLabel.textColor = UIColor.label
                    delelgate?.presentNextScreen()
                }
            } else if location.x <= skipLabel.frame.origin.x + skipLabel.frame.width {
                if skipLabel.isEnabled  {
                    skipLabel.backgroundColor = buttonColor
                    skipLabel.textColor = UIColor.label
                    delelgate?.skip()
                }
            } else if location.x >= pauseLabel.frame.origin.x {
                if pauseLabel.isEnabled {
                    pauseLabel.backgroundColor = buttonColor
                    pauseLabel.textColor = UIColor.label
                    delelgate?.presentPause()
                }
            } else {
                os_log(.debug, "touch outise buttons area: %@", location.debugDescription)
            }
        }
    }
}
