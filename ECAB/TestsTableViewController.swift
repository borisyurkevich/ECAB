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
    
    fileprivate let reuseIdentifier = "Games Table Cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Tests"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let selectedRow = IndexPath(row: model.data.selectedGame.intValue, section: 0)
        tableView.selectRow(at: selectedRow, animated: false, scrollPosition: .none)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let returnValue = model.games.count
        // Return the number of rows in the section.
        return returnValue
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) 
        
        cell.textLabel!.text = model.games[indexPath.row]
        cell.accessoryType = model.data.selectedGame.intValue == indexPath.row ? .checkmark : .none
        
        return cell
    }
	
	// MARK: — Table View delegate
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		model.data.selectedGame = NSNumber(value: indexPath.row)
		model.save()
        tableView.reloadData()
		
		selectGame()
	}
	
	func selectGame() {
		
		let navVC = splitViewController!.viewControllers.last as! UINavigationController
		let detailVC = navVC.topViewController as! MenuViewController
		
		switch model.data.selectedGame {
		case GamesIndex.visualSearch.rawValue:
			detailVC.showTheGame(.visualSearch);
		case GamesIndex.counterpointing.rawValue:
			detailVC.showTheGame(.counterpointing)
		case GamesIndex.flanker.rawValue:
			detailVC.showTheGame(.flanker)
		case GamesIndex.visualSust.rawValue:
			detailVC.showTheGame(.visualSust)
		default:
			break
		}
	}
}
