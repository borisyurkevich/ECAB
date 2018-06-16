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
import CoreGraphics

private enum MoveType {
    case moveTypeMotorOne
    case moveTypeMotorTwo
    case moveTypeMotorThree
    case moveTypeSearchOne
    case moveTypeSearchTwo
    case moveTypeSearchThree
    case moveTypeUnknown
}

class DataExportModel {
	
    var pickedVisualSearchSession: Session? = nil
    var pickedCounterpointingSession: CounterpointingSession? = nil
    
	private let model = Model.sharedInstance
    private let msInOneSec = 1000.0 // Milliseconds in one second
    private let gameName: String
    private let birth: String
    private let age: String
    private let dateFormatter = DateFormatter()
    private let timeFormatter = DateFormatter()
    private var returnValue = "empty line\n"
    
    init() {
        gameName = model.games[model.data.selectedGame.intValue]
        birth = "dd/MM/yy"
        age = "yy/mm"
        dateFormatter.dateStyle = DateFormatter.Style.short
        timeFormatter.dateFormat = "HH:mm:ss:SSS"
    }
    
	func export() -> String? {
		var returnValue: String? = nil
		
		switch model.data.selectedGame {
		case GamesIndex.visualSearch.rawValue:
			returnValue = createVisualSearchTable()
        case GamesIndex.counterpointing.rawValue:
            returnValue = createCounterpointingTable()
        case GamesIndex.flanker.rawValue:
        
            if pickedCounterpointingSession?.type.intValue == SessionType.flanker.rawValue {
                returnValue = createFlankerTable()
            } else if pickedCounterpointingSession?.type.intValue == SessionType.flankerRandomized.rawValue {
                returnValue = createFlankerRandomTable()
            }
        
        case GamesIndex.visualSust.rawValue:
            returnValue = createVisualSustainedTable()
		default:
			break
		}
		
		return returnValue
	}
    
