//
//  LogModel.swift
//  ECAB
//
//  Created by Boris Yurkevich on 03/01/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class LogModel {
	
	let formatter = NSDateFormatter()
	let smallFormatter = NSDateFormatter()
	init() {
		formatter.locale = NSLocale.autoupdatingCurrentLocale()
		formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss:S"
		smallFormatter.locale = NSLocale.autoupdatingCurrentLocale()
		smallFormatter.dateFormat = "HH:mm:ss:S"
	}
	
	func generateVisualSearchLogWithSession(session: Session, gameName: String) -> String {
		var detailMoves = ""
		var counter = 1
		var emptyScreenCounter = 0
		for move in session.moves {
			
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
			
			var `repeat` = ""
			if gameMove.`repeat`.boolValue == true {
				`repeat` = "(repeat)"
			} else {
				`repeat` = "(unique)"
			}
			
			let dateStr = smallFormatter.stringFromDate(gameMove.date)
			
			var append: String
			
			if gameMove.empty.boolValue == false {
				
				var extraTime = "unknwon"
				if let definedExtraTime = gameMove.extraTimeLeft {
					extraTime = String(format: "%.02f", definedExtraTime.doubleValue)
				}
				
				append = "\(counter)) \(screenName) Down: \(gameMove.row) Across: \(gameMove.column) \(dateStr) \(progress) \(`repeat`) Extra time left: \(extraTime)\n"
				counter++
			} else {
				append = "\n\(screenName) on set \(dateStr) \n"
				emptyScreenCounter++
			}
			
			detailMoves = detailMoves + append
		}
		_ = session.dateStart.description
		let dateStr = formatter.stringFromDate(session.dateStart)
		
		// Difficlulty level
		// You also can look into difficulty int attribute, I added it in case you would need
		// more than two difficulty levels. 0 - is easy...
		var difficlulty = "unknown"
		if let firstMove = session.moves.firstObject as? Move {
			if firstMove.screenNumber.integerValue > 10 {
				difficlulty = "hard"
			} else {
				difficlulty = "easy"
			}
		}
		
		let comment = session.comment
		
		var build = "unknown"
		if let canonicBuild = session.bundleVersion as String? {
			build = canonicBuild
		}
		
		let visualSearchLog = "\(gameName)\n\nPlayer name: \(session.player.name); difficulty: \(difficlulty); speed: \(session.speed.doubleValue)\n\nComment: \(comment)\n\nTotal score = \(session.score), total moves: \(session.moves.count - emptyScreenCounter) \nFailed attempts: \(session.failureScore)\n\nDetail moves:\n\nSession started: \(dateStr)\nBuild: \(build)\n\n\(detailMoves)"
		return visualSearchLog;
	}
	
	func generateCounterpointingLog(session: CounterpointingSession, gameName: String) -> String {
		var details = ""
		var counter = 0
		var status = "success"
		var spacePrinted = false
		for move in session.moves {
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
			
			let append = "\(counter)) \(status) screen:\(actualMove.poitionX) \(actualMove.interval.integerValue) ms \(inverted) \n"
			if actualMove.inverted.boolValue && spacePrinted == false {
				details = details + "\n" + append
				spacePrinted = true
			} else {
				details = details + append
			}
				counter++
		}
		
		let dateString = formatter.stringFromDate(session.dateStart)
		let ratio = session.totalTwo.doubleValue / session.totalOne.doubleValue
		let roundRatio = Double(round(100 * ratio) / 100)
		
		let comment = session.comment
		
		var build = "unknown"
		if let canonicBuild = session.bundleVersion as String? {
		build = canonicBuild
		}
		
		let text = "\(gameName)\n\nPlayer: \(session.player.name)\n\nComment: \(comment)\n\nTotal score = \(session.score), moves = \(session.moves.count)\nErrors = \(session.errors)\n\nTotal 1 (non-conflict time) = \(session.totalOne.integerValue), total 2 (conflict time) = \(session.totalTwo.integerValue); Ratio (total 2 / total 1) = \(roundRatio)\n\nSession started: \(dateString)\n\nBuild: \(build)\nMoves:\n\n\(details)"
		return text
	}
}
