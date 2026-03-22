//
//  ECABApplesViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController, SubjectPickerDelegate, UIPopoverPresentationControllerDelegate {

    var managedContext: NSManagedObjectContext

    private let changePlayerButton = UIBarButtonItem(title: "Player", style: .plain, target: nil, action: nil)
    private let playButton = UIBarButtonItem(title: "Play", style: .done, target: nil, action: nil)

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let gameIcon = UIImageView()
    private let difficultyTitle = UILabel()
    private let difControl = UISegmentedControl(items: ["Easy", "Hard"])
    private let speedLabelDescription = UILabel()
    private let speedLabel = UILabel()
    private let speedStepper = UIStepper()
    private let secondSpeedLabelDescription = UILabel()
    private let secondSpeedLabel = UILabel()
    private let secondSpeedStepper = UIStepper()
    private let periodTitle = UILabel()
    private let periodValue = UILabel()
    private let periodControl = UIStepper()
    private let periodHelp = UILabel()
    private let randomizeLabel = UILabel()
    private let randmomizeFlanker = UISwitch()

    private let model: Model = Model.sharedInstance

    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViewHierarchy()
        configureNavigationItems()
        configureControls()

        changePlayerButton.title = "Loading..."
        NotificationCenter.default.addObserver(self, selector: #selector(dataLoaded), name: Notification.Name(rawValue: "dataLoaded"), object: nil)
        if model.data == nil {
            model.setupWithContext(managedContext)
        } else {
            dataLoaded()
        }

        difControl.selectedSegmentIndex = model.data.visSearchDifficulty.intValue
        randmomizeFlanker.isOn = UserDefaults.standard.bool(forKey: "isFlankerRandmoized")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func dataLoaded() {
        switch model.data.selectedGame {
        case GamesIndex.visualSearch.rawValue:
            showTheGame(.visualSearch)
        case GamesIndex.visualSust.rawValue:
            showTheGame(.visualSust)
        case GamesIndex.flanker.rawValue:
            showTheGame(.flanker)
        case GamesIndex.counterpointing.rawValue:
            showTheGame(.counterpointing)
        default:
            break
        }

        changePlayerButton.title = model.data.selectedPlayer.name
    }

    func showTheGame(_ game: GamesIndex) {
        let currentTitle = model.games[model.data.selectedGame.intValue]
        title = currentTitle

        switch game {
        case .visualSearch:
            gameIcon.image = UIImage(named: "menu_red_apple")
            setHidden(false, views: [difficultyTitle, difControl, speedLabel, speedLabelDescription, speedStepper])
            setHidden(true, views: [secondSpeedLabel, secondSpeedStepper, secondSpeedLabelDescription, periodControl, periodTitle, periodHelp, periodValue, randmomizeFlanker, randomizeLabel])

            if model.data.visSearchDifficulty.intValue == 0 {
                speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
                speedStepper.value = model.data.visSearchSpeed.doubleValue
            } else {
                speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
                speedStepper.value = model.data.visSearchSpeedHard.doubleValue
            }

        case .flanker:
            gameIcon.image = UIImage(named: "menu_fish")
            setHidden(true, views: [difficultyTitle, difControl, speedLabel, speedLabelDescription, speedStepper, secondSpeedLabel, secondSpeedStepper, secondSpeedLabelDescription, periodControl, periodTitle, periodHelp, periodValue])
            setHidden(false, views: [randmomizeFlanker, randomizeLabel])

        case .counterpointing:
            gameIcon.image = UIImage(named: "menu_dog")
            setHidden(true, views: [difficultyTitle, difControl, speedLabel, speedLabelDescription, speedStepper, secondSpeedLabel, secondSpeedStepper, secondSpeedLabelDescription, periodControl, periodTitle, periodHelp, periodValue, randmomizeFlanker, randomizeLabel])

        case .visualSust:
            gameIcon.image = UIImage(named: "menu_pig")
            setHidden(true, views: [difficultyTitle, difControl, randmomizeFlanker, randomizeLabel])
            setHidden(false, views: [speedLabel, speedLabelDescription, speedStepper, secondSpeedLabel, secondSpeedStepper, secondSpeedLabelDescription, periodControl, periodTitle, periodHelp, periodValue])

            speedStepper.value = model.data.visSustSpeed.doubleValue
            speedLabel.text = "\(model.data.visSustSpeed.doubleValue) \(MenuConstants.second)"

            secondSpeedLabel.text = "\(model.data.visSustAcceptedDelay!.doubleValue) \(MenuConstants.second)"
            secondSpeedStepper.value = model.data.visSustAcceptedDelay!.doubleValue

            let exposure = model.data.visSustSpeed.doubleValue
            let delay = model.data.visSustDelay.doubleValue
            let totalPeriod = exposure + delay
            periodControl.value = totalPeriod
            periodValue.text = "\(totalPeriod) \(MenuConstants.second)"
            periodHelp.text = "Blank space time: \(delay) \(MenuConstants.second)"

            validateAndHighliteBlankSpaceLabel()
        }
    }

    @objc func difficultyControlHandler(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == Difficulty.easy.rawValue.intValue {
            model.data.visSearchDifficulty = Difficulty.easy.rawValue
            speedStepper.value = model.data.visSearchSpeed.doubleValue
            speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
        } else {
            model.data.visSearchDifficulty = Difficulty.hard.rawValue
            speedStepper.value = model.data.visSearchSpeedHard.doubleValue
            speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
        }

        model.save()
    }

    @objc func speedStepperHandler(_ sender: UIStepper) {
        let formattedValue = NSString(format: "%.01f", sender.value)
        let newSpeedValueDouble = Double(formattedValue as String) ?? sender.value

        if model.data.selectedGame == GamesIndex.visualSearch.rawValue {
            if model.data.visSearchDifficulty == Difficulty.easy.rawValue {
                model.data.visSearchSpeed = NSNumber(value: newSpeedValueDouble)
            } else {
                model.data.visSearchSpeedHard = NSNumber(value: newSpeedValueDouble)
            }
        } else if model.data.selectedGame == GamesIndex.visualSust.rawValue {
            model.data.visSustSpeed = NSNumber(value: newSpeedValueDouble)

            let delay = model.data.visSustDelay.doubleValue
            let newTotal = newSpeedValueDouble + delay
            periodValue.text = "\(newTotal) \(MenuConstants.second)"
            periodControl.value = newTotal
        }

        speedLabel.text = "\(formattedValue) \(MenuConstants.second)"
        model.save()
    }

    @objc func delayHandler(_ sender: UIStepper) {
        let formattedValue = NSString(format: "%.01f", sender.value)
        let number = Double(formattedValue as String)
        secondSpeedLabel.text = "\(formattedValue) \(MenuConstants.second)"

        model.data.visSustAcceptedDelay = number as NSNumber?
        model.save()
    }

    @objc func totalPeriodHandler(_ sender: UIStepper) {
        let newTotalPeriod = NSString(format: "%.01f", sender.value)
        let newTotalPeriodDouble = Double(newTotalPeriod as String) ?? sender.value
        let exposure = model.data.visSustSpeed.doubleValue
        let newDelay = newTotalPeriodDouble - exposure
        periodValue.text = "\(newTotalPeriod) \(MenuConstants.second)"

        if newDelay >= model.kMinDelay {
            periodHelp.text = "Blank space time: \(newDelay) \(MenuConstants.second)"
            periodHelp.textColor = UIColor.darkGray
            model.data.visSustDelay = NSNumber(value: newDelay)
        } else {
            periodHelp.text = "Blank space time: 0 \(MenuConstants.second) Ignored when less than a second"
            periodHelp.textColor = UIColor.red
            model.data.visSustDelay = 0.0
        }
        model.save()
    }

    @objc func randomizedFlanker(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isFlankerRandmoized")
    }

    func validateAndHighliteBlankSpaceLabel() {
        let currentDelay = model.data.visSustDelay.doubleValue
        if currentDelay < model.kMinDelay {
            periodHelp.text = "Blank space time: \(currentDelay) \(MenuConstants.second) Ignored when less than a second"
            periodHelp.textColor = UIColor.red
        }
    }

    @objc func playButtonHandler(_ sender: UIBarButtonItem) {
        guard let presenter = splitViewController ?? navigationController ?? self.presentingViewController else {
            return
        }

        switch model.data.selectedGame {
        case GamesIndex.visualSearch.rawValue:
            let gameVC = VisualSearchViewController()
            gameVC.modalPresentationStyle = .fullScreen
            presenter.present(gameVC, animated: true)
        case GamesIndex.counterpointing.rawValue:
            let gameVC = CounterpointingViewController()
            gameVC.modalPresentationStyle = .fullScreen
            presenter.present(gameVC, animated: true)
        case GamesIndex.flanker.rawValue:
            let gameVC = FlankerViewController()
            gameVC.modalPresentationStyle = .fullScreen

            let alert = UIAlertController(title: "Small Images.", message: "Enable small images?", preferredStyle: .alert)
            let okayAction = UIAlertAction(title: "Classic images (2x)", style: .default) { _ in
                presenter.present(gameVC, animated: true)
            }
            let smallImageAction = UIAlertAction(title: "Smaller images (1.5x)", style: .cancel) { _ in
                gameVC.smallImages = true
                presenter.present(gameVC, animated: true)
            }
            alert.addAction(okayAction)
            alert.addAction(smallImageAction)
            present(alert, animated: true)
        case GamesIndex.visualSust.rawValue:
            let gameVC = VisualSustainViewController()
            gameVC.modalPresentationStyle = .fullScreen
            presenter.present(gameVC, animated: true)
        default:
            let gameVC = VisualSearchViewController()
            gameVC.modalPresentationStyle = .fullScreen
            presenter.present(gameVC, animated: true)
        }
    }

    @objc private func presentPlayersPopover() {
        let playersController = PlayersTableViewController(style: .plain)
        playersController.delegate = self
        playersController.modalPresentationStyle = .popover
        playersController.preferredContentSize = CGSize(width: 320, height: 320)

        if let popover = playersController.popoverPresentationController {
            popover.barButtonItem = changePlayerButton
            popover.delegate = self
            popover.permittedArrowDirections = .any
        }

        present(playersController, animated: true)
    }

    func pickSubject() {
        changePlayerButton.title = model.data.selectedPlayer.name
        presentedViewController?.dismiss(animated: true)
    }

    private func configureViewHierarchy() {
        view.backgroundColor = .systemBackground

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        gameIcon.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 18
        contentStack.alignment = .fill

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24)
        ])

        gameIcon.contentMode = .scaleAspectFit
        gameIcon.heightAnchor.constraint(equalToConstant: 160).isActive = true

        difficultyTitle.text = "Difficulty"
        speedLabelDescription.text = "Exposure"
        secondSpeedLabelDescription.text = "Accepted Delay"
        periodTitle.text = "Total Period"
        randomizeLabel.text = "Randomize Flanker"
        periodHelp.numberOfLines = 0

        speedLabel.font = .preferredFont(forTextStyle: .title3)
        secondSpeedLabel.font = .preferredFont(forTextStyle: .title3)
        periodValue.font = .preferredFont(forTextStyle: .title3)

        contentStack.addArrangedSubview(gameIcon)
        contentStack.addArrangedSubview(makeSection(titleLabel: difficultyTitle, control: difControl))
        contentStack.addArrangedSubview(makeSection(titleLabel: speedLabelDescription, detailLabel: speedLabel, control: speedStepper))
        contentStack.addArrangedSubview(makeSection(titleLabel: secondSpeedLabelDescription, detailLabel: secondSpeedLabel, control: secondSpeedStepper))
        contentStack.addArrangedSubview(makeSection(titleLabel: periodTitle, detailLabel: periodValue, control: periodControl))
        contentStack.addArrangedSubview(periodHelp)
        contentStack.addArrangedSubview(makeToggleRow(titleLabel: randomizeLabel, control: randmomizeFlanker))
    }

    private func configureNavigationItems() {
        changePlayerButton.target = self
        changePlayerButton.action = #selector(presentPlayersPopover)
        playButton.target = self
        playButton.action = #selector(playButtonHandler(_:))

        navigationItem.leftBarButtonItem = changePlayerButton
        navigationItem.rightBarButtonItem = playButton
    }

    private func configureControls() {
        difControl.addTarget(self, action: #selector(difficultyControlHandler(_:)), for: .valueChanged)

        speedStepper.minimumValue = 0.1
        speedStepper.maximumValue = 60
        speedStepper.stepValue = 0.1
        speedStepper.addTarget(self, action: #selector(speedStepperHandler(_:)), for: .valueChanged)

        secondSpeedStepper.minimumValue = 0.1
        secondSpeedStepper.maximumValue = 60
        secondSpeedStepper.stepValue = 0.1
        secondSpeedStepper.addTarget(self, action: #selector(delayHandler(_:)), for: .valueChanged)

        periodControl.minimumValue = 0.1
        periodControl.maximumValue = 120
        periodControl.stepValue = 0.1
        periodControl.addTarget(self, action: #selector(totalPeriodHandler(_:)), for: .valueChanged)

        randmomizeFlanker.addTarget(self, action: #selector(randomizedFlanker(_:)), for: .valueChanged)
    }

    private func makeSection(titleLabel: UILabel, detailLabel: UILabel? = nil, control: UIView) -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 8

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.alignment = .center

        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        topRow.addArrangedSubview(titleLabel)

        if let detailLabel = detailLabel {
            detailLabel.textAlignment = .right
            detailLabel.setContentHuggingPriority(.required, for: .horizontal)
            topRow.addArrangedSubview(detailLabel)
        }

        container.addArrangedSubview(topRow)
        container.addArrangedSubview(control)
        return container
    }

    private func makeToggleRow(titleLabel: UILabel, control: UIView) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 16
        row.addArrangedSubview(titleLabel)
        row.addArrangedSubview(control)
        return row
    }

    private func setHidden(_ hidden: Bool, views: [UIView]) {
        views.forEach { $0.isHidden = hidden }
    }
}
