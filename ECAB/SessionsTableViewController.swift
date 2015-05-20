//
//  SessionsTableViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/13/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class SessionsTableViewController: UITableViewController {
	
	let model = Model.sharedInstance
	
	private let reuseIdentifier = "Session Table Cell"
	
	override func viewWillAppear(animated: Bool) {
		
		// For some reason there's delay and table is not updated streight after
		// game is finished.
		
		tableView.reloadData()
	}

	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! UITableViewCell
		
		let session = model.data.sessions[indexPath.row] as! Session
		cell.textLabel!.text = session.dateStart.description
		
		return cell
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		let returnValue = model.data.sessions.count
		return returnValue
	}
	
	// MARK: Table view delegate
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let pickedSesstion = model.data.sessions[indexPath.row] as! Session
		
		var detailMoves = ""
		var counter = 1
		
		for move  in pickedSesstion.moves {
			let gameMove = move as! Move
			let append = "\(counter). Row: \(gameMove.row) Column: \(gameMove.column) Time: \(gameMove.date) Success: \(gameMove.success.boolValue) Repeat: \(gameMove.repeat.boolValue) Training: \(gameMove.training.boolValue)\n"
			detailMoves = detailMoves + append
			counter++
		}
		
		let dateStarted = pickedSesstion.dateStart.description
//		let dateEnded = pickedSesstion.dateEnd.description
		var sudoName = "Unknown"
		
		if let player = pickedSesstion.player as Player? {
			sudoName = player.name
		}
		
		let stringForTheTextView = "Total score = \(pickedSesstion.score), total moves: \(pickedSesstion.moves.count)\n\nFailed attempts: \(pickedSesstion.failureScore)\n\nSession started: \(dateStarted)\n\nPlayer name: \(sudoName)\n\nDetail moves:\n\n\(detailMoves)"
		
		let detailVC = splitViewController!.viewControllers.last?.topViewController as! HistoryViewController

		detailVC.textView.text = stringForTheTextView
		
	}

}
