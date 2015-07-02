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
		super.viewWillAppear(animated)
		
		// For some reason there's delay and table is not updated streight after
		// game is finished.
		tableView.reloadData()
	}
	
	// MARK: - Table view delegate
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle
		editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
		
			let detailVC = splitViewController!.viewControllers.last?.topViewController as! HistoryViewController
		
			// Session to remove
			switch model.data.selectedGame {
			case 0:
				let session = model.data.sessions[indexPath.row] as! Session
				model.managedContext.deleteObject(session)
				var error: NSError?
				if !model.managedContext.save(&error) {
					println("Could not save after delete: \(error)")
				}
				break
			case 1:
				var cSessions = [CounterpointingSession]()
				for session in model.data.counterpointingSessions {
					let cSession = session as! CounterpointingSession
					if cSession.type.integerValue == 0 {
						cSessions.append(cSession)
					}
				}
				let session = cSessions[indexPath.row]
				model.managedContext.deleteObject(session)
				var error: NSError?
				if !model.managedContext.save(&error) {
					println("Could not save after delete: \(error)")
				}
				break
			case 2:
				var fSessions = [CounterpointingSession]()
				for session in model.data.counterpointingSessions {
					let fSession = session as! CounterpointingSession
					if fSession.type.integerValue == 1 {
						fSessions.append(fSession)
					}
				}
				let session = fSessions[indexPath.row]
				model.managedContext.deleteObject(session)
				var error: NSError?
				if !model.managedContext.save(&error) {
					println("Could not save after delete: \(error)")
				}
				break
			default:
			break
			}
		
			// Last step
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
			detailVC.textView.text = ""
			detailVC.helpMessage.text = "Select any session from the left."
		}
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
			
			var cSessions = [CounterpointingSession]()
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 0 {
					cSessions.append(cSession)
				}
			}
			
			let session = cSessions[indexPath.row]
			let dateStr = formatter.stringFromDate(session.dateStart)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
		break
		case 2:
			var fSessions = [CounterpointingSession]()
			for session in model.data.counterpointingSessions {
				let fSession = session as! CounterpointingSession
				if fSession.type.integerValue == 1 {
					fSessions.append(fSession)
				}
			}
			
			let session = fSessions[indexPath.row]
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
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 0 {
					returnValue++
				}
			}
			break
		case 2:
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 1 {
					returnValue++
				}
			}
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
					append = "\n\(screenName) on set \(dateStr) \n"
					emptyScreenCounter++
				}
				
				detailMoves = detailMoves + append
			}
			let dateStarted = pickedSesstion.dateStart.description
			let dateStr = formatter.stringFromDate(pickedSesstion.dateStart)
			
			// Difficlulty level
			let firstMove: Move = pickedSesstion.moves[0] as! Move
			var difficlulty = "easy"
			if firstMove.screenNumber.integerValue > 10 {
				difficlulty = "hard"
			}
			
			let stringForTheTextView = "Visual Search\n\nPlayer name: \(pickedSesstion.player.name) Difficulty: \(difficlulty)\n\nTotal score = \(pickedSesstion.score), total moves: \(pickedSesstion.moves.count - emptyScreenCounter) \nFailed attempts: \(pickedSesstion.failureScore)\n\nDetail moves:\n\nSession started: \(dateStr)\n\(detailMoves)"
			detailVC.textView.text = stringForTheTextView
			detailVC.helpMessage.text = ""
			break;
		case 1: // Counterpointing
			var array = [CounterpointingSession]()
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 0 {
					array.append(cSession)
				}
			}
			let pickedSesstion = array[indexPath.row]
			var details = ""
			var counter = 0
			var status = "success"
			var spacePrinted = false
			for move in pickedSesstion.moves {
				let actualMove = move as! CounterpointingMove
				if !actualMove.success.boolValue {
					status = "mistake"
				} else {
					status = "success"
				}
				
				var inverted = "normal"
				if actualMove.inverted.boolValue {
					inverted = "inverted"
				}
				
				let append = "\(counter)) \(status) across:\(actualMove.poitionX) down:\(actualMove.poitionY) \(actualMove.interval.integerValue) ms \(inverted) \n"
				if actualMove.inverted.boolValue && spacePrinted == false {
					details = details + "\n" + append
					spacePrinted = true
				} else {
					details = details + append
				}
				counter++
			}
			
			let dateString = formatter.stringFromDate(pickedSesstion.dateStart)
			let ratio = pickedSesstion.totalTwo.doubleValue / pickedSesstion.totalOne.doubleValue
			let text = "Counterpointing\n\nPlayer: \(pickedSesstion.player.name)\n\nTotal score = \(pickedSesstion.score), moves = \(pickedSesstion.moves.count)\nErrors = \(pickedSesstion.errors)\n\nTotal 1 = \(pickedSesstion.totalOne.integerValue) Total 2 = \(pickedSesstion.totalTwo.integerValue) Ratio (total 2 / total 1) = \(ratio)\n\nSession started: \(dateString)\n\nMoves:\n\n\(details)"
			detailVC.textView.text = text
			detailVC.helpMessage.text = ""
			break
		case 2: // Flanker - exact copy of Counterpointing
			var array = [CounterpointingSession]()
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 1 {
					array.append(cSession)
				}
			}
			let pickedSesstion = array[indexPath.row]
			var details = ""
			var counter = 0
			var status = "success"
			var spacePrinted = false
			for move in pickedSesstion.moves {
				let actualMove = move as! CounterpointingMove
				if !actualMove.success.boolValue {
					status = "mistake"
				} else {
					status = "success"
				}
				
				var inverted = "normal"
				if actualMove.inverted.boolValue {
					inverted = "inverted"
				}
				
				let append = "\(counter)) \(status) across:\(actualMove.poitionX) down:\(actualMove.poitionY) \(actualMove.interval.integerValue) ms \(inverted) \n"
				if counter == 9 || counter == 19 || counter == 29 {
					details = details + "\n" + append
				} else {
					details = details + append
				}
				counter++
			}
			
			let dateString = formatter.stringFromDate(pickedSesstion.dateStart)
			let ratio = pickedSesstion.totalTwo.doubleValue / pickedSesstion.totalOne.doubleValue
			let text = "Flanker\n\nPlayer: \(pickedSesstion.player.name)\n\nTotal score = \(pickedSesstion.score), moves = \(pickedSesstion.moves.count)\nErrors = \(pickedSesstion.errors)\n\nTotal 1 = \(pickedSesstion.totalOne.integerValue) Total 2 = \(pickedSesstion.totalTwo.integerValue) Ratio (game 2 + game 3 / game 1 + game 4) = \(ratio)\n\nSession started: \(dateString)\n\nMoves:\n\n\(details)"
			detailVC.textView.text = text
			detailVC.helpMessage.text = ""
			break
		default:
			break
		}
	}
}
