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
		
		model.setupWithContext(managedContext)
		
		changePlayerButton.title = "Pick a player"
		
		if model.data.selectedGame == 0 {
			if (model.visualSearchOnEasy) {
				speedStepper.value = model.visualSearchSpeedEasy
				speedLabel.text = "\(model.visualSearchSpeedEasy) seconds"
			} else {
				speedStepper.value = model.visualSearchSpeedHard
				speedLabel.text = "\(model.visualSearchSpeedHard) seconds"
			}
		} else if model.data.selectedGame == 3 {
			speedStepper.value = model.visualSustSpeed
			speedLabel.text = "\(model.visualSustSpeed) seconds"
		}
	}
	
	@IBAction func difficultyControlHandler(sender: UISegmentedControl) {
		if sender.selectedSegmentIndex == 0 {
			model.visualSearchOnEasy = true
			speedStepper.value = model.visualSearchSpeedEasy
			speedLabel.text = "\(model.visualSearchSpeedEasy) seconds"
		} else {
			model.visualSearchOnEasy = false
			speedStepper.value = model.visualSearchSpeedHard
			speedLabel.text = "\(model.visualSearchSpeedHard) seconds"
		}
	}
	
	@IBAction func speedStepperHandler(sender: UIStepper) {
		if model.data.selectedGame == 0 {
			if model.visualSearchOnEasy {
				model.visualSearchSpeedEasy = sender.value
				speedLabel.text = "\(model.visualSearchSpeedEasy) seconds"
			} else {
				model.visualSearchSpeedHard = sender.value
				speedLabel.text = "\(model.visualSearchSpeedHard) seconds"
			}
		} else if model.data.selectedGame == 3 {
			model.visualSustSpeed = sender.value
			speedLabel.text = "\(model.visualSustSpeed) seconds"
		}
	}

    // MARK: - Navigation

    @IBAction func playButtonHandler(sender: UIBarButtonItem) {
        
        if let detailVC: UISplitViewController = splitViewController {
			
			switch title! {
			case model.titles.visual:
				let flowLayout = UICollectionViewFlowLayout()
				let gameVC = RedAppleCollectionViewController(collectionViewLayout: flowLayout)
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
				let flowLayout = UICollectionViewFlowLayout()
				let gameVC = RedAppleCollectionViewController(collectionViewLayout: flowLayout)
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
                if let cvc = segue.destinationViewController as? RedAppleCollectionViewController {
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