    func createVisualSearchTable() -> String {
        
        if let visualSearchSession: Session = pickedVisualSearchSession {
            let playerName = visualSearchSession.player.name
            
            let dateStart: String = dateFormatter.string(from: visualSearchSession.dateStart as Date)
            let timeStart = timeFormatter.string(from: visualSearchSession.dateStart as Date)
            
            var difficulty = "easy"
            if visualSearchSession.difficulty == Difficulty.hard.rawValue {
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
    
    func createCounterpointingTable() -> String {
        
        if let session: CounterpointingSession = pickedCounterpointingSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.string(from: session.dateStart as Date)
            let timeStart = timeFormatter.string(from: session.dateStart as Date)
            
            let comments = session.comment
            
            let rows = createCounterpointinLines(session)
            let t = ECABLogCalculator.getCounterpintingResult(session)
            
            let ratio = t.timeBlockConflict / t.timeBlockNonConflict
            let mediansRatio = t.conflictTimeMedian / t.nonConflictTimeMedian
            
            returnValue = "ECAB Test     ,\(gameName)    ,                      ,                      ,                       ,               ,    \n" +
                "                        ,               ,                      ,                      ,                       ,               ,    \n" +
                "ID                      ,\(playerName)  ,                      ,                      ,                       ,               ,    \n" +
                "date of birth           ,\(birth)       ,age at test           ,\(age)                ,                       ,               ,    \n" +
                "date/time of test start ,\(dateStart)   ,\(timeStart)          ,                      ,                       ,               ,    \n" +
                "                        ,               ,                      ,                      ,                       ,               ,    \n" +
                "comments                ,\(comments)    ,                      ,                      ,                       ,               ,    \n" +
                "                        ,               ,                      ,                      ,                       ,               ,    \n" +
                "non-conflict (blocks 1) ,               ,                      ,                      ,                       ,               ,    \n" +
                "total time 1 =          ,\(r(t.timeBlockNonConflict)),sec      ,                      ,                       ,               ,    \n" +
                "mean response time 1 =   ,\(r(t.nonConflictTimeMean)),sec       ,                      ,                       ,               ,    \n" +
                "median response time 1 = ,\(r(t.nonConflictTimeMedian)),sec     ,                      ,                       ,               ,    \n" +
                "                        ,               ,                      ,                      ,                       ,               ,    \n" +
                "conflict (blocks 2)     ,               ,                      ,                      ,                       ,               ,    \n" +
                "total time 2 =          ,\(r(t.timeBlockConflict)),sec         ,                      ,                       ,               ,    \n" +
                "mean response time 2 =   ,\(r(t.conflictTimeMean)),sec          ,                      ,                       ,               ,    \n" +
                "median response time 2 = ,\(r(t.conflictTimeMedian)),sec        ,                      ,                       ,               ,    \n" +
                "                         ,               ,                     ,                      ,                       ,               ,    \n" +
                "ratio total2 / total1  = ,\(r(ratio))    ,                     ,                      ,                       ,               ,    \n" +
                "ratio median2 / median1 =,\(r(mediansRatio)),                  ,                     ,                        ,               ,    \n" +
                "                        ,               ,                      ,                      ,                       ,               ,    \n" +
                "log of individual responses,            ,                      ,                      ,                       ,               ,    \n" +
                "                        ,               ,                      ,                      ,                       ,               ,    \n"
            
            // Append dynamic rows: headers and moves
            for line in rows {
                returnValue += line
            }
        }
        
        return returnValue;
    }
    
    func createFlankerTable() -> String {
        
        if let session: CounterpointingSession = pickedCounterpointingSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.string(from: session.dateStart as Date)
            let timeStart = timeFormatter.string(from: session.dateStart as Date)
            
            let comments = session.comment
            var imageInfo = "unknown image size"
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
                          "total time block 1 =    ,\(r(t.timeBlock1)),sec                 ,                      ,                       ,               ,    \n" +
                          "total time block 4 =    ,\(r(t.timeBlock4)),sec                 ,                      ,                       ,               ,    \n" +
                          "total time blocks 1+4 = ,\(r(t.nonConflictTime)),sec            ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "mean response time 1+4 = ,\(r(t.nonConflictTimeMean)),sec        ,                      ,                       ,               ,    \n" +
                          "median response time 1+4 =,\(r(t.nonConflictTimeMedian)),sec     ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "conflicts (blocks 2+3),               ,                         ,                      ,                       ,               ,    \n" +
                          "total time block 2 =    ,\(r(t.timeBlock2)),sec                 ,                      ,                       ,               ,    \n" +
                          "total time block 3 =    ,\(r(t.timeBlock3)),sec                 ,                      ,                       ,               ,    \n" +
                          "total time blocks 2+3 = ,\(r(t.conflictTime)),sec               ,                      ,                       ,               ,    \n" +
                          "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                          "mean response time 2+3 = ,\(r(t.conflictTimeMean)),sec           ,                      ,                       ,               ,    \n" +
                          "median response time 2+3 =,\(r(t.conflictTimeMedian)),sec        ,                      ,                       ,               ,    \n" +
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
    
    func createFlankerRandomTable() -> String {
        
        if let session: CounterpointingSession = pickedCounterpointingSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.string(from: session.dateStart as Date)
            let timeStart = timeFormatter.string(from: session.dateStart as Date)
            
            let comments = session.comment
            var imageInfo = "unknown image size"
            if let definedImageInfo = session.imageSizeComment as String? {
                imageInfo = definedImageInfo
            }
            
            let rows = createFlankerRandomLines(session)
            let t = ECABLogCalculator.getFlankerResult(session)
            
            let ratio = t.conflictTime / t.nonConflictTime
            let mediansRatio = t.conflictTimeMedian / t.nonConflictTimeMedian
            
            returnValue = "ECAB Test               ,\(gameName)    ,Randomized   ,                      ,                       ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "ID                      ,\(playerName)  ,                       ,                      ,                       ,               ,    \n" +
                "date of birth           ,\(birth)       ,age at test            ,\(age)                ,                       ,               ,    \n" +
                "date/time of test start ,\(dateStart)   ,\(timeStart)           ,                      ,                       ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "parameters              ,\(imageInfo)   ,                       ,                      ,                       ,               ,    \n" +
                "comments                ,\(comments)    ,                       ,                      ,                       ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "total non-conflict time =,\(r(t.nonConflictTime)),sec           ,                      ,                       ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "mean response time non conflict =,\(r(t.nonConflictTimeMean)),sec,                      ,                       ,               ,    \n" +
                "median response time non conflict =,\(r(t.nonConflictTimeMedian)),sec ,                 ,                       ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "total conflict time =   ,\(r(t.conflictTime)),sec               ,                      ,                       ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "mean response time conflict =,\(r(t.conflictTimeMean)),sec       ,                      ,                       ,               ,    \n" +
                "median response time conflict =,\(r(t.conflictTimeMedian)),sec      ,                      ,                       ,               ,    \n" +
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
    
    func createVisualSustainedTable() -> String {
        
        if let session: CounterpointingSession = pickedCounterpointingSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.string(from: session.dateStart as Date)
            let timeStart = timeFormatter.string(from: session.dateStart as Date)
            
            let comments = session.comment
            
            let rows = createVisualSustainedLines(session)
            let t = ECABLogCalculator.getVisualSustainResult(session)
            
            returnValue = "ECAB Test               ,\(gameName)    ,                       ,                      ,                       ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "ID                      ,\(playerName)  ,                       ,                      ,                       ,               ,    \n" +
                "date of birth           ,\(birth)       ,age at test            ,\(age)                ,                       ,               ,    \n" +
                "date/time of test start ,\(dateStart)   ,\(timeStart)           ,                      ,                       ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "parameters              ,               ,                       ,                      ,                       ,               ,    \n" +
                "total period            ,\(t.totalPeriod),exposure              ,\(t.totalExposure)    ,max delay              ,\(t.maxDelay)  ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "comments                ,\(comments)    ,                       ,                      ,                       ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "total pictures displayed,\(t.totalPicturesDisplayd),of which    ,\(t.totalAnimalsDisplayed),animals            ,               ,    \n" +
                "                        ,               ,                       ,                      ,                       ,               ,    \n" +
                "total hits =            ,\(t.totalHits) ,                       ,                      ,                       ,               ,    \n" +
                "total misses =          ,\(t.totalMisses),                      ,                      ,                       ,               ,    \n" +
                "total false +ves        ,\(t.totalFalseAndVE),                  ,                      ,                       ,               ,    \n" +
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
    
    fileprivate func createDynamicLinesForVSSession(_ visualSearchSession: Session) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        
        for move in visualSearchSession.moves {
            let gameMove = move as! Move
            let screenNumber = gameMove.screenNumber.intValue
            
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
                    let moveTimestamp = timeFormatter.string(from: gameMove.date as Date)
                    let targetRow = gameMove.row
                    let targetColumn = gameMove.column
                    
                    // CSV line
                    let line = ",\(sof) \(veor), \(targetRow), \(targetColumn), \(moveTimestamp)\n"
                    collectionOfTableRows.append(line)
                    
                } else {
                    var header = "header uknown"
                    switch screenNumber {
                    case VisualSearchEasyModeView.motorOne.rawValue:
                        header = "motor screen 1"
                    case VisualSearchEasyModeView.motorTwo.rawValue:
                        header = "motor screen 2"
                    case VisualSearchEasyModeView.motorThree.rawValue:
                        header = "motor screen 3"
                    case VisualSearchHardModeView.motorOne.rawValue:
                        header = "motor screen 1"
                    case VisualSearchHardModeView.motorTwo.rawValue:
                        header = "motor screen 2"
                    case VisualSearchEasyModeView.one.rawValue:
                        header = "search screen 1"
                    case VisualSearchEasyModeView.two.rawValue:
                        header = "search screen 2"
                    case VisualSearchEasyModeView.three.rawValue:
                        header = "search screen 3"
                    case VisualSearchHardModeView.one.rawValue:
                        header = "search screen 1"
                    case VisualSearchHardModeView.two.rawValue:
                        header = "search screen 2"
                    default:
                        header = "wrong header number"
                    }
                    // Time
                    let headerTime = timeFormatter.string(from: gameMove.date as Date)
                    
                    // CSV line
                    let headerLine = "\(header),screen onset, , ,\(headerTime)\n"
                    collectionOfTableRows.append(headerLine)
                }
            }
        }
        
        return collectionOfTableRows
    }
    
    fileprivate func createCounterpointinLines(_ session: CounterpointingSession) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var headerCount = 0
        var screenCount = 1
        var needHeader = true
        
        for move in session.moves {
            let gameMove = move as! CounterpointingMove
            
            if (gameMove.poitionX.intValue >= 4 && gameMove.poitionX.intValue <= 23)
            || (gameMove.poitionX.intValue >= 29 && gameMove.poitionX.intValue <= 48) {
            
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
                let line = ",\(screenCount),\(sof), \(time), sec., , ,\n"
                collectionOfTableRows.append(line)
                
                screenCount += 1
                needHeader = true
                
            } else {
            
                if needHeader  {
                
                    var header = "header uknown"
                    
                    switch headerCount {
                    case 0:
                        header = "non-conflict block 1"
                    case 1:
                        header = "conflict block 2"
                    default:
                        header = "header error"
                    }
                    headerCount += 1
        
                    // CSV line
                    let headerLine = "\(header),screen,response,time, , ,\n"
                    collectionOfTableRows.append(headerLine)
        
                    // Prevents duplicate headers
                    needHeader = false
                }
    
            }
        }

        return collectionOfTableRows
    }

    fileprivate func createFlankerLines(_ session: CounterpointingSession) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var headerCount = 1
        var screenCount = 1
        
        // First header
        let headerLine = "\(FlankerBlock.example.title),screen,response,time, , ,\n"
        collectionOfTableRows.append(headerLine)
        
        for move in session.moves {
            let gameMove = move as! CounterpointingMove

            let positionX: CGFloat = CGFloat(gameMove.poitionX.doubleValue)
            if positionX != blankSpaceTag {
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
                let line = ",\(screenCount),\(sof), \(time), sec., , ,\n"
                collectionOfTableRows.append(line)
                
                screenCount += 1
                
            } else {
                let header: String
                if let aHeader = FlankerBlock(rawValue: headerCount) {
                    header = aHeader.title
                } else {
                    header = "Header Error"
                }
                headerCount += 1
    
                // CSV line
                let headerLine = "\(header),screen,response,time, , ,\n"
                collectionOfTableRows.append(headerLine)
            }
        }

        return collectionOfTableRows
    }
    
