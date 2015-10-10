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
	@IBOutlet weak var gameTitleCenter: UILabel!
	@IBOutlet weak var gameIcon: UIImageView!
	@IBOutlet weak var difControl: UISegmentedControl!
	@IBOutlet weak var speedLabel: UILabel!
	@IBOutlet weak var speedStepper: UIStepper!
	@IBOutlet weak var secondSpeedStepper: UIStepper!
	@IBOutlet weak var secondSpeedLabel: UILabel!
	@IBOutlet weak var speedLabelDescription: UILabel!
	@IBOutlet weak var secondSpeedLabelDescription: UILabel!

	
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
		switch game {
		case .VisualSearch:
			gameIcon.image = UIImage(named: "red_apple")
			difControl.hidden = false
			speedLabel.hidden = false
			speedStepper.hidden = false
			secondSpeedLabel.hidden = true
			secondSpeedStepper.hidden = true
			secondSpeedLabelDescription.hidden = true
			speedLabelDescription.hidden = false
			
			if model.data.visSearchDifficulty.integerValue == 0 {
				speedStepper.value = model.data.visSearchSpeed.doubleValue
				speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
			} else {
				speedStepper.value = model.data.visSearchSpeedHard.doubleValue
				speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
			}
			if model.data.visSearchDifficulty.integerValue == 0 {
				speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
			} else {
				speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
			}
			
		case .Flanker:
			gameIcon.image = UIImage(named: "fish")
			difControl.hidden = true
			speedLabel.hidden = true
			speedStepper.hidden = true
			secondSpeedLabel.hidden = true
			secondSpeedStepper.hidden = true
			secondSpeedLabelDescription.hidden = true
			speedLabelDescription.hidden = true
		case .Counterpointing:
			gameIcon.image = UIImage(named: "dog")
			difControl.hidden = true
			speedLabel.hidden = true
			speedStepper.hidden = true
			secondSpeedLabel.hidden = true
			secondSpeedStepper.hidden = true
			secondSpeedLabelDescription.hidden = true
			speedLabelDescription.hidden = true
		case .VisualSust:
			gameIcon.image = UIImage(named: "pig")
			difControl.hidden = true
			speedLabel.hidden = false
			speedStepper.hidden = false
			secondSpeedLabel.hidden = false
			secondSpeedStepper.hidden = false
			secondSpeedLabelDescription.hidden = false
			speedLabelDescription.hidden = false
			
			speedStepper.value = model.data.visSustSpeed.doubleValue
			speedLabel.text = "\(model.data.visSustSpeed.doubleValue) \(MenuConstants.second)"
			
			speedLabel.text = "\(model.data.visSustSpeed.doubleValue) \(MenuConstants.second)"
			secondSpeedLabel.text = "\(model.data.visSustAcceptedDelay!.doubleValue) \(MenuConstants.second)"
		}
	}
	
	@IBAction func difficultyControlHandler(sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == GamesIndex.VisualSearch.rawValue {
			model.data.visSearchDifficulty = 0
			speedStepper.value = model.data.visSearchSpeed.doubleValue
			speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
		} else {
			model.data.visSearchDifficulty = 1
			speedStepper.value = model.data.visSearchSpeedHard.doubleValue
			speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
		}
	}
	
	@IBAction func speedStepperHandler(sender: UIStepper) {
		if model.data.selectedGame == GamesIndex.VisualSearch.rawValue {
			if model.data.visSearchDifficulty.integerValue == 0 {
				model.data.visSearchSpeed = sender.value
				speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
			} else {
				model.data.visSearchSpeedHard = sender.value
				speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
			}
		} else if model.data.selectedGame == 3 {
			model.data.visSustSpeed = sender.value
			speedLabel.text = "\(model.data.visSustSpeed.doubleValue) \(MenuConstants.second)"
		}
	}

    // MARK: - Navigation

    @IBAction func playButtonHandler(sender: UIBarButtonItem) {
        
        if let detailVC: UISplitViewController = splitViewController {
			
			switch title! {
			case model.titles.visual:
				let gameVC = VisualSearch()
				detailVC.presentViewController(gameVC, animated: true, completion: nil)
			case model.titles.counterpointing:
				let gameVC = CounterpointingViewController()
				detailVC.presentViewController(gameVC, animated: true, completion: nil)
			case model.titles.flanker:
				let gameVC = FlankerViewController()
				detailVC.presentViewController(gameVC, animated: true, completion: nil)
			case model.titles.visualSust:
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
