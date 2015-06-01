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
		
		// Date
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale.autoupdatingCurrentLocale()
		formatter.dateFormat = "dd MMM yyyy HH:mm"
		let dateStr = formatter.stringFromDate(session.dateStart)
		let label = "\(indexPath.row+1). \(dateStr)"
		cell.textLabel!.text = label
		
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
		var emptyScreenCounter = 0
		
		for move  in pickedSesstion.moves {
			
			let gameMove = move as! Move
			
			// Caluculate screen
			var screenName = ""
			let screenNum = gameMove.screenNumber.integerValue
			switch screenNum {
			case 0 ... 2:
				screenName = "Training \(screenNum + 1)"
				break
			case 3 ... 5:
				screenName = "Motor \(screenNum - 2)"
				break
			case 6 ... 8:
				screenName = "Search \(screenNum - 5)"
				break
			default:
				break
			}
			
			// Success or failure
			var progress = ""
			if gameMove.success.boolValue == true {
				progress = "success"
			} else {
				progress = "failure"
			}
			
			var repeat = ""
			if gameMove.repeat.boolValue == true {
				repeat = "repeat"
			} else {
				repeat = "unique"
			}
			
			// Date
			let formatter = NSDateFormatter()
			formatter.locale = NSLocale.autoupdatingCurrentLocale()
			formatter.dateFormat = "HH:mm:ss:S"
			let dateStr = formatter.stringFromDate(gameMove.date)
			
			var append: String
			
			if gameMove.empty.boolValue == false {
				append = "\(counter)) \(screenName) Row: \(gameMove.row) Column: \(gameMove.column) \(dateStr) \(progress) \(repeat) \n"
				counter++
			} else {
				append = "\(screenName) changed: \(dateStr) \n"
				emptyScreenCounter++
			}
			
			detailMoves = detailMoves + append
		}
		
		let dateStarted = pickedSesstion.dateStart.description
		
		// Date
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale.autoupdatingCurrentLocale()
		formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss"
		let dateStr = formatter.stringFromDate(pickedSesstion.dateStart)
		
//		let dateEnded = pickedSesstion.dateEnd.description
		var sudoName = "Unknown"
		
		if let player = pickedSesstion.player as Player? {
			sudoName = player.name
		}
		
		let stringForTheTextView = "Total score = \(pickedSesstion.score), total moves: \(pickedSesstion.moves.count - emptyScreenCounter)\n\nFailed attempts: \(pickedSesstion.failureScore)\n\nSession started: \(dateStr)\n\nPlayer name: \(sudoName)\n\nDetail moves:\n\n\(detailMoves)"
		
		let detailVC = splitViewController!.viewControllers.last?.topViewController as! HistoryViewController

		detailVC.textView.text = stringForTheTextView
	}
}
