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

class DataExportModel {
	
	let model = Model.sharedInstance
	var pickedVisualSearchSession: Session? = nil
	var pickedCounterpointingSession: CounterpointingSession? = nil
	
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
	
	func createVisualSearchTable() -> String? {
		var returnValue = "empty line\n"
		
		if let visualSearchSession: Session = pickedVisualSearchSession {
			let gameName = model.games[Int(model.data.selectedGame)]
			let playerName = visualSearchSession.player.name
			let birth = "dd/mm/yy"
			let age = "yy/mm"
			
			let dateFormatter = NSDateFormatter()
			dateFormatter.dateFormat = "dd/mm/yy"
			let dateStart: String = dateFormatter.stringFromDate(visualSearchSession.dateStart)
			let timeFormatter = NSDateFormatter()
			timeFormatter.dateFormat = "hh:mm:ss"
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
						  "no of hits              ,               ,              ,               ,               ,               ,               \n" +
						  "no of false positives   ,               ,              ,               ,               ,               ,               \n" +
 						  "total time              ,               ,              ,               ,               ,               ,**             \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
					      "                        ,               ,search 1      ,search 2       ,search 3       ,               ,               \n" +
  						  "no of hits              ,               ,              ,               ,               ,               ,               \n" +
						  "no of false positives   ,               ,              ,               ,               ,               ,               \n" +
						  "total time              ,               ,              ,               ,               ,               ,**             \n" +
			              "hits- false positives   ,               ,              ,               ,               ,               ,               \n" +
  						  "                        ,\(screenComm)  ,              ,               ,               ,               ,               \n" +
						  "                        ,\(durationComm),              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "\(header)               ,               ,              ,               ,               ,               ,               \n" +
                          "                        ,               ,target row    ,target col     ,time           ,               ,               \n"
            
            // Append dynamic lines
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
                        // time
                        let moveTime = timeFormatter.stringFromDate(gameMove.date)
                        // Row and column
                        let targetRow = gameMove.row
                        let targetColumn = gameMove.column
                        
                        // CSV line
                        let line = ",\(sof) \(veor), \(targetRow), \(targetColumn), \(moveTime)\n"
                        returnValue += line
                    } else {
                        var header = "header uknown"
                        switch screenNumber {
                        case 3:
                            header = "motor screen 1"
                        case 4:
                            header = "motor screen 2"
                        case 5:
                            header = "motor screen 3"
                        case 14:
                            header = "motor screen 1"
                        case 15:
                            header = "motor screen 2"
                        case 6:
                            header = "search screen 1"
                        case 7:
                            header = "search screen 2"
                        case 8:
                            header = "search screen 3"
                        case 16:
                            header = "search screen 1"
                        case 17:
                            header = "search screen 2"
                        default:
                            header = "wrong header number"
                        }
                        // Time
                        let headerTime = timeFormatter.stringFromDate(gameMove.date)
                        
                        // CSV line
                        let headerLine = "\(header),screen onset, , ,\(headerTime)\n"
                        returnValue += headerLine
                    }
                }
            }
		}
		
		return returnValue
	}
}

