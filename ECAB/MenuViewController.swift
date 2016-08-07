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
    @IBOutlet weak var difficultyTitle: UILabel!

	@IBOutlet weak var speedLabel: UILabel!
	@IBOutlet weak var speedStepper: UIStepper!
    @IBOutlet weak var speedLabelDescription: UILabel!

	@IBOutlet weak var secondSpeedStepper: UIStepper!
	@IBOutlet weak var secondSpeedLabel: UILabel!
	@IBOutlet weak var secondSpeedLabelDescription: UILabel!
    
	@IBOutlet weak var periodValue: UILabel!
	@IBOutlet weak var periodControl: UIStepper!
	@IBOutlet weak var periodTitle: UILabel!
	@IBOutlet weak var periodHelp: UILabel!
    
    @IBOutlet weak var thresholdLabel: UILabel!
    @IBOutlet weak var thresholdStepper: UIStepper!
    @IBOutlet weak var thresholdTitle: UILabel!
    
    @IBOutlet weak var randomizeFlanker: UISwitch!
    @IBOutlet weak var randomizeLabel: UILabel!
	
    let model: Model = Model.sharedInstance
    
    private struct Segues {
        static let startApplesGame = "Start apples game"
        static let openSubjectsPopover = "Open subjects popover"
    }
    
    @IBAction func adjustThreshold(sender: UIStepper) {
        let formattedValue = NSString(format: "%.01f", sender.value)
        let newValue = Float(formattedValue as String)!
        
        model.data.threshold = newValue
        thresholdLabel.text = "\(formattedValue)"
        model.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
		changePlayerButton.title = "Loading..."
        
		// Subscribe from notifications from Model
		NSNotificationCenter.defaultCenter().addObserver(self,
		                                                 selector: #selector(MenuViewController.dataLoaded),
		                                                 name: "dataLoaded",
		                                                 object: nil)
		model.setupWithContext(managedContext)

        difControl.selectedSegmentIndex = model.data.visSearchDifficulty.integerValue
        randomizeFlanker.on = NSUserDefaults.standardUserDefaults().boolForKey("isFlankerRandomized")
    }
	
	func dataLoaded() {
        
        // Select row in tableView
        let navVC = splitViewController!.viewControllers.first as! UINavigationController
        let testTVC = navVC.topViewController as! TestsTableViewController
        testTVC.selectRow(model.data.selectedGame.integerValue)
		
        // Show correct selected game
		switch model.data.selectedGame {
            
            case GamesIndex.VisualSearch.rawValue:
                showTheGame(.VisualSearch)
                break;
            
            case GamesIndex.VisualSust.rawValue:
                showTheGame(.VisualSust)
                break;
            
            case GamesIndex.Flanker.rawValue:
                showTheGame(.Flanker)
                break;
            
            case GamesIndex.Counterpointing.rawValue:
                showTheGame(.Counterpointing)
                break;
            
            case GamesIndex.AuditorySust.rawValue:
                showTheGame(.AuditorySust)
                break;
            
            case GamesIndex.DualSust.rawValue:
                showTheGame(.DualSust)
                break;
                
            case GamesIndex.Verbal.rawValue:
                showTheGame(.Verbal)
                break;
                
            case GamesIndex.Balloon.rawValue:
                showTheGame(.Balloon)
                break;
            
            default:
                break
		}
		
        // Show correct player name
		changePlayerButton.title = model.data.selectedPlayer.name
	}
	
	func showTheGame(game: GamesIndex) {
        
        // Hide all the controls
        difControl.hidden = true
        difficultyTitle.hidden = true
        
        speedLabel.hidden = true
        speedStepper.hidden = true
        speedLabelDescription.hidden = true

        secondSpeedLabel.hidden = true
        secondSpeedStepper.hidden = true
        secondSpeedLabelDescription.hidden = true
        
        periodControl.hidden = true
        periodTitle.hidden = true
        periodHelp.hidden = true
        periodValue.hidden = true
        
        thresholdLabel.hidden = true
        thresholdStepper.hidden = true
        thresholdTitle.hidden = true
        
        randomizeFlanker.hidden = true
        randomizeLabel.hidden = true
		
        // Set game title
		title = model.games[model.data.selectedGame.integerValue].rawValue
		
		switch game {
            case .VisualSearch:
                gameIcon.image = UIImage(named: "icon_visual")
                difControl.hidden = false
                difficultyTitle.hidden = false

                speedLabel.hidden = false
                speedLabelDescription.hidden = false
                
                speedStepper.hidden = false
                
                // Set difficulty toggle
                difControl.selectedSegmentIndex = model.data.visSearchDifficulty.integerValue
                
                if model.data.visSearchDifficulty.integerValue == 0 {
                    speedLabel.text = "\(model.data.visSearchSpeed.doubleValue) \(MenuConstants.second)"
                    speedStepper.value = model.data.visSustSpeed.doubleValue
                } else {
                    speedLabel.text = "\(model.data.visSearchSpeedHard.doubleValue) \(MenuConstants.second)"
                    speedStepper.value = model.data.visSearchSpeedHard.doubleValue
                }
                break
            case .Flanker, .FlankerRandomised:
                gameIcon.image = UIImage(named: "icon_flanker")
            
                randomizeFlanker.hidden = false
                randomizeLabel.hidden = false
                break
            case .Counterpointing:
                gameIcon.image = UIImage(named: "icon_counter")
                break
            case .VisualSust:
                gameIcon.image = UIImage(named: "icon_sustained")
                
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
                break
            case .AuditorySust:
                gameIcon.image = UIImage(named: "icon_auditory")
                break
            
            case .DualSust:
                gameIcon.image = UIImage(named: "icon_dual")
                
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
                
                speedStepper.value = model.data.dualSustSpeed.doubleValue
                speedLabel.text = "\(model.data.dualSustSpeed.doubleValue) \(MenuConstants.second)"
                
                secondSpeedLabel.text = "\(model.data.dualSustAcceptedDelay!.doubleValue) \(MenuConstants.second)"
                secondSpeedStepper.value = model.data.dualSustAcceptedDelay!.doubleValue
                
                let exposure = model.data.dualSustSpeed.doubleValue
                let delay = model.data.dualSustDelay.doubleValue
                let totalPeriod = exposure + delay
                periodControl.value = totalPeriod
                periodValue.text = "\(totalPeriod) \(MenuConstants.second)"
                periodHelp.text = "Blank space time: \(delay) \(MenuConstants.second)"
                
                break
                
            case .Verbal:
                gameIcon.image = UIImage(named: "icon_verbal")
                
                thresholdLabel.hidden = false
                thresholdStepper.hidden = false
                thresholdTitle.hidden = false
                
                let formattedValue = NSString(format: "%.01f", model.data.threshold.doubleValue)
                thresholdLabel.text = "\(formattedValue)"
                thresholdStepper.value = model.data.threshold.doubleValue
                
                break
                
            case .Balloon:
                gameIcon.image = UIImage(named: "icon_balloon")
                break
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
        } else if model.data.selectedGame == GamesIndex.DualSust.rawValue {
            model.data.dualSustSpeed = newSpeedValueDouble
            
            let delay = model.data.dualSustDelay.doubleValue
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
        
        if model.data.selectedGame == GamesIndex.VisualSust.rawValue {
            model.data.visSustAcceptedDelay = number
        } else if model.data.selectedGame == GamesIndex.DualSust.rawValue {
            model.data.dualSustAcceptedDelay = number
        }
        
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
			
            if model.data.selectedGame == GamesIndex.VisualSust.rawValue {
                model.data.visSustDelay = newDelay
            } else if model.data.selectedGame == GamesIndex.DualSust.rawValue {
                model.data.dualSustDelay = newDelay
            }
		} else {
			periodHelp.text = "Blank space time: 0 \(MenuConstants.second) Ignored when less than a second"
			periodHelp.textColor = UIColor.redColor()
			
            if model.data.selectedGame == GamesIndex.VisualSust.rawValue {
                model.data.visSustDelay = 0.0
            } else if model.data.selectedGame == GamesIndex.DualSust.rawValue {
                model.data.dualSustDelay = 0.0
            }
		}
		model.save()
	}

    @IBAction func randomizedFlanker(sender: UISwitch) {
        NSUserDefaults.standardUserDefaults().setBool(sender.on, forKey: "isFlankerRandmoized")
    }
	
	func validateAndHighliteBlankSpaceLabel() {
        var currentDelay: Double = 0.0;
                    
        if model.data.selectedGame.integerValue == GamesIndex.VisualSust.rawValue {
            currentDelay = model.data.visSustDelay.doubleValue
        } else if model.data.selectedGame == GamesIndex.DualSust.rawValue {
            currentDelay = model.data.dualSustDelay.doubleValue
        }
        
		if currentDelay < model.kMinDelay {
			periodHelp.text = "Blank space time: \(currentDelay) \(MenuConstants.second) Ignored when less than a second"
			periodHelp.textColor = UIColor.redColor()
		}
	}
	
    // MARK: - Navigation

    @IBAction func playButtonHandler(sender: UIBarButtonItem) {
        
        if let detailVC: UISplitViewController = splitViewController {
			
			switch title! {
                
                case GameTitle.visual.rawValue:
                    detailVC.presentViewController(VisualSearchViewController(), animated: true, completion: nil)
                
                case GameTitle.counterpointing.rawValue:
                    detailVC.presentViewController(CounterpointingViewController(), animated: true, completion: nil)
                
                case GameTitle.flanker.rawValue:
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
                    
                case GameTitle.visualSust.rawValue:
                    detailVC.presentViewController(VisualSustainViewController(), animated: true, completion: nil)
                
                case GameTitle.auditorySust.rawValue:
                    detailVC.presentViewController(AuditorySustainViewController(), animated: true, completion: nil)
                
                case GameTitle.dualSust.rawValue:
                    detailVC.presentViewController(DualSustainViewController(), animated: true, completion: nil)
                
                case GameTitle.verbal.rawValue:
                    detailVC.presentViewController(VerbalOppositesViewController(), animated: true, completion: nil)
                
                case GameTitle.balloon.rawValue:
                    detailVC.presentViewController(VisualSustainViewController(), animated: true, completion: nil)
                
                default:
                    let gameVC = VisualSearchViewController()
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
                if let cvc = segue.destinationViewController as? VisualSearchViewController {
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
