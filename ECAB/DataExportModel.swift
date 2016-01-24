//
//  DataExportModel.swift
//  ECAB
//
//  The class will create CSV from CoreData
//
//  Creates CSV strings
//  Use this as example "Visual S,,,,,,,\n,,,,,,,,\nID,aaaaa,,,,,,,\nbirth,dd/mm/yy,,,\n"
//
//  Created by Boris Yurkevich on 21/12/2015.
//  Copyright © 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

private enum MoveType {
    case MoveTypeMotorOne
    case MoveTypeMotorTwo
    case MoveTypeMotorThree
    case MoveTypeSearchOne
    case MoveTypeSearchTwo
    case MoveTypeSearchThree
    case MoveTypeUnknown
}

class DataExportModel {
	
	let model = Model.sharedInstance
	var pickedVisualSearchSession: Session? = nil
	var pickedCounterpointingSession: CounterpointingSession? = nil
    let msIn1️⃣Sec = 1000.0 // Milliseconds in one second
    
    // Motor Total Hits:
    var mh1 = 0; var mh2 = 0; var mh3 = 0
    // Motor False Positives:
    var mfp1 = 0; var mfp2 = 0; var mfp3 = 0
    // Motor time total:
    var mt1:NSTimeInterval = 0; var mt2:NSTimeInterval = 0; var mt3:NSTimeInterval = 0
    // Search Total Hits:
    var sh1 = 0; var sh2 = 0; var sh3 = 0
    // Search False Positives:
    var sfp1 = 0; var sfp2 = 0; var sfp3 = 0
    // Search time total:
    var st1:NSTimeInterval = 0; var st2:NSTimeInterval = 0; var st3:NSTimeInterval = 0
	
	func export() -> String? {
		var returnValue: String? = nil
		
		switch model.data.selectedGame {
		case GamesIndex.VisualSearch.rawValue:
			returnValue = createVisualSearchTable()
			break
		default:
			break
		}
		
		return returnValue
	}
	
	func createVisualSearchTable() -> String {
		var returnValue = "empty line\n"
		
		if let visualSearchSession: Session = pickedVisualSearchSession {
			let gameName = model.games[Int(model.data.selectedGame)]
			let playerName = visualSearchSession.player.name
			let birth = "dd/MM/yy"
			let age = "yy/mm"
			
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "dd/MM/yy"
			let dateStart: String = dateFormatter.stringFromDate(visualSearchSession.dateStart)
			let timeFormatter = NSDateFormatter()
			timeFormatter.dateFormat = "HH:mm:ss:SSS"
			let timeStart = timeFormatter.stringFromDate(visualSearchSession.dateStart)
			
			var difficulty = "easy"
			if visualSearchSession.difficulty == Difficulty.Hard.rawValue {
				difficulty = "hard"
			}
			let speed = visualSearchSession.speed.doubleValue
			
			let comments = visualSearchSession.comment
			
			let screenComm = "*screen 3 should be blank throughout for 'hard' condition"
			let durationComm = "**set this to screen duration if it doesn't finish early"
			let header = "log of indivudual responces"
            
            // Create dynamic lines
            let dynamicLines = createDynamicLinesForVSSession(visualSearchSession)
            
            // Motor time total
            let totalMt = mt1 + mt2 + mt3
            let totSearch = st1 + st2 + st3
			
			returnValue = "\(gameName)             ,               ,              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
			              "ID                      ,\(playerName)  ,              ,               ,               ,               ,               \n" +
			              "date of birth           ,\(birth)       ,age at test   ,\(age)         ,               ,               ,               \n" +
						  "date/time of test start ,\(dateStart)   ,\(timeStart)  ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "parameters              ,\(difficulty)  ,              ,               ,\(speed) s     ,               ,               \n" +
						  "comments                ,\(comments)    ,              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "                        ,               ,motor 1       ,motor 2        ,motor 3        ,TOTAL          ,*              \n" +
						  "no of hits              ,               ,\(mh1)        ,\(mh2)         ,\(mh3)         ,               ,               \n" +
						  "no of false positives   ,               ,\(mfp1)       ,\(mfp2)        ,\(mfp3)        ,               ,               \n" +
 						  "total time              ,               ,\(r(mt1))     ,\(r(mt2))      ,\(r(mt3))      ,\(r(totalMt))  ,**             \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
					      "                        ,               ,search 1      ,search 2       ,search 3       ,               ,               \n" +
  						  "no of hits              ,               ,\(sh1)        ,\(sh2)         ,\(sh3)         ,               ,               \n" +
						  "no of false positives   ,               ,\(sfp1)       ,\(sfp2)        ,\(sfp3)        ,               ,               \n" +
						  "total time              ,               ,\(r(st1))     ,\(r(st2))      ,\(r(st3))      ,\(r(totSearch)),**             \n" +
			              "hits - false positives  ,               ,\(sh1 - sfp1) ,\(sh2 - sfp2)  ,\(sh3 - sfp3)  ,               ,               \n" +
  						  "                        ,\(screenComm)  ,              ,               ,               ,               ,               \n" +
						  "                        ,\(durationComm),              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "\(header)               ,               ,              ,               ,               ,               ,               \n" +
                          "                        ,               ,target row    ,target col     ,time           ,               ,               \n"
            
            // Append dynamic rows: headers and moves
            for line in dynamicLines {
                returnValue += line
            }
		}
		
		return returnValue
	}
    func r(x:NSTimeInterval) -> Double {
        return Double(round(msIn1️⃣Sec * x) / msIn1️⃣Sec)
    }
    func createDynamicLinesForVSSession(visualSearchSession: Session) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss:SSS"
        let sessionStarted = visualSearchSession.dateStart
        
