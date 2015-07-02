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
		
		if (model.visualSearchOnEasy) {
			speedStepper.value = model.visualSearchSpeedEasy
			speedLabel.text = "\(model.visualSearchSpeedEasy) seconds"
		} else {
			speedStepper.value = model.visualSearchSpeedHard
			speedLabel.text = "\(model.visualSearchSpeedHard) seconds"
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
		if model.visualSearchOnEasy {
			model.visualSearchSpeedEasy = sender.value
			speedLabel.text = "\(model.visualSearchSpeedEasy) seconds"
		} else {
			model.visualSearchSpeedHard = sender.value
			speedLabel.text = "\(model.visualSearchSpeedHard) seconds"
		}
	}

    // MARK: - Navigation

    @IBAction func playButtonHandler(sender: UIBarButtonItem) {
        
        if let detailVC: UISplitViewController = splitViewController {
            // The right way get reference to UISplitViewController, UINavigationController or UITabBarController
			
			var gameVC = UIViewController()
			
			switch title! {
			case model.titles.visual:
				let flowLayout = UICollectionViewFlowLayout()
				gameVC = RedAppleCollectionViewController(collectionViewLayout: flowLayout)
			case model.titles.counterpointing:
				let gameVC = CounterpointingViewController()
			case model.titles.flanker:
				let gameVC = FlankerViewController()
			case model.titles.visualSust:
				let gameVC = VisualSustainViewController()
			default:
				let flowLayout = UICollectionViewFlowLayout()
				let gameVC = RedAppleCollectionViewController(collectionViewLayout: flowLayout)
			}
			
			detailVC.presentViewController(gameVC, animated: true, completion: nil)
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
