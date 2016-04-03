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
    
    init() {
        gameName = model.games[Int(model.data.selectedGame)]
        birth = "dd/MM/yy"
        age = "yy/mm"
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        timeFormatter.dateFormat = "HH:mm:ss:SSS"
    }
    private let gameName: String
    private let birth: String
    private let age: String
    private let dateFormatter = NSDateFormatter()
    private let timeFormatter = NSDateFormatter()
    private var returnValue = "empty line\n"
    
	func export() -> String? {
		var returnValue: String? = nil
		
		switch model.data.selectedGame {
		case GamesIndex.VisualSearch.rawValue:
			returnValue = createVisualSearchTable()
        case GamesIndex.Flanker.rawValue:
            returnValue = createFlankerTable()
		default:
			break
		}
		
		return returnValue
	}
    
    
    func createFlankerTable() -> String {
        
        if let session: CounterpointingSession = pickedCounterpointingSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.stringFromDate(session.dateStart)
            let timeStart = timeFormatter.stringFromDate(session.dateStart)
            
            let comments = session.comment
            var imageInfo = "uknown image size"
            if let definedImageInfo = session.imageSizeComment as String? {
                imageInfo = definedImageInfo
            }
            
            let rows = createFlankerLines(session)
            let t = ECABLogCalculator.getFlankerResult(session)
            
            let ratio = t.conflictTime / t.nonConflictTime
            let mediansRatio = t.conflictTimeMedian / t.nonConflictTimeMedian
            
            returnValue = "ECAB Test               ,\(gameName)    ,                       ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "ID                      ,\(playerName)  ,                       ,                      ,                       ,               ,    \n" +
                          "date of birth           ,\(birth)       ,age at test            ,\(age)                ,                       ,               ,    \n" +
                          "date/time of test start ,\(dateStart)   ,\(timeStart)           ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "parameters              ,\(imageInfo)   ,                       ,                      ,                       ,               ,    \n" +
                          "comments                ,\(comments)    ,                       ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "non-conflict (blocks 1+4),               ,                      ,                      ,                       ,               ,    \n" +
                          "total time block 1 =    ,\(r(t.timeBlock1)),msec                ,                      ,                       ,               ,    \n" +
                          "total time block 4 =    ,\(r(t.timeBlock4)),msec                ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "total time blocks 1+4 = ,\(r(t.nonConflictTime)),msec           ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "mean reponse time 1+4 = ,\(r(t.nonConflictTimeMean)),msec       ,                      ,                       ,               ,    \n" +
                          "median reponse time 1+4 =,\(r(t.nonConflictTimeMedian)),msec    ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "conflicts (blocks 2+3),               ,                         ,                      ,                       ,               ,    \n" +
                          "total time block 2 =    ,\(r(t.timeBlock2)),msec                ,                      ,                       ,               ,    \n" +
                          "total time block 3 =    ,\(r(t.timeBlock3)),msec                ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "total time blocks 2+3 = ,\(r(t.conflictTime)),msec              ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "mean reponse time 2+3 = ,\(r(t.conflictTimeMean)),msec          ,                      ,                       ,               ,    \n" +
                          "median reponse time 2+3 =,\(r(t.conflictTimeMedian)),msec       ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "ratio conflict/non-conflict total = ,\(r(ratio)),               ,                      ,                       ,               ,    \n" +
                          "ratio of medians conflict/non-conflict total = ,\(r(mediansRatio)),                    ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "log of individual responses,            ,                       ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n"
            
            // Append dynamic rows: headers and moves
            for line in rows {
                returnValue += line
            }
        }
        
        return returnValue;
    }
    
    private func createFlankerLines(session: CounterpointingSession) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var headerCount = 0
        var screenCount = 1
        
        for move in session.moves {
            let gameMove = move as! CounterpointingMove

            if gameMove.poitionX != blankSpaceTag {
                // Success or failure
                var sof = ""
                if gameMove.success.boolValue == true {
                    sof = "correct"
                } else {
                    sof = "incorrect"
                }

                var time: Double
                if let newInterval = gameMove.intervalDouble as? Double {
                    time = r(newInterval)
                } else {
                    // Because I defined old interval as Integer I am chaning it to Double
                    // This condition is to keep old data working.
                    time = gameMove.interval.doubleValue
                }
                
                // CSV line
                let line = ",\(screenCount),\(sof), \(time), msec, , ,\n"
                collectionOfTableRows.append(line)
                
                screenCount += 1
                
            } else {
                var header = "header uknown"
                
                switch headerCount {
                case 0:
                    header = "non-conflict block 1"
                case 1:
                    header = "conflict block 2"
                case 2:
                    header = "conflict block 3"
                case 3:
                    header = "non-conflict block 4"
                default:
                    header = "header error"
                }
                headerCount += 1
                
                // CSV line
                let headerLine = "\(header),screen,response,time, , ,\n"
                collectionOfTableRows.append(headerLine)
            }
        }
        
        return collectionOfTableRows
    }
	
	func createVisualSearchTable() -> String {
		
		if let visualSearchSession: Session = pickedVisualSearchSession {
			let playerName = visualSearchSession.player.name
			
			let dateStart: String = dateFormatter.stringFromDate(visualSearchSession.dateStart)
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
            let t = ECABLogCalculator.getVisualSearchTotals(visualSearchSession)
            let avg = t.average
            
            let mht = t.motorHits1 + t.motorHits2 + t.motorHits3
            let mfpt = t.motorFalse1 + t.motorFalse2 + t.motorFalse3
            // Motor time total
            let mtt = t.motorOneTotal + t.motorTwoTotal + t.motorThreeTotal
            // Search time total
            let stt = t.searchOneTotal + t.searchTwoTotal + t.searchThreeTotal
            // Search total hits
            let sht = t.searchHits1 + t.searchHits2 + t.searchHits3
            // Search false positives
            let sfpt = t.searchFalse1 + t.searchFalse2 + t.searchFalse3
            let searchDiff1 = t.searchHits1 - t.searchFalse1
            let searchDiff2 = t.searchHits2 - t.searchFalse2
            let searchDiff3 = t.searchHits3 - t.searchFalse3
            
            let avgMotor = "Time per target found [motor]"
            let avgSearch = "Time per target found [search]"
            let avgDiff = "Search time - motor time per target"
            let avgDiffVal = avg.search - avg.motor
			
			returnValue = "\(gameName)             ,               ,                       ,                      ,                       ,               ,    \n" +
						  "                        ,               ,                       ,                      ,                       ,               ,    \n" +
			              "ID                      ,\(playerName)  ,                       ,                      ,                       ,               ,    \n" +
			              "date of birth           ,\(birth)       ,age at test            ,\(age)                ,                       ,               ,    \n" +
						  "date/time of test start ,\(dateStart)   ,\(timeStart)           ,                      ,                       ,               ,    \n" +
						  "                        ,               ,                       ,                      ,                       ,               ,    \n" +
						  "parameters              ,\(difficulty)  ,                       ,                      ,\(speed) s             ,               ,    \n" +
						  "comments                ,\(comments)    ,                       ,                      ,                       ,               ,    \n" +
						  "                        ,               ,                       ,                      ,                       ,               ,    \n" +
						  "                        ,               ,                       ,                      ,                       ,               ,    \n" +
						  "                        ,               ,motor 1                ,motor 2               ,motor 3                ,TOTAL          ,*   \n" +
						  "no of hits              ,               ,\(t.motorHits1)        ,\(t.motorHits2)       ,\(t.motorHits3)        ,\(mht)         ,    \n" +
						  "no of false positives   ,               ,\(t.motorFalse1)       ,\(t.motorFalse2)      ,\(t.motorFalse3)       ,\(mfpt)        ,    \n" +
 						  "total time              ,               ,\(r(t.motorOneTotal))  ,\(r(t.motorTwoTotal)) ,\(r(t.motorThreeTotal)),\(r(mtt))      ,**  \n" +
						  "                        ,               ,                       ,                      ,                       ,               ,    \n" +
						  "                        ,               ,                       ,                      ,                       ,               ,    \n" +
					      "                        ,               ,search 1               ,search 2              ,search 3               ,               ,    \n" +
  						  "no of hits              ,               ,\(t.searchHits1)       ,\(t.searchHits2)      ,\(t.searchHits3)       ,\(sht)         ,    \n" +
						  "no of false positives   ,               ,\(t.searchFalse1)      ,\(t.searchFalse2)     ,\(t.searchFalse3)      ,\(sfpt)        ,    \n" +
						  "total time              ,               ,\(r(t.searchOneTotal)) ,\(r(t.searchTwoTotal)),\(r(t.searchThreeTotal)),\(r(stt))      ,**  \n" +
			              "hits - false positives  ,               ,\(searchDiff1)         ,\(searchDiff2)        ,\(searchDiff3)         ,\(sht-sfpt)    ,    \n" +
  						  "                        ,\(screenComm)  ,                       ,                      ,                       ,               ,    \n" +
						  "                        ,\(durationComm),                       ,                      ,                       ,               ,    \n" +
						  "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "\(avgMotor)             ,\(avg.motor)   ,                       ,                      ,                       ,               ,    \n" +
                          "\(avgSearch)            ,\(avg.search)  ,                       ,                      ,                       ,               ,    \n" +
                          "\(avgDiff)              ,\(avgDiffVal)  ,                       ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
						  "\(header)               ,               ,                       ,                      ,                       ,               ,    \n" +
                          "                        ,               ,target row             ,target col            ,time                   ,               ,    \n"
            
            // Append dynamic rows: headers and moves
            for line in dynamicLines {
                returnValue += line
            }
		}
		
		return returnValue
	}
