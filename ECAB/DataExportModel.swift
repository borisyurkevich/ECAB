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
                returnValue = createFlankerTable(isRandom: false)
            } else if pickedCounterpointingSession?.type.intValue == SessionType.flankerRandomized.rawValue {
                returnValue = createFlankerTable(isRandom: true)
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
            
            returnValue = """
            \(gameName)             ,               ,                       ,                      ,                       ,               ,  
                                    ,               ,                       ,                      ,                       ,               ,  
            ID                      ,\(playerName)  ,                       ,                      ,                       ,               ,  
            date of birth           ,\(birth)       ,age at test            ,\(age)                ,                       ,               ,  
            date/time of test start ,\(dateStart)   ,\(timeStart)           ,                      ,                       ,               ,  
                                    ,               ,                       ,                      ,                       ,               ,  
            parameters              ,\(difficulty)  ,                       ,                      ,\(speed) s             ,               ,  
            comments                ,\(comments)    ,                       ,                      ,                       ,               ,  
                                    ,               ,                       ,                      ,                       ,               ,  
                                    ,               ,                       ,                      ,                       ,               ,  
                                    ,               ,motor 1                ,motor 2               ,motor 3                ,TOTAL          ,* 
            no of hits              ,               ,\(t.motorHits1)        ,\(t.motorHits2)       ,\(t.motorHits3)        ,\(mht)         ,  
            no of false positives   ,               ,\(t.motorFalse1)       ,\(t.motorFalse2)      ,\(t.motorFalse3)       ,\(mfpt)        ,  
            total time              ,               ,\(r(t.motorOneTotal))  ,\(r(t.motorTwoTotal)) ,\(r(t.motorThreeTotal)),\(r(mtt))      ,**
                                    ,               ,                       ,                      ,                       ,               ,  
                                    ,               ,                       ,                      ,                       ,               ,  
                                    ,               ,search 1               ,search 2              ,search 3               ,               ,  
            no of hits              ,               ,\(t.searchHits1)       ,\(t.searchHits2)      ,\(t.searchHits3)       ,\(sht)         ,  
            no of false positives   ,               ,\(t.searchFalse1)      ,\(t.searchFalse2)     ,\(t.searchFalse3)      ,\(sfpt)        ,  
            total time              ,               ,\(r(t.searchOneTotal)) ,\(r(t.searchTwoTotal)),\(r(t.searchThreeTotal)),\(r(stt))     ,**
            hits - false positives  ,               ,\(searchDiff1)         ,\(searchDiff2)        ,\(searchDiff3)         ,\(sht-sfpt)    ,  
                                    ,\(screenComm)  ,                       ,                      ,                       ,               ,  
                                    ,\(durationComm),                       ,                      ,                       ,               ,  
                                    ,               ,                       ,                      ,                       ,               ,  
            \(avgMotor)             ,\(avg.motor)   ,                       ,                      ,                       ,               ,  
            \(avgSearch)            ,\(avg.search)  ,                       ,                      ,                       ,               ,  
            \(avgDiff)              ,\(avgDiffVal)  ,                       ,                      ,                       ,               ,  
                                    ,               ,                       ,                      ,                       ,               ,  
            \(header)               ,               ,                       ,                      ,                       ,               ,  
                                    ,               ,target row             ,target col            ,time                   ,               ,
            
            """
            
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
            let data = ECABLogCalculator.getCounterpintingResult(session)
            guard let t = data.result else {
                return "Critical Error \(data.error ?? "")"
            }
            
            let meanRatio = t.conflictTimeMean / t.nonConflictTimeMean
            let medianRatio = t.conflictTimeMedian / t.nonConflictTimeMedian
            let timeRatio = t.timeBlockConflict / t.timeBlockNonConflict
            
            returnValue = """
            ECAB Test                    ,\(gameName)    ,                   ,        ,
                                         ,               ,                   ,        ,
            ID                           ,\(playerName)  ,                   ,        ,
            date of birth                ,\(birth)       ,age at test        ,\(age)  ,
            date/time of test start      ,\(dateStart)   ,\(timeStart)       ,        ,
                                         ,               ,                   ,        ,
            comments                     ,\(comments)    ,                   ,        ,
                                         ,               ,                   ,        ,
            non-conflict (blocks 1)      ,               ,                   ,        ,
            total time 1 =               ,\(r(t.timeBlockNonConflict)),s.    ,        ,
            mean response time 1 =       ,\(r(t.nonConflictTimeMean)),s.     ,        ,
            median response time 1 =     ,\(r(t.nonConflictTimeMedian)),s.   ,        ,
                                         ,               ,                   ,        ,
            conflict (blocks 2)          ,               ,                   ,        ,
            total time 2 =               ,\(r(t.timeBlockConflict)),s.       ,        ,
            mean response time 2 =       ,\(r(t.conflictTimeMean)),s.        ,        ,
            median response time 2 =     ,\(r(t.conflictTimeMedian)),s.      ,        ,
                                         ,               ,                   ,        ,
            mean ratio (con / non c)     ,\(r(meanRatio)),                   ,        ,
            median ratio                 ,\(r(medianRatio)),                 ,        ,
            time ratio                   ,\(r(timeRatio)),                   ,        ,
                                         ,               ,                   ,        ,
            log of individual responses  ,               ,                   ,        ,
            
            """
            
            // Append dynamic rows: headers and moves
            for line in rows {
                returnValue += line
            }
        }
        
        return returnValue;
    }
    
    func createFlankerTable(isRandom: Bool) -> String {
        
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
            let output = ECABLogCalculator.getFlankerResult(session)
            guard let t = output.result else {
                return "Couldn't create file. \(output.error ?? "")"
            }
            
            let meanRatio = t.conflictTimeMean / t.nonConflictTimeMean
            let medianRatio = t.conflictTimeMedian / t.nonConflictTimeMedian
            let timeRatio = t.conflictTime / t.nonConflictTime
            let random: String
            if isRandom {
                random = "Randomised"
            } else {
                random = "Not randomised"
            }
            
            returnValue = """
            ECAB Test               ,\(gameName) \(random)        ,            ,       ,
                                  ,                             ,            ,         ,
            ID                      ,\(playerName)                ,            ,       ,
            date of birth           ,\(birth)                     ,age at test ,\(age) ,
            date/time of test start ,\(dateStart)                 ,\(timeStart),       ,
                                  ,                             ,            ,         ,
            parameters              ,\(imageInfo)                 ,            ,       ,
            comments                ,\(comments)                  ,            ,       ,
                                  ,                             ,            ,         ,
            non-conflict (block 1+4),                             ,            ,       ,
            total time block 1      ,\(r(t.timeBlock1))           ,s.          ,       ,
            total time block 4      ,\(r(t.timeBlock4))           ,s.          ,       ,
            total time blocks 1+4   ,\(r(t.nonConflictTime))      ,s.          ,       ,
                                  ,                             ,            ,         ,
            mean response time 1+4  ,\(r(t.nonConflictTimeMean))  ,s.          ,       ,
            median response time 1+4,\(r(t.nonConflictTimeMedian)),s.          ,       ,
                                  ,                             ,            ,         ,
            conflicts (blocks 2+3)  ,                             ,            ,       ,
            total time block 2      ,\(r(t.timeBlock2))           ,s.          ,       ,
            total time block 3      ,\(r(t.timeBlock3))           ,s.          ,       ,
            total time blocks 2+3   ,\(r(t.conflictTime))         ,s.          ,       ,
                                  ,                             ,            ,         ,
            mean response time 2+3  ,\(r(t.conflictTimeMean))     ,s.          ,       ,
            median response time 2+3,\(r(t.conflictTimeMedian))   ,s.          ,       ,
                                  ,                             ,            ,         ,
            mean ratio (con / non c),\(r(meanRatio))              ,            ,       ,
            median ratio            ,\(r(medianRatio))            ,            ,       ,
            time ratio              ,\(r(timeRatio))              ,            ,       ,
                                    ,                             ,            ,       ,
            log of ind. responses   ,                             ,            ,       ,
            
            """
            
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
            
            returnValue = """
            ECAB Test               ,\(gameName)    ,                       ,                      ,           ,             ,
                                    ,               ,                       ,                      ,           ,             ,
            ID                      ,\(playerName)  ,                       ,                      ,           ,             ,
            date of birth           ,\(birth)       ,age at test            ,\(age)                ,           ,             ,
            date/time of test start ,\(dateStart)   ,\(timeStart)           ,                      ,           ,             ,
                                    ,               ,                       ,                      ,           ,             ,
            parameters              ,               ,                       ,                      ,           ,             ,
            total period            ,\(t.totalPeriod),exposure              ,\(t.totalExposure)    ,max delay  ,\(t.maxDelay),
                                    ,               ,                       ,                      ,           ,             ,
            comments                ,\(comments)    ,                       ,                      ,           ,             ,
                                    ,               ,                       ,                      ,           ,             ,
            total pictures displayed,\(t.totalPicturesDisplayd),of which    ,\(t.totalAnimalsDisplayed),animals,             ,
                                    ,               ,                       ,                      ,           ,             ,
            total hits =            ,\(t.totalHits) ,                       ,                      ,           ,             ,
            total misses =          ,\(t.totalMisses),                      ,                      ,           ,             ,
            total false +ves        ,\(t.totalFalseAndVE),                  ,                      ,           ,             ,
                                    ,               ,                       ,                      ,           ,             ,
            log of individual responses,            ,                       ,                      ,           ,             ,
            
            """
            
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
                    var header = "header unknown"
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
                let line = ",\(gameMove.poitionX.intValue),\(sof), \(time), s.\n"
                collectionOfTableRows.append(line)
                
                needHeader = true
                
            } else {
            
                if needHeader  {
                
                    var header = "header unknown"
                    
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
                    let headerLine = "\(header),screen,response,time\n"
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
        
        // First header
        let headerLine = "\(FlankerBlock.example.title),screen,response,time, ,\n"
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
                let line = ",\(positionX),\(sof), \(time), s.,\n"
                collectionOfTableRows.append(line)
                
            } else {
                let header: String
                if let aHeader = FlankerBlock(rawValue: headerCount) {
                    header = aHeader.title
                } else {
                    header = "Header Error"
                }
                headerCount += 1
    
                // CSV line
                let headerLine = "\(header),screen,response,time, ,\n"
                collectionOfTableRows.append(headerLine)
            }
        }

        return collectionOfTableRows
    }
    
    fileprivate func createFlankerRandomLines(_ session: CounterpointingSession) -> Array<String> {
        var collectionOfTableRows: Array<String> = Array()
        var screenCount = 1
        
        collectionOfTableRows.append("Randmised,screen,response,time,,inversed ,case ,\n")
        
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
                let line = ",\(screenCount),\(sof), \(time), s.,\(inv),\(gameMove.poitionX.stringValue),\n"
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
                
                line = "picture \(gameMove.poitionX), Success, delay:,\(formattedDelay) s., \(fourMistakes)\n"
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

