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
		
		for move  in pickedSesstion.success {
			let successMove = move as! Success
			let append = "Row: \(successMove.row) Column: \(successMove.column) Time: \(successMove.date)\n"
			detailMoves = detailMoves + append
		}
		
		let dateStarted = pickedSesstion.dateStart.description
//		let dateEnded = pickedSesstion.dateEnd.description
		let name = pickedSesstion.player.name
		
		let stringForTheTextView = "Total score = \(pickedSesstion.score), succesfull moves: \(pickedSesstion.success.count)\n\nSession started: \(dateStarted)\n\nPlayer name: \(name)\n\nDetail moves:\n\n\(detailMoves)"
		
		
//		let stringForTheTextView = "Total score = \(pickedSesstion.score), succesfull moves: \(pickedSesstion.success.count)\n\nSession started: \(pickedSesstion.dateStart.description), ended: \(pickedSesstion.dateEnd)\n\nPlayer name: \(pickedSesstion.player.name)\n\n Error moves: \(pickedSesstion.failure.count), repeats: \(pickedSesstion.repeat.count)\n\n Detail moves:\n\n\(detailMoves)"
		
		
		let detailVC = splitViewController!.viewControllers.last?.topViewController as! HistoryViewController

		detailVC.textView.text = stringForTheTextView
		
	}

}