//    func r(x:NSTimeInterval) -> Double {
//        return Double(round(msIn1️⃣Sec * x) / msIn1️⃣Sec)
//    }
    func createDynamicLinesForVSSession(visualSearchSession: Session) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        
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
                    
                } else {
                    var header = "header uknown"
                    switch screenNumber {
                    case VisualSearchEasyModeView.MotorOne.rawValue:
                        header = "motor screen 1"
                    case VisualSearchEasyModeView.MotorTwo.rawValue:
                        header = "motor screen 2"
                    case VisualSearchEasyModeView.MotorThree.rawValue:
                        header = "motor screen 3"
                    case VisualSearchHardModeView.MotorOne.rawValue:
                        header = "motor screen 1"
                    case VisualSearchHardModeView.MotorTwo.rawValue:
                        header = "motor screen 2"
                    case VisualSearchEasyModeView.One.rawValue:
                        header = "search screen 1"
                    case VisualSearchEasyModeView.Two.rawValue:
                        header = "search screen 2"
                    case VisualSearchEasyModeView.Three.rawValue:
                        header = "search screen 3"
                    case VisualSearchHardModeView.One.rawValue:
                        header = "search screen 1"
                    case VisualSearchHardModeView.Two.rawValue:
                        header = "search screen 2"
                    default:
                        header = "wrong header number"
                    }
                    // Time
                    let headerTime = timeFormatter.stringFromDate(gameMove.date)
                    
                    // CSV line
                    let headerLine = "\(header),screen onset, , ,\(headerTime)\n"
                    collectionOfTableRows.append(headerLine)
                }
            }
        }
        
        return collectionOfTableRows
    }
}

