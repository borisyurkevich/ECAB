//
//  GamesTableViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 3/9/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class GamesTableViewController: UITableViewController {
    
    let model = Model.sharedInstance
    
    private let reuseIdentifier = "Games Table Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let returnValue = model.games.count
        // Return the number of rows in the section.
        return returnValue
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        cell.textLabel!.text = model.games[indexPath.row]
        
        return cell
    }
	
	// MARK: — Table View delegate
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let pickedGameTitle = model.games[indexPath.row]
		model.data.selectedGame = indexPath.row
		
		let detailVC = splitViewController!.viewControllers.last?.topViewController as! MenuViewController
		detailVC.title = pickedGameTitle
		detailVC.gameTitleCenter.text = pickedGameTitle
		
		switch model.data.selectedGame {
			case 0:
				detailVC.gameIcon.image = UIImage(named: "red_apple")
				detailVC.difControl.hidden = false
				detailVC.speedLabel.hidden = false
				detailVC.speedStepper.hidden = false
			case 1:
				detailVC.gameIcon.image = UIImage(named: "dog")
				detailVC.difControl.hidden = true
				detailVC.speedLabel.hidden = true
				detailVC.speedStepper.hidden = true
			case 2:
				detailVC.gameIcon.image = UIImage(named: "fish")
				detailVC.difControl.hidden = true
				detailVC.speedLabel.hidden = true
				detailVC.speedStepper.hidden = true
			case 3:
				detailVC.gameIcon.image = UIImage(named: "pig")
				detailVC.difControl.hidden = true
				detailVC.speedLabel.hidden = true
				detailVC.speedStepper.hidden = true
			default:
			break
		}
	}
}