    fileprivate func createFlankerRandomLines(_ session: CounterpointingSession) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var screenCount = 1
        
        collectionOfTableRows.append("Randmized,screen,response,time,,inversed ,case ,\n")
        
        for move in session.moves {
            let gameMove = move as! CounterpointingMove
            
            if gameMove.poitionX.doubleValue != Double(blankSpaceTag) {
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
                
                var inv = "normal"
                if let sc = gameMove.poitionX.intValue as Int? {
                    switch sc {
                        // TODO: Replace with the correct numers from Oliver.
                        case 24, 25, 27, 29, 30, 31, 32, 35, 36, 41, 42, 46, 47, 49, 50, 54, 55:
                        inv = "inversed"
                        default:
                        inv = "unknown"
                    }
                }
                
                // CSV line
                let line = ",\(screenCount),\(sof), \(time), sec.,\(inv),\(gameMove.poitionX.stringValue),\n"
                collectionOfTableRows.append(line)
                
                screenCount += 1
            }
        }
        
        return collectionOfTableRows
    }

    fileprivate func createVisualSustainedLines(_ session: CounterpointingSession) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var spacePrinted = false
        
        for move in session.moves {
            let gameMove = move as! CounterpointingMove
            
            var line = ""
            var fourMistakes = ""
            let poitionY = CGFloat(gameMove.poitionY.floatValue)
            if poitionY == VisualSustainSkip.fourSkips.rawValue {
                fourMistakes = "[4 mistaken taps in a row]"
            }
            if gameMove.success.boolValue {
                
                let formattedDelay = String(format: "%.02f", gameMove.delay!.doubleValue)
                
                line = "picture \(gameMove.poitionX), Success, delay:,\(formattedDelay) seconds, \(fourMistakes)\n"
            } else {
                // Two mistakes type
                if (gameMove.interval.doubleValue == VisualSustainMistakeType.falsePositive.rawValue) {
                    line = "picture \(gameMove.poitionX), False Positive, \(fourMistakes)\n"
                } else if (gameMove.interval.doubleValue == VisualSustainMistakeType.miss.rawValue) {
                    line = "picture \(gameMove.poitionX), Miss, \(fourMistakes)\n"
                }
            }
            
            if !spacePrinted && !gameMove.inverted.boolValue { // Not training
                line = "\n" + line
                spacePrinted = true
            }
            
            collectionOfTableRows.append(line)
        }
        
        return collectionOfTableRows
    }
}

