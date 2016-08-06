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
	
    var pickedSession: Session? = nil
    
	private let model = Model.sharedInstance
    private let msInOneSec = 1000.0 // Milliseconds in one second
    private let gameName: String
    private let birth: String
    private let age: String
    private let dateFormatter = NSDateFormatter()
    private let timeFormatter = NSDateFormatter()
    private var returnValue = "empty line\n"
    
    init() {
        gameName = model.games[Int(model.data.selectedGame)].rawValue
        birth = "dd/MM/yy"
        age = "yy/mm"
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        timeFormatter.dateFormat = "HH:mm:ss:SSS"
    }
    
	func export() -> String? {
		var returnValue: String? = nil
		
		switch model.data.selectedGame {
            
            case GamesIndex.VisualSearch.rawValue:
                returnValue = createVisualSearchTable()
            
            case GamesIndex.Counterpointing.rawValue:
                returnValue = createCounterpointingTable()
            
            case GamesIndex.Flanker.rawValue:
                returnValue = createFlankerTable()
            
            case GamesIndex.VisualSust.rawValue:
                returnValue = createVisualSustainedTable()
            
            case GameTitle.auditorySust.rawValue:
                break
                
            case GameTitle.dualSust.rawValue:
                returnValue = createDualSustainedTable()
                break
                
            case GameTitle.verbal.rawValue:
                break
                
            case GameTitle.balloon.rawValue:
                break
            
            default:
                break
		}
		
		return returnValue
	}
    
    func createVisualSearchTable() -> String {
        
        if let session: Session = pickedSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.stringFromDate(session.dateStart)
            let timeStart = timeFormatter.stringFromDate(session.dateStart)
            
            var difficulty = "easy"
            if session.difficulty == Difficulty.Hard.rawValue {
                difficulty = "hard"
            }
            let speed = session.speed.doubleValue
            
            let comments = session.comment
            
            let screenComm = "*screen 3 should be blank throughout for 'hard' condition"
            let durationComm = "**set this to screen duration if it doesn't finish early"
            let header = "log of indivudual responces"
            
            // Create dynamic lines
            let dynamicLines = createDynamicLinesForVSSession(session)
            let t = ECABLogCalculator.getVisualSearchTotals(session)
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
        
        if let session: Session = pickedSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.stringFromDate(session.dateStart)
            let timeStart = timeFormatter.stringFromDate(session.dateStart)
            
            let comments = session.comment
            
            let rows = createCounterpointingLines(session)
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
                "total time 1 =          ,\(r(t.timeBlockNonConflict)),msec     ,                      ,                       ,               ,    \n" +
                "mean reponse time 1 =   ,\(r(t.nonConflictTimeMean)),msec      ,                      ,                       ,               ,    \n" +
                "median reponse time 1 = ,\(r(t.nonConflictTimeMedian)),msec    ,                      ,                       ,               ,    \n" +
                "                        ,               ,                      ,                      ,                       ,               ,    \n" +
                "conflict (blocks 2)     ,               ,                      ,                      ,                       ,               ,    \n" +
                "total time 2 =          ,\(r(t.timeBlockConflict)),msec        ,                      ,                       ,               ,    \n" +
                "mean reponse time 2 =   ,\(r(t.conflictTimeMean)),msec         ,                      ,                       ,               ,    \n" +
                "median reponse time 2 = ,\(r(t.conflictTimeMedian)),msec       ,                      ,                       ,               ,    \n" +
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
        
        if let session: Session = pickedSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.stringFromDate(session.dateStart)
            let timeStart = timeFormatter.stringFromDate(session.dateStart)
            
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
    
    func createVisualSustainedTable() -> String {
        
        if let session: Session = pickedSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.stringFromDate(session.dateStart)
            let timeStart = timeFormatter.stringFromDate(session.dateStart)
            
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
                "total hits=             ,\(t.totalHits) ,                       ,                      ,                       ,               ,    \n" +
                "total misses=           ,\(t.totalMisses),                      ,                      ,                       ,               ,    \n" +
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
    
    func createDualSustainedTable() -> String {
        
        if let session: Session = pickedSession {
            let playerName = session.player.name
            
            let dateStart: String = dateFormatter.stringFromDate(session.dateStart)
            let timeStart = timeFormatter.stringFromDate(session.dateStart)
            
            let comments = session.comment
            
            let rows = createDualSustainedLines(session)
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
                "total hits=             ,\(t.totalHits) ,                       ,                      ,                       ,               ,    \n" +
                "total misses=           ,\(t.totalMisses),                      ,                      ,                       ,               ,    \n" +
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
    
    private func createDynamicLinesForVSSession(visualSearchSession: Session) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        
        for case let move as Move in visualSearchSession.moves {
            let screenNumber = move.screenNumber.integerValue
            
            var ignoreThisMove = false
            switch screenNumber {
            case 0 ... 2, 11 ... 13:
                ignoreThisMove = true // Training
            default:
                break
            }
            if !ignoreThisMove {
                if move.empty.boolValue == false {
                    // Success or failure
                    var sof = ""
                    if move.success.boolValue == true {
                        sof = "hit"
                    } else {
                        sof = "false"
                    }
                    // ve / repeat
                    var veor = ""
                    if move.`repeat`.boolValue == true {
                        veor = "repeat"
                    } else {
                        veor = "ve"
                    }
                    let moveTimestamp = timeFormatter.stringFromDate(move.date)
                    let targetRow = move.row
                    let targetColumn = move.column
                    
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
                    let headerTime = timeFormatter.stringFromDate(move.date)
                    
                    // CSV line
                    let headerLine = "\(header),screen onset, , ,\(headerTime)\n"
                    collectionOfTableRows.append(headerLine)
                }
            }
        }
        
        return collectionOfTableRows
    }
    
    private func createCounterpointingLines(session: Session) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var headerCount = 0
        var screenCount = 1
        var needHeader = true
        
        for case let move as Move in session.moves {
            
            if (move.positionX.integerValue >= 4 && move.positionX.integerValue <= 23)
            || (move.positionX.integerValue >= 29 && move.positionX.integerValue <= 48) {
            
                // Success or failure
                var sof = ""
                if move.success.boolValue == true {
                    sof = "correct"
                } else {
                    sof = "incorrect"
                }
                
                var time: Double
                if let newInterval = move.intervalDouble as? Double {
                    time = r(newInterval)
                } else {
                    // Because I defined old interval as Integer I am chaning it to Double
                    // This condition is to keep old data working.
                    time = move.interval.doubleValue
                }
                
                // CSV line
                let line = ",\(screenCount),\(sof), \(time), msec, , ,\n"
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

    private func createFlankerLines(session: Session) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var headerCount = 0
        var screenCount = 1
        
        for case let move as Move in session.moves {

            if move.positionX != blankSpaceTag {
                // Success or failure
                var sof = ""
                if move.success.boolValue == true {
                    sof = "correct"
                } else {
                    sof = "incorrect"
                }

                var time: Double
                if let newInterval = move.intervalDouble as? Double {
                    time = r(newInterval)
                } else {
                    // Because I defined old interval as Integer I am chaning it to Double
                    // This condition is to keep old data working.
                    time = move.interval.doubleValue
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

    private func createVisualSustainedLines(session: Session) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var spacePrinted = false
        
        for case let move as Move in session.moves {
            
            var line = ""
            var fourMistakes = ""
            if move.positionY == VisualSustainSkip.FourSkips.rawValue {
                fourMistakes = "[4 mistaken taps in a row]"
            }
            if move.success.boolValue {
                
                let formattedDelay = String(format: "%.02f", move.delay!.doubleValue)
                
                line = "picture \(move.positionX), Success, delay:,\(formattedDelay) seconds, \(fourMistakes)\n"
            } else {
                // Two mistakes type
                if (move.interval == VisualSustainMistakeType.FalsePositive.rawValue) {
                    line = "picture \(move.positionX), False Positive, \(fourMistakes)\n"
                } else if (move.interval == VisualSustainMistakeType.Miss.rawValue) {
                    line = "picture \(move.positionX), Miss, \(fourMistakes)\n"
                }
            }
            
            if !spacePrinted && !move.inverted.boolValue { // Not training
                line = "\n" + line
                spacePrinted = true
            }
            
            collectionOfTableRows.append(line)
        }
        
        return collectionOfTableRows
    }
    
    private func createDualSustainedLines(session: Session) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var spacePrinted = false
        
        for case let move as Move in session.moves {
            
            var line = ""
            var fourMistakes = ""
            if move.positionY == VisualSustainSkip.FourSkips.rawValue {
                fourMistakes = "[4 mistaken taps in a row]"
            }
            if move.success.boolValue {
                
                let formattedDelay = String(format: "%.02f", move.delay!.doubleValue)
                
                line = "picture \(move.positionX), Success, delay:,\(formattedDelay) seconds, \(fourMistakes)\n"
            } else {
                // Two mistakes type
                if (move.interval == VisualSustainMistakeType.FalsePositive.rawValue) {
                    line = "picture \(move.positionX), False Positive, \(fourMistakes)\n"
                } else if (move.interval == VisualSustainMistakeType.Miss.rawValue) {
                    line = "picture \(move.positionX), Miss, \(fourMistakes)\n"
                }
            }
            
            if !spacePrinted && !move.inverted.boolValue { // Not training
                line = "\n" + line
                spacePrinted = true
            }
            
            collectionOfTableRows.append(line)
        }
        
        return collectionOfTableRows
    }

}

