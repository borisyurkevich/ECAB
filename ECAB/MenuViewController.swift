//
//  ECABApplesViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController, SubjectPickerDelegate, UIPopoverPresentationControllerDelegate
{
	var managedContext: NSManagedObjectContext!
    
    @IBOutlet weak var changePlayerButton: UIBarButtonItem!
	@IBOutlet weak var gameIcon: UIImageView!
	@IBOutlet weak var difControl: UISegmentedControl!
	@IBOutlet weak var speedLabel: UILabel!
	@IBOutlet weak var speedStepper: UIStepper!
	@IBOutlet weak var secondSpeedStepper: UIStepper!
	@IBOutlet weak var secondSpeedLabel: UILabel!
	@IBOutlet weak var speedLabelDescription: UILabel!
	@IBOutlet weak var secondSpeedLabelDescription: UILabel!
	@IBOutlet weak var periodValue: UILabel!
	@IBOutlet weak var periodControl: UIStepper!
	@IBOutlet weak var periodTitle: UILabel!
	@IBOutlet weak var periodHelp: UILabel!
	@IBOutlet weak var difficultyTitle: UILabel!
    @IBOutlet weak var randmomizeFlanker: UISwitch!
    @IBOutlet weak var randomizeLabel: UILabel!
	
    let model: Model = Model.sharedInstance
    
    fileprivate struct Segues {
        static let startApplesGame = "Start apples game"
        static let openSubjectsPopover = "Open subjects popover"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		changePlayerButton.title = "Loading..."
		// Subscribe from notifications from Model
		NotificationCenter.default.addObserver(self, selector: #selector(MenuViewController.dataLoaded), name: NSNotification.Name(rawValue: "dataLoaded"), object: nil)
		model.setupWithContext(managedContext)
		
		difControl.selectedSegmentIndex = model.data.visSearchDifficulty.intValue
        randmomizeFlanker.isOn = UserDefaults.standard.bool(forKey: "isFlankerRandmoized")
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
            difficultyTitle.isHidden = false
			difControl.isHidden = false
			speedLabel.isHidden = false
			speedLabelDescription.isHidden = false
			
			speedStepper.isHidden = false
			secondSpeedLabel.isHidden = true
			secondSpeedStepper.isHidden = true
			secondSpeedLabelDescription.isHidden = true
			
			// Third Control
			periodControl.isHidden = true
			periodTitle.isHidden = true
			periodHelp.isHidden = true
			periodValue.isHidden = true
            
            randmomizeFlanker.isHidden = true
            randomizeLabel.isHidden = true
			
			
			if model.data.visSearchDifficulty.intValue == 0 {
				speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
				speedStepper.value = model.data.visSustSpeed.doubleValue
			} else {
				speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
				speedStepper.value = model.data.visSearchSpeedHard.doubleValue
			}
			
		case .flanker:
			gameIcon.image = UIImage(named: "menu_fish")
			
			difficultyTitle.isHidden = true
			difControl.isHidden = true
			
			speedLabel.isHidden = true
			speedStepper.isHidden = true
			
			secondSpeedLabel.isHidden = true
			secondSpeedStepper.isHidden = true
			secondSpeedLabelDescription.isHidden = true
			speedLabelDescription.isHidden = true
			
			// Third Control
			periodControl.isHidden = true
			periodTitle.isHidden = true
			periodHelp.isHidden = true
			periodValue.isHidden = true
            
            randmomizeFlanker.isHidden = false
            randomizeLabel.isHidden = false
			
		case .counterpointing:
			gameIcon.image = UIImage(named: "menu_dog")
			
			difficultyTitle.isHidden = true
			difControl.isHidden = true
			
			speedLabel.isHidden = true
			speedStepper.isHidden = true
			secondSpeedLabel.isHidden = true
			secondSpeedStepper.isHidden = true
			secondSpeedLabelDescription.isHidden = true
			speedLabelDescription.isHidden = true
			
			// Third Control
			periodControl.isHidden = true
			periodTitle.isHidden = true
			periodHelp.isHidden = true
			periodValue.isHidden = true
            
            randmomizeFlanker.isHidden = true
            randomizeLabel.isHidden = true
			
		case .visualSust:
			gameIcon.image = UIImage(named: "menu_pig")
			
			difficultyTitle.isHidden = true
			difControl.isHidden = true
			
			speedLabel.isHidden = false
			speedStepper.isHidden = false
			secondSpeedLabel.isHidden = false
			secondSpeedStepper.isHidden = false
			secondSpeedLabelDescription.isHidden = false
			speedLabelDescription.isHidden = false
			
			periodControl.isHidden = false
			periodTitle.isHidden = false
			periodHelp.isHidden = false
			periodValue.isHidden = false
            
            randmomizeFlanker.isHidden = true
            randomizeLabel.isHidden = true
			
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
	
	@IBAction func difficultyControlHandler(_ sender: UISegmentedControl) {
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
	
	@IBAction func speedStepperHandler(_ sender: UIStepper) {
		
		let formattedValue = NSString(format: "%.01f", sender.value)
		let newSpeedValueDouble = Double(formattedValue as String)!
		
		if model.data.selectedGame == GamesIndex.visualSearch.rawValue {
			if model.data.visSearchDifficulty == Difficulty.easy.rawValue{ 
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

	@IBAction func delayHandler(_ sender: UIStepper) {

		let formattedValue = NSString(format: "%.01f", sender.value)
		let number = Double(formattedValue as String)
		secondSpeedLabel.text = "\(formattedValue) \(MenuConstants.second)"
		
		model.data.visSustAcceptedDelay = number as NSNumber?
		model.save()
	}
	
	@IBAction func totalPeriodHandler(_ sender: UIStepper) {
		
		let newTotalPeriod = NSString(format: "%.01f", sender.value)
		let newTotalPeriodDouble = Double(newTotalPeriod as String)
		let exposure = model.data.visSustSpeed.doubleValue
		let newDelay = newTotalPeriodDouble! - exposure
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
    
    @IBAction func randomizedFlanker(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "isFlankerRandmoized")
    }
	
	func validateAndHighliteBlankSpaceLabel() {
		let currentDelay = model.data.visSustDelay.doubleValue
		if currentDelay < model.kMinDelay {
			periodHelp.text = "Blank space time: \(currentDelay) \(MenuConstants.second) Ignored when less than a second"
			periodHelp.textColor = UIColor.red
		}
	}
	
    // MARK: - Navigation

    @IBAction func playButtonHandler(_ sender: UIBarButtonItem) {
        
        if let detailVC: UISplitViewController = splitViewController {
			
			switch title! {
			case GameTitle.visual:
				let gameVC = VisualSearchViewController()
                gameVC.modalPresentationStyle = .fullScreen
				detailVC.present(gameVC, animated: true, completion: nil)
			case GameTitle.counterpointing:
				let gameVC = CounterpointingViewController()
                gameVC.modalPresentationStyle = .fullScreen
				detailVC.present(gameVC, animated: true, completion: nil)
			case GameTitle.flanker:
				let gameVC = FlankerViewController()
                gameVC.modalPresentationStyle = .fullScreen
				
				let alert = UIAlertController(title: "Small Images.", message: "Enable small images?", preferredStyle:.alert)
				let okayAction = UIAlertAction(title: "Classic images (2x)", style: .default, handler: { (alertAction) -> Void in
					detailVC.present(gameVC, animated: true, completion: nil)
				})
				let smallImageAction = UIAlertAction(title: "Smaller images (1.5x)", style: .cancel, handler: { (alertAction) -> Void in
					gameVC.smallImages = true
					detailVC.present(gameVC, animated: true, completion: nil)
				})
				alert.addAction(okayAction)
				alert.addAction(smallImageAction)
				
				self.present(alert, animated: true, completion: nil)
				
			case GameTitle.visualSust:
				let gameVC = VisualSustainViewController()
                gameVC.modalPresentationStyle = .fullScreen
                
				detailVC.present(gameVC, animated: true, completion: nil)
			default:
				let gameVC = VisualSearchViewController()
                gameVC.modalPresentationStyle = .fullScreen
                
				detailVC.present(gameVC, animated: true, completion: nil)
			}
		}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case Segues.openSubjectsPopover:
                if let tvc = segue.destination as? PlayersTableViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self;
                    }
                    tvc.delegate = self
                }
            case Segues.startApplesGame:
                if let cvc = segue.destination as? VisualSearchViewController {
                    cvc.presenter = self
                }
            default: break;
            }
        }
    }
    
    // MARK: <SubjectPickerDelegate>
    
    func pickSubject() {
        changePlayerButton.title = model.data.selectedPlayer.name
    }
}
