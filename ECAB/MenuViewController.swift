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
	
    let model: Model = Model.sharedInstance
    
    private struct Segues {
        static let startApplesGame = "Start apples game"
        static let openSubjectsPopover = "Open subjects popover"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		changePlayerButton.title = "Loading..."
		// Subscribe from notifications from Model
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataLoaded", name: "dataLoaded", object: nil)
		model.setupWithContext(managedContext)
		
		difControl.selectedSegmentIndex = model.data.visSearchDifficulty.integerValue
	}
	
	func dataLoaded() {
		
		switch model.data.selectedGame {
		case GamesIndex.VisualSearch.rawValue:
			showTheGame(.VisualSearch)
		case GamesIndex.VisualSust.rawValue:
			showTheGame(.VisualSust)
		case GamesIndex.Flanker.rawValue:
			showTheGame(.Flanker)
		case GamesIndex.Counterpointing.rawValue:
			showTheGame(.Counterpointing)
		default:
			break
		}
		
		changePlayerButton.title = model.data.selectedPlayer.name
	}
	
	func showTheGame(game: GamesIndex) {
		
		let currentTitle = model.games[model.data.selectedGame.integerValue]
		title = currentTitle
		
		switch game {
		case .VisualSearch:
			gameIcon.image = UIImage(named: "red_apple")
			difControl.hidden = false
			speedLabel.hidden = false
			speedLabelDescription.hidden = false
			
			speedStepper.hidden = false
			secondSpeedLabel.hidden = true
			secondSpeedStepper.hidden = true
			secondSpeedLabelDescription.hidden = true
			
			// Third Control
			periodControl.hidden = true
			periodTitle.hidden = true
			periodHelp.hidden = true
			periodValue.hidden = true
			
			
			if model.data.visSearchDifficulty.integerValue == 0 {
				speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
				speedStepper.value = model.data.visSustSpeed.doubleValue
			} else {
				speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
				speedStepper.value = model.data.visSearchSpeedHard.doubleValue
			}
			
		case .Flanker:
			gameIcon.image = UIImage(named: "fish")
			
			difficultyTitle.hidden = true
			difControl.hidden = true
			
			speedLabel.hidden = true
			speedStepper.hidden = true
			
			secondSpeedLabel.hidden = true
			secondSpeedStepper.hidden = true
			secondSpeedLabelDescription.hidden = true
			speedLabelDescription.hidden = true
			
			// Third Control
			periodControl.hidden = true
			periodTitle.hidden = true
			periodHelp.hidden = true
			periodValue.hidden = true
			
		case .Counterpointing:
			gameIcon.image = UIImage(named: "dog")
			
			difficultyTitle.hidden = true
			difControl.hidden = true
			
			speedLabel.hidden = true
			speedStepper.hidden = true
			secondSpeedLabel.hidden = true
			secondSpeedStepper.hidden = true
			secondSpeedLabelDescription.hidden = true
			speedLabelDescription.hidden = true
			
			// Third Control
			periodControl.hidden = true
			periodTitle.hidden = true
			periodHelp.hidden = true
			periodValue.hidden = true
			
		case .VisualSust:
			gameIcon.image = UIImage(named: "pig")
			
			difficultyTitle.hidden = true
			difControl.hidden = true
			
			speedLabel.hidden = false
			speedStepper.hidden = false
			secondSpeedLabel.hidden = false
			secondSpeedStepper.hidden = false
			secondSpeedLabelDescription.hidden = false
			speedLabelDescription.hidden = false
			
			periodControl.hidden = false
			periodTitle.hidden = false
			periodHelp.hidden = false
			periodValue.hidden = false
			
			
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
	
	@IBAction func difficultyControlHandler(sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == Difficulty.Easy.rawValue {
			model.data.visSearchDifficulty = Difficulty.Easy.rawValue
			speedStepper.value = model.data.visSearchSpeed.doubleValue
			speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
		} else {
			model.data.visSearchDifficulty = Difficulty.Hard.rawValue
			speedStepper.value = model.data.visSearchSpeedHard.doubleValue
			speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
		}
		
		model.save()
	}
	
	@IBAction func speedStepperHandler(sender: UIStepper) {
		
		let formattedValue = NSString(format: "%.01f", sender.value)
		let newSpeedValueDouble = Double(formattedValue as String)!
		
		if model.data.selectedGame == GamesIndex.VisualSearch.rawValue {
			if model.data.visSearchDifficulty == Difficulty.Easy.rawValue{ 
				model.data.visSearchSpeed = newSpeedValueDouble
			} else {
				model.data.visSearchSpeedHard = newSpeedValueDouble
			}
		} else if model.data.selectedGame == GamesIndex.VisualSust.rawValue {
			model.data.visSustSpeed = newSpeedValueDouble
			
			let delay = model.data.visSustDelay.doubleValue
			let newTotal = newSpeedValueDouble + delay
			periodValue.text = "\(newTotal) \(MenuConstants.second)"
			periodControl.value = newTotal
		}
		
		speedLabel.text = "\(formattedValue) \(MenuConstants.second)"
		model.save()
	}

	@IBAction func delayHandler(sender: UIStepper) {

		let formattedValue = NSString(format: "%.01f", sender.value)
		let number = Double(formattedValue as String)
		secondSpeedLabel.text = "\(formattedValue) \(MenuConstants.second)"
		
		model.data.visSustAcceptedDelay = number
		model.save()
	}
	
	@IBAction func totalPeriodHandler(sender: UIStepper) {
		
		let newTotalPeriod = NSString(format: "%.01f", sender.value)
		let newTotalPeriodDouble = Double(newTotalPeriod as String)
		let exposure = model.data.visSustSpeed.doubleValue
		let newDelay = newTotalPeriodDouble! - exposure
		periodValue.text = "\(newTotalPeriod) \(MenuConstants.second)"
		
		if newDelay >= model.kMinDelay {
			periodHelp.text = "Blank space time: \(newDelay) \(MenuConstants.second)"
			periodHelp.textColor = UIColor.darkGrayColor()
			
			model.data.visSustDelay = newDelay
		} else {
			periodHelp.text = "Blank space time: 0 \(MenuConstants.second) Ignored when less than a second"
			periodHelp.textColor = UIColor.redColor()
			
			model.data.visSustDelay = 0.0
		}
		model.save()
	}
	
	func validateAndHighliteBlankSpaceLabel() {
		let currentDelay = model.data.visSustDelay.doubleValue
		if currentDelay < model.kMinDelay {
			periodHelp.text = "Blank space time: \(currentDelay) \(MenuConstants.second) Ignored when less than a second"
			periodHelp.textColor = UIColor.redColor()
		}
	}
	
    // MARK: - Navigation

    @IBAction func playButtonHandler(sender: UIBarButtonItem) {
        
        if let detailVC: UISplitViewController = splitViewController {
			
			switch title! {
			case GameTitle.visual:
				let gameVC = VisualSearch()
				detailVC.presentViewController(gameVC, animated: true, completion: nil)
			case GameTitle.counterpointing:
				let gameVC = CounterpointingViewController()
				detailVC.presentViewController(gameVC, animated: true, completion: nil)
			case GameTitle.flanker:
				let gameVC = FlankerViewController()
				
				let alert = UIAlertController(title: "Small Images.", message: "Enable small images?", preferredStyle:.Alert)
				let okayAction = UIAlertAction(title: "Classic images (2x)", style: .Default, handler: { (alertAction) -> Void in
					detailVC.presentViewController(gameVC, animated: true, completion: nil)
				})
				let smallImageAction = UIAlertAction(title: "Smaller images (1.5x)", style: .Cancel, handler: { (alertAction) -> Void in
					gameVC.smallImages = true
					detailVC.presentViewController(gameVC, animated: true, completion: nil)
				})
				alert.addAction(okayAction)
				alert.addAction(smallImageAction)
				
				self.presentViewController(alert, animated: true, completion: nil)
				
			case GameTitle.visualSust:
				let gameVC = VisualSustainViewController()
				detailVC.presentViewController(gameVC, animated: true, completion: nil)
			default:
				let gameVC = VisualSearch()
				detailVC.presentViewController(gameVC, animated: true, completion: nil)
			}
		}
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case Segues.openSubjectsPopover:
                if let tvc = segue.destinationViewController as? PlayersTableViewController {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self;
                    }
                    tvc.delegate = self
                }
            case Segues.startApplesGame:
                if let cvc = segue.destinationViewController as? VisualSearch {
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
