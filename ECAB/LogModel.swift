//
//  LogModel.swift
//  ECAB
//
//  Created by Boris Yurkevich on 03/01/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreGraphics

class LogModel {
	
	let formatter = DateFormatter()
	let smallFormatter = DateFormatter()
	init() {
		formatter.dateFormat = "E, dd MMM yyyy HH:mm:ss:S"
		smallFormatter.dateFormat = "HH:mm:ss:S"
	}
	
	func generateVisualSearchLogWithSession(_ session: Session, gameName: String) -> String {
		var detailMoves = ""
		var counter = 1
		var emptyScreenCounter = 0
        
        let totals = ECABLogCalculator.getVisualSearchTotals(session)
        
		for move in session.moves {
			
			let gameMove = move as! Move
			
			// Caluculate screen
			var screenName = ""
			let screenNum = gameMove.screenNumber.intValue
            var trainig = false
            
			switch screenNum {
                
            case VisualSearchEasyModeView.trainingOne.rawValue ... VisualSearchEasyModeView.trainingThree.rawValue:
                
				screenName = "Training \(screenNum + 1)"
                trainig = true
                
            case VisualSearchHardModeView.trainingOne.rawValue ... VisualSearchHardModeView.trainingThree.rawValue:
                
                screenName = "Training \(screenNum - 10)"
                trainig = true
                
            case VisualSearchEasyModeView.motorOne.rawValue ... VisualSearchEasyModeView.motorThree.rawValue:
                
                screenName = "Motor \(screenNum - 2)"
                trainig = false
                
            case VisualSearchHardModeView.motorOne.rawValue, VisualSearchHardModeView.motorTwo.rawValue:

                screenName = "Motor \(screenNum - 13)"
                trainig = false

            case VisualSearchEasyModeView.one.rawValue ... VisualSearchEasyModeView.three.rawValue:
            
				screenName = "Search \(screenNum - 5)"
                trainig = false
			
            case VisualSearchHardModeView.one.rawValue, VisualSearchHardModeView.two.rawValue:
                
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
				progress = "false positive"
			}
			
			var `repeat` = ""
			if gameMove.`repeat`.boolValue == true {
				`repeat` = "(repeat)"
			} else {
				`repeat` = "(unique)"
			}
			
			let dateStr = smallFormatter.string(from: gameMove.date as Date)
			
			var append: String
			
			if gameMove.empty.boolValue == false {
				
                append = "\(counter)) \(screenName) Down: \(gameMove.row) Across: \(gameMove.column) \(dateStr) \(progress) \(`repeat`) \n"

				counter += 1
			} else {
                if (!trainig) {
                    append = "\n\(screenName) onset \(dateStr) \n"
                } else {
                    append = "\n\(screenName)\n"
                }
				emptyScreenCounter += 1
			}
			
			detailMoves = detailMoves + append
		}
		_ = session.dateStart.description
		let dateStr = formatter.string(from: session.dateStart as Date)
		
		var difficulty = "easy"
		if session.difficulty == Difficulty.hard.rawValue {
			difficulty = "hard"
		}
		
		let comment = session.comment
		
		var build = "unknown"
		if let canonicBuild = session.bundleVersion as String? {
			build = canonicBuild
		}
        
		let visualSearchLog = "\(gameName) \(difficulty) difficulty. \n\nPlayer name: \(session.player.name)\nExposure: \(session.speed.doubleValue)\n\nComment: \(comment)\n\nTotal score: \(session.score)\nFalse positives: \(session.failureScore)\n\nTime per target found[motor] = \(totals.average.motor)\nTime per target found[search] = \(totals.average.search)\nSearch time - motor time per target = \(totals.average.search - totals.average.motor)\n\nMotor 1 total = \(totals.motorOneTotal)\nMotor 2 total = \(totals.motorTwoTotal)\nMotor 3 total = \(totals.motorThreeTotal)\nSearch 1 total = \(totals.searchOneTotal)\nSearch 2 total = \(totals.searchTwoTotal)\nSearch 3 total = \(totals.searchThreeTotal)\n\nDetail moves:\n\nSession started: \(dateStr)\nBuild: \(build)\n\n\(detailMoves)"
		return visualSearchLog;
	}
	
