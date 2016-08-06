//
//  GamesTableViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 3/9/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class TestsTableViewController: UITableViewController {
    
    let model = Model.sharedInstance
    
    private let reuseIdentifier = "Games Table Cell"

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let returnValue = model.games.count
        // Return the number of rows in the section.
        return returnValue
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) 
        
        cell.textLabel!.text = model.games[indexPath.row]
        
        return cell
    }
	
	// MARK: — Table View delegate
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		model.data.selectedGame = indexPath.row
		model.save()
		
		selectGame()
	}
	
	func selectGame() {
		
		let navVC = splitViewController!.viewControllers.last as! UINavigationController
		let detailVC = navVC.topViewController as! MenuViewController
		
		switch model.data.selectedGame {
		case GamesIndex.VisualSearch.rawValue:
			detailVC.showTheGame(.VisualSearch);
		case GamesIndex.Counterpointing.rawValue:
			detailVC.showTheGame(.Counterpointing)
		case GamesIndex.Flanker.rawValue:
			detailVC.showTheGame(.Flanker)
		case GamesIndex.VisualSust.rawValue:
			detailVC.showTheGame(.VisualSust)
		default:
			break
		}
	}
}
