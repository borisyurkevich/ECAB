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
	
	
	
    let model: Model = Model.sharedInstance
    
    private struct Segues {
        static let startApplesGame = "Start apples game"
        static let openSubjectsPopover = "Open subjects popover"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		model.setupWithContext(managedContext)
		
		let modelReference = model
		let dataRef = modelReference.data
		if let playerRef = dataRef.selectedPlayer as Player?{
			// Change button title to display current player name
			changePlayerButton.title = "\(playerRef.name)"
		}
	}

    // MARK: - Navigation

    @IBAction func playButtonHandler(sender: UIBarButtonItem) {
        
        if let detailVC: UISplitViewController = splitViewController {
            // The right way get reference to UISplitViewController, UINavigationController or UITabBarController
			
			switch title! {
			case model.titles.visual:
				let flowLayout = UICollectionViewFlowLayout()
				let gameVC = RedAppleCollectionViewController(collectionViewLayout: flowLayout)
				
				detailVC.presentViewController(gameVC, animated: true, completion: nil)
				break
			case model.titles.counterpointing:
				break
			default:
				break
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