	func generateCounterpointingLogWithSession(_ session: CounterpointingSession, gameName: String) -> String {
		var details = ""
		var counter = 1
		var status = "success"

		for move in session.moves {
			let actualMove = move as! CounterpointingMove
			if !actualMove.success.boolValue {
				status = "false positive"
			} else {
				status = "success"
			}
			
			var inverted = "non-conflict"
			if actualMove.inverted.boolValue {
				inverted = "conflict"
			}
            
            // Because I defined old interval as Integer I am changing it to Double
            // This condition is to keep old data working.
            var append: String
            if let newInterval = actualMove.intervalDouble as? Double {
                append = "\(counter)) \(status) screen:\(actualMove.poitionX) \(r(newInterval)) sec. \(inverted) \n"
            } else {
                append = "\(counter)) \(status) screen:\(actualMove.poitionX) \(actualMove.interval.intValue) sec. \(inverted) \n"
            }
            
            if actualMove.poitionX.doubleValue == Double(blankSpaceTag) {
                details = details + "\n"
            } else {
                details = details + append
            }
            
            counter += 1
		}
		
		let dateString = formatter.string(from: session.dateStart as Date)
				
		let comment = session.comment
		
		var build = "unknown"
		if let canonicBuild = session.bundleVersion as String? {
            build = canonicBuild
		}
		
        let result = ECABLogCalculator.getCounterpintingResult(session)
        let resultRatio = result.timeBlockConflict / result.timeBlockNonConflict
        let mediansRatio = result.conflictTimeMedian / result.nonConflictTimeMedian
        
		let text = "\(gameName)\n\n" + "Player: \(session.player.name)\n\n" +
            "Comment: \(comment)\n\nTotal score = \(session.score)\n" +
            "Screens = \(session.moves.count)\n" +
            "Errors = \(session.errors)\n\n" +
            "non-conflict (blocks 1)\n" +
            "total time 1 = \(r(result.timeBlockNonConflict)) sec. \n" +
            "mean reponse time 1 = \(r(result.nonConflictTimeMean)) sec. \n" +
            "median reponse time 1 = \(r(result.nonConflictTimeMedian)) sec." +
            "\n\n" +
            "conflict (blocks 2)\n" +
            "total time 2 = \(r(result.timeBlockConflict)) sec. \n" +
            "mean reponse time 2 = \(r(result.conflictTimeMean)) sec. \n" +
            "median reponse time 2 = \(r(result.conflictTimeMedian)) sec." +
            "\n\n" +
            "ratio total2 / total1  = \(r(resultRatio)) sec. \n" +
            "ratio median2 / median1 = \(r(mediansRatio)) sec." +
            "\n\n" +
            "Session started: \(dateString)\n\n" +
            "Build: \(build)\n" +
            "Moves:\n\n\(details)"
		return text
	}
	
	func generateFlankerLogWithSession(_ session: CounterpointingSession, gameName: String) -> String {
		var details = ""
		var counter = 1
		var status = "success"
		for move in session.moves {
			let actualMove = move as! CounterpointingMove
			if !actualMove.success.boolValue {
				status = "false positive"
			} else {
				status = "success"
			}
			
			var inverted = "non-conflict"
			if actualMove.inverted.boolValue {
				inverted = "conflict"
			}
			
            var append: String
            if let newInterval = actualMove.intervalDouble as? Double {
                append = "\(counter)) \(status) screen: \(actualMove.poitionX) \(r(newInterval)) s. \(inverted) \n"
            } else {
                // Because I defined old interval as Integer I am chaning it to Double
                // This condition is to keep old data working.
                append = "\(counter)) \(status) screen: \(actualMove.poitionX) \(actualMove.interval) s. \(inverted) \n"
            }
            counter += 1
            
            if session.type.intValue == SessionType.flanker.rawValue {
            
                if actualMove.poitionX.doubleValue == Double(blankSpaceTag) {
                    details = details + append + "\n"
                } else {
                    details = details + append
                }
            } else if session.type.intValue == SessionType.flankerRandomized.rawValue {
            
                switch actualMove.poitionX {
                case 21:
                    details = details + "\n"
                    
                default:
                    details = details + append
                }
            }
		}
		
		let dateString = formatter.string(from: session.dateStart as Date)
		
		let comment = session.comment
		
		var build = "unknown"
		if let definedBuild = session.bundleVersion as String? {
			build = definedBuild
		}
		
		var imageInfo = "uknown"
		if let definedImageInfo = session.imageSizeComment as String? {
			imageInfo = definedImageInfo
		}
    
        let result = ECABLogCalculator.getFlankerResult(session)
        let ratio = result.conflictTime / result.nonConflictTime
        
        var text = ""
        
        if session.type.intValue == SessionType.flanker.rawValue {
        
            text = "\(gameName)\n\n" +
                "Player: \(session.player.name)\n\n" +
                "Total score = \(session.score), moves = \(session.moves.count)\n" +
                "Errors = \(session.errors)\n\n" +
                "Comment: \(comment)\n\n" +
                "Total 1 (non-conflict time) = \(r(result.nonConflictTime))\n" +
                "total 2 (conflict time) = \(r(result.conflictTime))\n" +
                "Ratio (block 2 + block 3 / block 1 + block 4) = \(r(ratio))\n\n" +
                "Conflict time mean = \(r(result.conflictTimeMean))\n" +
                "Conflict median = \(r(result.conflictTimeMedian))\n" +
                "Conflict time standard deviation = \(r(result.conflictTimeStandardDeviation))\n" +
                "Non conflict time mean = \(r(result.nonConflictTimeMean))\n" +
                "Non conflict median = \(r(result.nonConflictTimeMedian))\n" +
                "Non conflict time standard deviation = \(r(result.nonConflictTimeStandardDeviation))\n\n" +
                "Session started: \(dateString)\n\n" +
                "Build: \(build)\n" +
                "Images: \(imageInfo)\n\n" +
                "Moves:\n\n\(details)"
            
        } else if session.type.intValue == SessionType.flankerRandomized.rawValue {
            
            text = "\(gameName) Randomized.\n\n" +
                "Player: \(session.player.name)\n\n" +
                "Total score = \(session.score), moves = \(session.moves.count)\n" +
                "Errors = \(session.errors)\n\n" +
                "Comment: \(comment)\n\n" +
                "Total 1 (non-conflict time) = \(r(result.nonConflictTime))\n" +
                "total 2 (conflict time) = \(r(result.conflictTime))\n" +
                "Ratio (conflict / non-conflcit) = \(r(ratio))\n\n" +
                "Conflict time mean = \(r(result.conflictTimeMean))\n" +
                "Conflict median = \(r(result.conflictTimeMedian))\n" +
                "Conflict time standard deviation = \(r(result.conflictTimeStandardDeviation))\n" +
                "Non conflict time mean = \(r(result.nonConflictTimeMean))\n" +
                "Non conflict median = \(r(result.nonConflictTimeMedian))\n" +
                "Non conflict time standard deviation = \(r(result.nonConflictTimeStandardDeviation))\n\n" +
                "Session started: \(dateString)\n\n" +
                "Build: \(build)\n" +
                "Images: \(imageInfo)\n\n" +
                "Moves:\n\n\(details)"
        }
        
		return text
	}
	
