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
	let logModel = LogModel()
	
	private let reuseIdentifier = "Session Table Cell"
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		title = model.games[Int(model.data.selectedGame)]
		
		// For some reason there's delay and table is not updated streight after
		// game is finished.
		tableView.reloadData()
	}
	
	// MARK: - Table view data source
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
		
		// Date
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale.autoupdatingCurrentLocale()
		formatter.dateFormat = "dd MMM yyyy HH:mm"
		
		switch model.data.selectedGame {
		case GamesIndex.VisualSearch.rawValue:
			let session = model.data.sessions[indexPath.row] as! Session
			let dateStr = formatter.stringFromDate(session.dateStart)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
			
		case GamesIndex.Counterpointing.rawValue:
			
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
			
		case GamesIndex.Flanker.rawValue:
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
			
		case GamesIndex.VisualSust.rawValue:
			var fSessions = [CounterpointingSession]()
			for session in model.data.counterpointingSessions {
				let fSession = session as! CounterpointingSession
				if fSession.type.integerValue == 2 {
					fSessions.append(fSession)
				}
			}
			
			let session = fSessions[indexPath.row]
			let dateStr = formatter.stringFromDate(session.dateStart)
			let label = "\(indexPath.row+1). \(dateStr)"
			cell.textLabel!.text = label
		default:
			break;
		}
		return cell
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		var returnValue = 0
		
		switch model.data.selectedGame {
		case GamesIndex.VisualSearch.rawValue:
			returnValue = model.data.sessions.count
			break
		case GamesIndex.Counterpointing.rawValue:
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 0 {
					returnValue++
				}
			}
			break
		case GamesIndex.Flanker.rawValue:
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 1 {
					returnValue++
				}
			}
		case GamesIndex.VisualSust.rawValue:
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 2 {
					returnValue++
				}
			}
		default:
			break
		}
		
		return returnValue
	}
	
	// MARK: - Table view delegate
	
	override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
		return true
	}
	
	override func tableView(tableView: UITableView, commitEditingStyle
		editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == UITableViewCellEditingStyle.Delete {
		
			let navVC = splitViewController!.viewControllers.last as! UINavigationController
			let detailVC = navVC.topViewController as! HistoryViewController
		
			// Session to remove
			switch model.data.selectedGame {
			case GamesIndex.VisualSearch.rawValue:
				let session = model.data.sessions[indexPath.row] as! Session
				model.managedContext.deleteObject(session)
				var error: NSError?
				do {
					try model.managedContext.save()
				} catch let error1 as NSError {
					error = error1
					print("Could not save after delete: \(error)")
				}
			case GamesIndex.Counterpointing.rawValue:
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
				do {
					try model.managedContext.save()
				} catch let error1 as NSError {
					error = error1
					print("Could not save after delete: \(error)")
				}
			case GamesIndex.Flanker.rawValue:
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
				do {
					try model.managedContext.save()
				} catch let error1 as NSError {
					error = error1
					print("Could not save after delete: \(error)")
				}
			case GamesIndex.VisualSust.rawValue:
				var fSessions = [CounterpointingSession]()
				for session in model.data.counterpointingSessions {
					let fSession = session as! CounterpointingSession
					if fSession.type.integerValue == 2 {
						fSessions.append(fSession)
					}
				}
				let session = fSessions[indexPath.row]
				model.managedContext.deleteObject(session)
				var error: NSError?
				do {
					try model.managedContext.save()
				} catch let error1 as NSError {
					error = error1
					print("Could not save after delete: \(error)")
				}
			default:
			break
			}
		
			// Last step
			tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
			detailVC.textView.text = ""
			detailVC.helpMessage.text = "Select any session from the left."
		}
	}
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let navVC = splitViewController!.viewControllers.last as! UINavigationController!
		let detailVC = navVC.topViewController as! HistoryViewController
		
		let formatter = NSDateFormatter()
		formatter.locale = NSLocale.autoupdatingCurrentLocale()
		formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss:S"
		let smallFormatter = NSDateFormatter()
		smallFormatter.locale = NSLocale.autoupdatingCurrentLocale()
		smallFormatter.dateFormat = "HH:mm:ss:S"
		
		let gameName = model.games[Int(model.data.selectedGame)]
		
		switch model.data.selectedGame {
		case GamesIndex.VisualSearch.rawValue:
			let pickedSession = model.data.sessions[indexPath.row] as! Session
			let visualSearchLog = logModel.generateVisualSearchLogWithSession(pickedSession, gameName: gameName)
			detailVC.textView.text = visualSearchLog
			detailVC.helpMessage.text = ""
		case GamesIndex.Counterpointing.rawValue:
			var array = [CounterpointingSession]()
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 0 {
					array.append(cSession)
				}
			}
			let pickedSession = array[indexPath.row]
			let counterpointingLog = logModel.generateCounterpointingLogWithSession(pickedSession, gameName: gameName)
			detailVC.textView.text = counterpointingLog
			detailVC.helpMessage.text = ""
		case GamesIndex.Flanker.rawValue: // Flanker - exact copy of Counterpointing
			var array = [CounterpointingSession]()
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 1 {
					array.append(cSession)
				}
			}
			let pickedSession = array[indexPath.row]
			let text = logModel.generateFlankerLogWithSession(pickedSession, gameName: gameName)
			detailVC.textView.text = text
			detailVC.helpMessage.text = ""
		case GamesIndex.VisualSust.rawValue:
			var array = [CounterpointingSession]()
			for session in model.data.counterpointingSessions {
				let cSession = session as! CounterpointingSession
				if cSession.type.integerValue == 2 {
					array.append(cSession)
				}
			}
			let pickedSesstion = array[indexPath.row]
			detailVC.textView.text = logModel.generateVisualSustainLogWithSession(pickedSesstion, gameName: gameName)
			detailVC.helpMessage.text = ""
		default:
			break
		}
	}
}
