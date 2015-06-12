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
		
		// Date
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale.autoupdatingCurrentLocale()
		formatter.dateFormat = "dd MMM yyyy HH:mm"
		
		switch model.data.selectedGame {
		case 0:
			let session = model.data.sessions[indexPath.row] as! Session
			let dateStr = formatter.stringFromDate(session.dateStart)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
		break
		case 1:
			let session = model.data.counterpointingSessions[indexPath.row] as! CounterpointingSession
			let dateStr = formatter.stringFromDate(session.dateStart)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
		break
		default:
			break;
		}
		return cell
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var returnValue = 0
		
		switch model.data.selectedGame {
		case 0:
			returnValue = model.data.sessions.count
			break
		case 1:
			returnValue = model.data.counterpointingSessions.count
			break
		default:
			break
		}
		
		return returnValue
	}
	
	// MARK: Table view delegate
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let detailVC = splitViewController!.viewControllers.last?.topViewController as! HistoryViewController
		
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale.autoupdatingCurrentLocale()
		formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss:S"
		let smallFormatter = NSDateFormatter()
		smallFormatter.locale = NSLocale.autoupdatingCurrentLocale()
		smallFormatter.dateFormat = "HH:mm:ss:S"
		
		switch model.data.selectedGame {
		case 0:
			let pickedSesstion = model.data.sessions[indexPath.row] as! Session
			var detailMoves = ""
			var counter = 1
			var emptyScreenCounter = 0
			for move in pickedSesstion.moves {
				
				let gameMove = move as! Move
				
				// Caluculate screen
				var screenName = ""
				let screenNum = gameMove.screenNumber.integerValue
				switch screenNum {
				case 0 ... 2, 11 ... 13:
					screenName = "Training \(screenNum + 1)"
					break
				case 3 ... 5, 14 ... 15:
					screenName = "Motor \(screenNum - 2)"
					break
				case 6 ... 8, 16 ... 17:
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
				
				let dateStr = smallFormatter.stringFromDate(gameMove.date)
				
				var append: String
				
				if gameMove.empty.boolValue == false {
					append = "\(counter)) \(screenName) Down: \(gameMove.row) Across: \(gameMove.column) \(dateStr) \(progress) \(repeat) \n"
					counter++
				} else {
					append = "\(screenName) on set \(dateStr) \n"
					emptyScreenCounter++
				}
				
				detailMoves = detailMoves + append
			}
			let dateStarted = pickedSesstion.dateStart.description
			let dateStr = formatter.stringFromDate(pickedSesstion.dateStart)
			let stringForTheTextView = "Player name: \(pickedSesstion.player.name)\n\nTotal score = \(pickedSesstion.score), total moves: \(pickedSesstion.moves.count - emptyScreenCounter)\nFailed attempts: \(pickedSesstion.failureScore)\n\nDetail moves:\n\nSession started: \(dateStr)\n\(detailMoves)"
			detailVC.textView.text = stringForTheTextView
			break;
		case 1:
			let pickedSesstion = model.data.counterpointingSessions[indexPath.row] as! CounterpointingSession
			var details = ""
			var counter = 0
			var status = "success"
			for move in pickedSesstion.moves {
				let actualMove = move as! CounterpointingMove
				if !actualMove.success.boolValue {
					status = "mistake"
				} else {
					status = "success"
				}
				let append = "\(counter)) \(status) \(smallFormatter.stringFromDate(actualMove.date)) across:\(actualMove.poitionX) down:\(actualMove.poitionY) \n"
				details = details + append
				counter++
			}
			
			let dateString = formatter.stringFromDate(pickedSesstion.dateStart)
			let text = "Total score = \(pickedSesstion.score), moves = \(pickedSesstion.moves.count)\n\nPlayer: \(pickedSesstion.player.name)\n\nErrors = \(pickedSesstion.errors)\n\nSession started: \(dateString)\n\nMoves:\n\n\(details)"
			detailVC.textView.text = text
			break;
		default:
			break;
		}
	}
}