	func generateVisualSustainLogWithSession(_ session: CounterpointingSession, gameName: String) -> String {
		var details = ""
		var counter = 1
		
		var spacePrinted = false
		for move in session.moves {
			let actualMove = move as! CounterpointingMove
			
			var append = ""
			var fourMistakes = ""
			if actualMove.poitionY.doubleValue == Double(VisualSustainSkip.fourSkips.rawValue) {
				fourMistakes = "[4 mistaken taps in a row]"
			}
			if actualMove.success.boolValue {
				
				let formattedDelay = String(format: "%.02f", actualMove.delay!.doubleValue)
				
				append = "picture \(actualMove.poitionX) - Success delay: \(formattedDelay) seconds \(fourMistakes)\n"
			} else {
				// Two mistakes type
				if (actualMove.interval.doubleValue == VisualSustainMistakeType.falsePositive.rawValue) {
					append = "picture \(actualMove.poitionX) - False Positive \(fourMistakes)\n"
				} else if (actualMove.interval.doubleValue == VisualSustainMistakeType.miss.rawValue) {
					append = "picture \(actualMove.poitionX) - Miss \(fourMistakes)\n"
				}
				
			}
			
			if !spacePrinted && !actualMove.inverted.boolValue { // Not training
				details = details + "\n" + append
				spacePrinted = true
			} else {
				details = details + append
			}
			counter += 1
		}
		
		let dateString = formatter.string(from: session.dateStart as Date)
		
		let comment = session.comment
		
		var build = "unknown"
		if let canonicBuild = session.bundleVersion as String? {
			build = canonicBuild
		}
		
		let exposure = session.speed.doubleValue
		let blank = session.vsustBlank!.doubleValue
		let interval = exposure + blank
		let objectsTotal = session.vsustObjects!.int32Value
		let animalsTotal = session.vsustAnimals!.int32Value
		
		let text = "\(gameName) (build \(build))\n\n" +
        "Player: \(session.player.name)\n" +
        "Interval = \(interval) exposure = \(exposure) " +
        "blank = \(blank) " +
        "accepted delay = \(session.vsustAcceptedDelay!.doubleValue)\n" +
        "Objects = \(objectsTotal) animals = \(animalsTotal) (doesn't count while in training)\n" +
        "Total score = \(session.score) moves = \(session.moves.count)\n" +
        "False positives = \(session.errors) Misses = \(session.vsustMiss!)\n\n" +
        "Comment: \(comment)\n\n" +
        "Session started: \(dateString)\n\n" +
        "\(details)"
        
		return text
	}
}
