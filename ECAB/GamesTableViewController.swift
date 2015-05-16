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
        
        let game: Game = model.games[indexPath.row]
        cell.textLabel!.text = game.title
        
        return cell
    }
}
