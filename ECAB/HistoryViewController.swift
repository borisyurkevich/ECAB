//
//  HistoryViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    let textView = UITextView()
    let helpMessage = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureViewHierarchy()
        resetSelectionPrompt()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetSelectionPrompt()
    }

    func resetSelectionPrompt() {
        textView.text = ""
        helpMessage.text = "Select any session from the left."
    }

    private func configureViewHierarchy() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        helpMessage.translatesAutoresizingMaskIntoConstraints = false

        textView.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
        textView.isEditable = false
        textView.contentInsetAdjustmentBehavior = .automatic

        helpMessage.numberOfLines = 0
        helpMessage.textAlignment = .center
        helpMessage.textColor = .secondaryLabel
        helpMessage.font = .preferredFont(forTextStyle: .headline)

        view.addSubview(textView)
        view.addSubview(helpMessage)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            helpMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            helpMessage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            helpMessage.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            helpMessage.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24)
        ])
    }
}
