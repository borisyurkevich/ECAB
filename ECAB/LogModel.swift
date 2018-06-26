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
        
		let visualSearchLog =
        """
        \(gameName) \(difficulty) difficulty.
        
        Player name: \(session.player.name)
        Exposure: \(session.speed.doubleValue)
        
        Comment: \(comment)
        
        Total score: \(session.score)
        False positives: \(session.failureScore)
        
        Time per target found[motor] = \(totals.average.motor)
        Time per target found[search] = \(totals.average.search)
        Search time - motor time per target = \(totals.average.search - totals.average.motor)
        
        Motor 1 total = \(totals.motorOneTotal)
        Motor 2 total = \(totals.motorTwoTotal)
        Motor 3 total = \(totals.motorThreeTotal)
        Search 1 total = \(totals.searchOneTotal)
        Search 2 total = \(totals.searchTwoTotal)
        Search 3 total = \(totals.searchThreeTotal)
        Detail moves:\n\nSession started: \(dateStr)
        
        Build: \(build)
        
        
        \(detailMoves)
        """
		return visualSearchLog;
	}
    
    /// Line by line creates log entry for every game move
    func buildCounterpointStyleDetails(session: CounterpointingSession) -> String {
        var details = ""
        var realScreenNumber: Int = 1
        var previous: Int = 0
        
        for move in session.moves {
            let actualMove = move as! CounterpointingMove
            
            if actualMove.poitionX.doubleValue == Double(blankSpaceTag) {
                // Blank Line.
                details = details + "\n"
            } else {
                let status: String
                if actualMove.success.boolValue {
                    status = "success"
                } else {
                    status = "false positive"
                }
                
                let inverted: String
                if actualMove.inverted.boolValue {
                    inverted = "conflict"
                } else {
                    inverted = "non-conflict"
                }
                let screen: String
                if realScreenNumber == previous {
                    screen = realScreenNumber > 9 ? "   " : "  " // indentation
                } else {
                    screen = "\(realScreenNumber))"
                }
                let append: String
                if let newInterval = actualMove.intervalDouble as? Double {
                    append = "\(screen) \(status) \(r(newInterval)) s. \(inverted) index \(actualMove.poitionX.intValue)\n"
                } else {
                    // Because I defined old interval as Integer I am changing it to Double
                    // This condition is to keep old data working.
                    append = "\(screen) \(status) \(actualMove.interval.intValue) s. \(inverted) index \(actualMove.poitionX.intValue)\n"
                }
                details = details + append
                
                previous = realScreenNumber
                
                if actualMove.success.boolValue == true {
                    realScreenNumber += 1
                }
                if let gameType = SessionType(rawValue: session.type.intValue) {
                    let index = Model.testStartScreen(gameType: gameType)
                    if actualMove.poitionX.intValue == index {
                        // Reset
                        realScreenNumber = 1
                    }
                }
            }
        }
        return details
    }
	
	func generateCounterpointingLogWithSession(_ session: CounterpointingSession, gameName: String) -> String {
		
		let dateString = formatter.string(from: session.dateStart as Date)
				
		let comment = session.comment
		
		var build = "unknown"
		if let canonicBuild = session.bundleVersion as String? {
            build = canonicBuild
		}
		
        let result = ECABLogCalculator.getCounterpintingResult(session)
        
        guard let data = result.result else {
            let error: String
            if let custom = result.error {
                error = custom
            } else {
                error = "Critical Error. Couldn't create this log, sorry."
            }
            return error
        }
        
        let meanRatio = data.conflictTimeMean / data.nonConflictTimeMean
        let mediansRatio = data.conflictTimeMedian / data.nonConflictTimeMedian
        let timeRatio = data.timeBlockConflict / data.timeBlockNonConflict
        
        let details = buildCounterpointStyleDetails(session: session)
        
		let text =
        """
        \(gameName)
        Player: \(session.player.name)
        Comment: \(comment)
        Total score = \(session.score)
        Screens = \(session.moves.count)
        Errors = \(session.errors)
        
        Non-conflict (blocks 1)
        Total time 1 = \(r(data.timeBlockNonConflict)) s.
        Mean response time 1 = \(r(data.nonConflictTimeMean)) s.
        Median response time 1 = \(r(data.nonConflictTimeMedian)) s.
        
        Conflict (blocks 2)
        Total time 2 = \(r(data.timeBlockConflict)) s.
        Mean response time 2 = \(r(data.conflictTimeMean)) s.
        Median response time 2 = \(r(data.conflictTimeMedian)) s.
        
        Mean ratio (conflict / non-conflict) = \(r(meanRatio)) s.
        Median ratio = \(r(mediansRatio)) s.
        Total time ratio = \(r(timeRatio)) s.

        Session started: \(dateString)
        
        Build: \(build)
        Moves:
        
        \(details)
        """
		return text
	}
    
	func generateFlankerLogWithSession(_ session: CounterpointingSession, gameName: String) -> String {
		
		let dateString = formatter.string(from: session.dateStart as Date)
		
		let comment = session.comment
		
		var build = "unknown"
		if let definedBuild = session.bundleVersion as String? {
			build = definedBuild
		}
		
		var imageInfo = "unknown"
		if let definedImageInfo = session.imageSizeComment as String? {
			imageInfo = definedImageInfo
		}
    
        guard let result = ECABLogCalculator.getFlankerResult(session).result else {
            return "Couldn't create log. \(ECABLogCalculator.getFlankerResult(session).error ?? "")"
        }
        
        let meanRatio = result.conflictTimeMean / result.nonConflictTimeMean
        let mediansRatio = result.conflictTimeMedian / result.nonConflictTimeMedian
        let timeRatio = result.conflictTime / result.nonConflictTime
        
        let firstLine: String
        if session.type.intValue == SessionType.flankerRandomized.rawValue {
            firstLine = "\(gameName) Randomised"
        } else {
            firstLine = "\(gameName)"
        }
        
        let details = buildCounterpointStyleDetails(session: session)
        
        let text =
        """
        \(firstLine)
        Player: \(session.player.name)
        Total score = \(session.score), moves = \(session.moves.count)
        Errors = \(session.errors)
        Comment: \(comment)
        
        Total 1 non-conflict time = \(r(result.nonConflictTime))
        Total 2 conflict time = \(r(result.conflictTime))
        Mean ratio (conflict / non-conflict) = \(r(meanRatio)) s.
        Median ratio = \(r(mediansRatio)) s.
        Total time ratio = \(r(timeRatio)) s.
        Conflict time mean = \(r(result.conflictTimeMean))
        Conflict median = \(r(result.conflictTimeMedian))
        Conflict time standard deviation = \(r(result.conflictTimeStandardDeviation))
        Non conflict time mean = \(r(result.nonConflictTimeMean))
        Non conflict median = \(r(result.nonConflictTimeMedian))
        Non conflict time standard deviation = \(r(result.nonConflictTimeStandardDeviation))
        
        Session started: \(dateString)
        
        Build: \(build)
        Images: \(imageInfo)
        
        Moves:\n\n\(details)
        """
        
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
				if (actualMove.interval.doubleValue == VisualSustainMistakeType.falsePositive.rawValue) {
					append = "picture \(actualMove.poitionX) - False Positive \(fourMistakes)\n"
				} else if (actualMove.interval.doubleValue == VisualSustainMistakeType.miss.rawValue) {
					append = "picture \(actualMove.poitionX) - Miss \(fourMistakes)\n"
                } else if (actualMove.interval.doubleValue == VisualSustainMistakeType.repeated.rawValue) {
                    append = "picture \(actualMove.poitionX) - repeat\n"
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
		
		let text = """
        \(gameName) (build \(build))
        
        Player: \(session.player.name)
        Interval = \(interval) exposure = \(exposure) blank = \(blank)
        accepted delay = \(session.vsustAcceptedDelay!.doubleValue)
        Objects = \(objectsTotal) animals = \(animalsTotal) (doesn't count while in training)
        Total score = \(session.score)
        moves = \(session.moves.count)
        
        False positives = \(session.errors) Misses = \(session.vsustMiss!)
        Comment: \(comment)
        
        Session started: \(dateString)
        
        \(details)
        """
        
		return text
	}
}
