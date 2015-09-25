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
		
		switch model.data.selectedGame {
		case 0:
			if model.data.visSearchDifficulty.integerValue == 0 {
				speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) seconds"
			} else {
				speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) seconds"
			}
		case 3:
			speedLabel.text = "\(model.data.visSustSpeed.doubleValue) seconds"
		default:
			break
		}
	}
	
	func dataLoaded() {
		
		switch model.data.selectedGame {
		case 0:
			if model.data.visSearchDifficulty.integerValue == 0 {
				speedStepper.value = model.data.visSearchSpeed.doubleValue
				speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) seconds"
			} else {
				speedStepper.value = model.data.visSearchSpeedHard.doubleValue
				speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) seconds"
			}
		case 3:
			speedStepper.value = model.data.visSustSpeed.doubleValue
			speedLabel.text = "\(model.data.visSustSpeed.doubleValue) seconds"
		default:
			break
		}
		
		changePlayerButton.title = model.data.selectedPlayer.name
	}
	
	@IBAction func difficultyControlHandler(sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 0 {
			model.data.visSearchDifficulty = 0
			speedStepper.value = model.data.visSearchSpeed.doubleValue
			speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) seconds"
		} else {
			model.data.visSearchDifficulty = 1
			speedStepper.value = model.data.visSearchSpeedHard.doubleValue
			speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) seconds"
		}
	}
	
	@IBAction func speedStepperHandler(sender: UIStepper) {
		if model.data.selectedGame == 0 {
			if model.data.visSearchDifficulty.integerValue == 0 {
				model.data.visSearchSpeed = sender.value
				speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) seconds"
			} else {
				model.data.visSearchSpeedHard = sender.value
				speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) seconds"
			}
		} else if model.data.selectedGame == 3 {
			model.data.visSustSpeed = sender.value
			speedLabel.text = "\(model.data.visSustSpeed.doubleValue) seconds"
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
