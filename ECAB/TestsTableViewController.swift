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
        // Return the number of rows in the section.
        return model.games.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) 
        
        cell.textLabel!.text = model.games[indexPath.row].rawValue
        
        return cell
    }
	
	// MARK: — Table View delegate
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		model.data.selectedGame = indexPath.row
		model.save()
		selectGame()
    }
    
    func selectRow(index:Int) {
        let rowToSelect:NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
        self.tableView.selectRowAtIndexPath(rowToSelect, animated: true, scrollPosition: UITableViewScrollPosition.None)
        self.tableView(self.tableView, didSelectRowAtIndexPath: rowToSelect)
    }
	
	func selectGame() {
		
		let navVC = splitViewController!.viewControllers.last as! UINavigationController
		let detailVC = navVC.topViewController as! MenuViewController
		
		switch model.data.selectedGame {
            case GamesIndex.VisualSearch.rawValue:
                detailVC.showTheGame(.VisualSearch)
                break;
            
            case GamesIndex.Counterpointing.rawValue:
                detailVC.showTheGame(.Counterpointing)
                break;
            
            case GamesIndex.Flanker.rawValue:
                detailVC.showTheGame(.Flanker)
                break;
            
            case GamesIndex.VisualSust.rawValue:
                detailVC.showTheGame(.VisualSust)
                break;
            
            case GamesIndex.AuditorySust.rawValue:
                detailVC.showTheGame(.AuditorySust)
                break;
            
            case GamesIndex.DualSust.rawValue:
                detailVC.showTheGame(.DualSust)
                break;
                
            case GamesIndex.Verbal.rawValue:
                detailVC.showTheGame(.Verbal)
                break;
                
            case GamesIndex.Balloon.rawValue:
                detailVC.showTheGame(.Balloon)
                break;
            
            default:
                break
		}
	}
}
