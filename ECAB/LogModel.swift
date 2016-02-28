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
		formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss:S"
		smallFormatter.dateFormat = "HH:mm:ss:S"
	}
	
	func generateVisualSearchLogWithSession(session: Session, gameName: String) -> String {
		var detailMoves = ""
		var counter = 1
		var emptyScreenCounter = 0
        
        let totals = ECABLogCalculator.getVisualSearchTotals(session)
        
		for move in session.moves {
			
			let gameMove = move as! Move
			
			// Caluculate screen
			var screenName = ""
			let screenNum = gameMove.screenNumber.integerValue
            var trainig = false
            
			switch screenNum {
                
            case VisualSearchEasyModeView.TrainingOne.rawValue ... VisualSearchEasyModeView.TrainingThree.rawValue:
                
				screenName = "Training \(screenNum + 1)"
                trainig = true
                
            case VisualSearchHardModeView.TrainingOne.rawValue ... VisualSearchHardModeView.TrainingThree.rawValue:
                
                screenName = "Training \(screenNum - 10)"
                trainig = true
                
            case VisualSearchEasyModeView.MotorOne.rawValue ... VisualSearchEasyModeView.MotorThree.rawValue:
                
                screenName = "Motor \(screenNum - 2)"
                trainig = false
                
            case VisualSearchHardModeView.MotorOne.rawValue, VisualSearchHardModeView.MotorTwo.rawValue:

                screenName = "Motor \(screenNum - 13)"
                trainig = false

            case VisualSearchEasyModeView.One.rawValue ... VisualSearchEasyModeView.Three.rawValue:
            
				screenName = "Search \(screenNum - 5)"
                trainig = false
			
            case VisualSearchHardModeView.One.rawValue, VisualSearchHardModeView.Two.rawValue:
                
                screenName = "Search \(screenNum - 15)"
                trainig = false
                
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
				
                append = "\(counter)) \(screenName) Down: \(gameMove.row) Across: \(gameMove.column) \(dateStr) \(progress) \(`repeat`) \n"

				counter++
			} else {
                if (!trainig) {
                    append = "\n\(screenName) onset \(dateStr) \n"
                } else {
                    append = "\n\(screenName)\n"
                }
				emptyScreenCounter++
			}
			
			detailMoves = detailMoves + append
		}
		_ = session.dateStart.description
		let dateStr = formatter.stringFromDate(session.dateStart)
		
		var difficulty = "easy"
		if session.difficulty == Difficulty.Hard.rawValue {
			difficulty = "hard"
		}
		
		let comment = session.comment
		
		var build = "unknown"
		if let canonicBuild = session.bundleVersion as String? {
			build = canonicBuild
		}
        
		let visualSearchLog = "\(gameName) \(difficulty) difficulty. \n\nPlayer name: \(session.player.name)\nExposure: \(session.speed.doubleValue)\n\nComment: \(comment)\n\nTotal score = \(session.score)\nFalse positives: \(session.failureScore)\n\nTime per target found[motor] = \(totals.average.motor)\nTime per target found[search] = \(totals.average.search)\nSearch time - motor time per target = \(totals.average.search - totals.average.motor)\n\nMotor 1 total = \(totals.motorOneTotal)\nMotor 2 total = \(totals.motorTwoTotal)\nMotor 3 total = \(totals.motorThreeTotal)\nSearch 1 total = \(totals.searachOneTotal)\nSearch 2 total = \(totals.searchTwoTotal)\nSearch 3 total = \(totals.searhThreeTotal)\n\nDetail moves:\n\nSession started: \(dateStr)\nBuild: \(build)\n\n\(detailMoves)"
		return visualSearchLog;
	}
	
	func generateCounterpointingLogWithSession(session: CounterpointingSession, gameName: String) -> String {
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
	
	func generateFlankerLogWithSession(session: CounterpointingSession, gameName: String) -> String {
		var details = ""
		var counter = 0
		var status = "success"
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
			
			let append = "\(counter)) \(status) screen: \(actualMove.poitionX) \(actualMove.interval.integerValue) ms \(inverted) \n"
			if counter == 9 || counter == 19 || counter == 29 {
				details = details + append + "\n"
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
		if let definedBuild = session.bundleVersion as String? {
			build = definedBuild
		}
		
		var imageInfo = "uknown"
		if let definedImageInfo = session.imageSizeComment as String? {
			imageInfo = definedImageInfo
		}
		
		let text = "\(gameName)\n\nPlayer: \(session.player.name)\n\nTotal score = \(session.score), moves = \(session.moves.count)\nErrors = \(session.errors)\n\nComment: \(comment)\n\nTotal 1 (non-conflict time) = \(session.totalOne.integerValue), total 2 (conflict time) = \(session.totalTwo.integerValue); Ratio (game 2 + game 3 / game 1 + game 4) = \(roundRatio)\n\nSession started: \(dateString)\n\nBuild: \(build)\nImages: \(imageInfo)\n\nMoves:\n\n\(details)"
		return text
	}
	
	func generateVisualSustainLogWithSession(session: CounterpointingSession, gameName: String) -> String {
		var details = ""
		var counter = 0
		
		var spacePrinted = false
		for move in session.moves {
			let actualMove = move as! CounterpointingMove
			
			var append = ""
			var fourMistakes = ""
			if actualMove.poitionY == VisualSustainSkip.FourSkips.rawValue {
				fourMistakes = "[4 mistaken taps in a row]"
			}
			if actualMove.success.boolValue {
				
				let formattedDelay = String(format: "%.02f", actualMove.delay!.doubleValue)
				
				append = "picture \(actualMove.poitionX) - Success delay: \(formattedDelay) seconds \(fourMistakes)\n"
			} else {
				// Two mistakes type
				if (actualMove.interval == VisualSustainMistakeType.FalsePositive.rawValue) {
					append = "picture \(actualMove.poitionX) - False Positive \(fourMistakes)\n"
				} else if (actualMove.interval == VisualSustainMistakeType.Miss.rawValue) {
					append = "picture \(actualMove.poitionX) - Miss \(fourMistakes)\n"
				}
				
			}
			
			if !spacePrinted && !actualMove.inverted.boolValue { // Not training
				details = details + "\n" + append
				spacePrinted = true
			} else {
				details = details + append
			}
			counter++
		}
		
		let dateString = formatter.stringFromDate(session.dateStart)
		
		let comment = session.comment
		
		var build = "unknown"
		if let canonicBuild = session.bundleVersion as String? {
			build = canonicBuild
		}
		
		let exposure = session.speed.doubleValue
		let blank = session.vsustBlank!.doubleValue
		let interval = exposure + blank
		let objectsTotal = session.vsustObjects!.intValue
		let animalsTotal = session.vsustAnimals!.intValue
		
		let text = "\(gameName) (build \(build))\n\nPlayer: \(session.player.name)\nInterval = \(interval) exposure = \(exposure) blank = \(blank) accepted delay = \(session.vsustAcceptedDelay!.doubleValue)\nObjects = \(objectsTotal) animals = \(animalsTotal) (doesn't count while in training)\nTotal score = \(session.score) moves = \(session.moves.count)\nFalse positives = \(session.errors) Misses = \(session.vsustMiss!)\n\nComment: \(comment)\n\nSession started: \(dateString)\n\n\(details)"
		return text
	}
}