        var currentSection:MoveType = .MoveTypeUnknown
        var timePassedSinceLatestMove = sessionStarted.timeIntervalSince1970
        for move in visualSearchSession.moves {
            let gameMove = move as! Move
            let screenNumber = gameMove.screenNumber.integerValue
            
            var ignoreThisMove = false
            switch screenNumber {
            case 0 ... 2, 11 ... 13:
                ignoreThisMove = true // Training
            default:
                break
            }
            if !ignoreThisMove {
                if gameMove.empty.boolValue == false {
                    // Success or failure
                    var sof = ""
                    if gameMove.success.boolValue == true {
                        sof = "hit"
                    } else {
                        sof = "false"
                    }
                    // ve / repeat
                    var veor = ""
                    if gameMove.`repeat`.boolValue == true {
                        veor = "repeat"
                    } else {
                        veor = "ve"
                    }
                    let moveTimestamp = timeFormatter.stringFromDate(gameMove.date)
                    let targetRow = gameMove.row
                    let targetColumn = gameMove.column
                    
                    // CSV line
                    let line = ",\(sof) \(veor), \(targetRow), \(targetColumn), \(moveTimestamp)\n"
                    collectionOfTableRows.append(line)
                    
                    // Time Interval
                    switch currentSection {
                    case .MoveTypeMotorOne:
                        if gameMove.success.boolValue == true {
                           mh1 += 1
                        } else {
                           mfp1 += 1
                        }
                        let secondsPassedForThisMove:NSTimeInterval = gameMove.date.timeIntervalSince1970 - timePassedSinceLatestMove
                        mt1 += secondsPassedForThisMove // increase total passed for this session's section
                    case .MoveTypeMotorTwo:
                        if gameMove.success.boolValue == true {
                            mh2 += 1
                        } else {
                            mfp2 += 1
                        }
                        let secondsPassedForThisMove:NSTimeInterval = gameMove.date.timeIntervalSince1970 - timePassedSinceLatestMove
                        mt2 += secondsPassedForThisMove
                    case .MoveTypeMotorThree:
                        if gameMove.success.boolValue == true {
                            mh3 += 1
                        } else {
                            mfp3 += 1
                        }
                        let secondsPassedForThisMove:NSTimeInterval = gameMove.date.timeIntervalSince1970 - timePassedSinceLatestMove
                        mt3 += secondsPassedForThisMove
                    case .MoveTypeSearchOne:
                        if gameMove.success.boolValue == true {
                            sh1 += 1
                        } else {
                            sfp1 += 1
                        }
                        let secondsPassedForThisMove:NSTimeInterval = gameMove.date.timeIntervalSince1970 - timePassedSinceLatestMove
                        st1 += secondsPassedForThisMove
                    case .MoveTypeSearchTwo:
                        if gameMove.success.boolValue == true {
                            sh2 += 1
                        } else {
                            sfp2 += 1
                        }
                        let secondsPassedForThisMove:NSTimeInterval = gameMove.date.timeIntervalSince1970 - timePassedSinceLatestMove
                        st2 += secondsPassedForThisMove
                    case .MoveTypeSearchThree:
                        if gameMove.success.boolValue == true {
                            sh3 += 1
                        } else {
                            sfp3 += 1
                        }
                        let secondsPassedForThisMove:NSTimeInterval = gameMove.date.timeIntervalSince1970 - timePassedSinceLatestMove
                        st3 += secondsPassedForThisMove
                    default:
                        break
                    }
                    // Increase the latest move date
                    timePassedSinceLatestMove = gameMove.date.timeIntervalSince1970
                } else {
                    var header = "header uknown"
                    switch screenNumber {
                    case 3:
                        header = "motor screen 1"
                        currentSection = .MoveTypeMotorOne
                    case 4:
                        header = "motor screen 2"
                        currentSection = .MoveTypeMotorTwo
                    case 5:
                        header = "motor screen 3"
                        currentSection = .MoveTypeMotorThree
                    case 14:
                        header = "motor screen 1"
                        currentSection = .MoveTypeSearchOne
                    case 15:
                        header = "motor screen 2"
                        currentSection = .MoveTypeSearchTwo
                    case 6:
                        header = "search screen 1"
                        currentSection = .MoveTypeSearchOne
                    case 7:
                        header = "search screen 2"
                        currentSection = .MoveTypeSearchTwo
                    case 8:
                        header = "search screen 3"
                        currentSection = .MoveTypeSearchThree
                    case 16:
                        header = "search screen 1"
                        currentSection = .MoveTypeSearchOne
                    case 17:
                        header = "search screen 2"
                        currentSection = .MoveTypeSearchTwo
                    default:
                        header = "wrong header number"
                    }
                    // Time
                    let headerTime = timeFormatter.stringFromDate(gameMove.date)
                    timePassedSinceLatestMove = gameMove.date.timeIntervalSince1970
                    
                    // CSV line
                    let headerLine = "\(header),screen onset, , ,\(headerTime)\n"
                    collectionOfTableRows.append(headerLine)
                }
            }
        }
        
        return collectionOfTableRows
    }
}

