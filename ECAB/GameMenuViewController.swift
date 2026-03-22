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

    private let menuView = MenuView()
    private let backLabel = UILabel()
    private let forwardLabel = UILabel()
    private let skipLabel = UILabel()
    private let pauseLabel = UILabel()

    private let borderWidth: CGFloat = 1.0
    private let borderColor: CGColor = UIColor.darkGray.cgColor
    private var buttonColor: UIColor?
    private var activity: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
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

        if #available(iOS 13.0, *) {
            activity = UIActivityIndicatorView(style: .medium)
        } else {
            activity = UIActivityIndicatorView(style: .gray)
        }

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
        pauseLabel.text = "Pause"
        pauseLabel.textColor = backwardCompatibleLabelColor
    }

    private var backwardCompatibleLabelColor: UIColor {
        UIColor.darkText
    }

    private func configureViewHierarchy() {
        view.backgroundColor = .clear
        view.tag = 10

        menuView.translatesAutoresizingMaskIntoConstraints = false
        menuView.backgroundColor = .secondarySystemBackground

        view.addSubview(menuView)

        NSLayoutConstraint.activate([
            menuView.topAnchor.constraint(equalTo: view.topAnchor),
            menuView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            menuView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            menuView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        let labels = [backLabel, forwardLabel, skipLabel, pauseLabel]
        let titles = ["Back", "Next", "Skip", "Pause"]

        for (index, label) in labels.enumerated() {
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = titles[index]
            label.textAlignment = .center
            label.backgroundColor = .systemBackground
            label.font = .preferredFont(forTextStyle: .headline)
            menuView.addSubview(label)
        }

        NSLayoutConstraint.activate([
            backLabel.topAnchor.constraint(equalTo: menuView.topAnchor),
            backLabel.leadingAnchor.constraint(equalTo: menuView.leadingAnchor),
            backLabel.bottomAnchor.constraint(equalTo: menuView.bottomAnchor),

            forwardLabel.topAnchor.constraint(equalTo: menuView.topAnchor),
            forwardLabel.leadingAnchor.constraint(equalTo: backLabel.trailingAnchor),
            forwardLabel.bottomAnchor.constraint(equalTo: menuView.bottomAnchor),
            forwardLabel.widthAnchor.constraint(equalTo: backLabel.widthAnchor),

            skipLabel.topAnchor.constraint(equalTo: menuView.topAnchor),
            skipLabel.leadingAnchor.constraint(equalTo: forwardLabel.trailingAnchor),
            skipLabel.bottomAnchor.constraint(equalTo: menuView.bottomAnchor),
            skipLabel.widthAnchor.constraint(equalTo: backLabel.widthAnchor),

            pauseLabel.topAnchor.constraint(equalTo: menuView.topAnchor),
            pauseLabel.leadingAnchor.constraint(equalTo: skipLabel.trailingAnchor),
            pauseLabel.trailingAnchor.constraint(equalTo: menuView.trailingAnchor),
            pauseLabel.bottomAnchor.constraint(equalTo: menuView.bottomAnchor),
            pauseLabel.widthAnchor.constraint(equalTo: backLabel.widthAnchor)
        ])
    }

    private func addMenuBorders() {
        [backLabel, forwardLabel, skipLabel, pauseLabel].forEach {
            $0.layer.borderWidth = borderWidth
            $0.layer.borderColor = borderColor
        }
    }

    private func setTextColor() {
        backLabel.textColor = backwardCompatibleLabelColor
        forwardLabel.textColor = backwardCompatibleLabelColor
        skipLabel.textColor = backwardCompatibleLabelColor
        pauseLabel.textColor = backwardCompatibleLabelColor
    }
}

extension GameMenuViewController: MenuViewDelegate {

    func reset(location: CGPoint) {
        DispatchQueue.main.async { [unowned self] in
            if location.x < forwardLabel.frame.origin.x {
                backLabel.backgroundColor = buttonColor
                backLabel.textColor = backwardCompatibleLabelColor
            } else if location.x < skipLabel.frame.origin.x {
                forwardLabel.backgroundColor = buttonColor
                forwardLabel.textColor = backwardCompatibleLabelColor
            } else if location.x <= skipLabel.frame.origin.x + skipLabel.frame.width {
                skipLabel.backgroundColor = buttonColor
                skipLabel.textColor = backwardCompatibleLabelColor
            } else if location.x >= pauseLabel.frame.origin.x {
                pauseLabel.backgroundColor = buttonColor
                pauseLabel.textColor = backwardCompatibleLabelColor
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
                    backLabel.textColor = backwardCompatibleLabelColor
                    delelgate?.presentPreviousScreen()
                }
            } else if location.x < skipLabel.frame.origin.x {
                if forwardLabel.isEnabled {
                    forwardLabel.backgroundColor = buttonColor
                    forwardLabel.textColor = backwardCompatibleLabelColor
                    delelgate?.presentNextScreen()
                }
            } else if location.x <= skipLabel.frame.origin.x + skipLabel.frame.width {
                if skipLabel.isEnabled {
                    skipLabel.backgroundColor = buttonColor
                    skipLabel.textColor = backwardCompatibleLabelColor
                    delelgate?.skip()
                }
            } else if location.x >= pauseLabel.frame.origin.x {
                if pauseLabel.isEnabled {
                    pauseLabel.backgroundColor = buttonColor
                    pauseLabel.textColor = backwardCompatibleLabelColor
                    delelgate?.presentPause()
                }
            } else {
                os_log(.debug, "touch outise buttons area: %@", location.debugDescription)
            }
        }
    }
}
