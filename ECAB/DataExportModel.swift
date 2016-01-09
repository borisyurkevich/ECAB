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
		var returnValue: String? = nil
		
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
			
			returnValue = "\(gameName)             ,               ,              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
			              "ID                      ,\(playerName)  ,              ,               ,               ,               ,               \n" +
			              "date of birth           ,\(birth)       ,age at test   ,\(age)         ,               ,               ,               \n" +
						  "date/time of test start ,\(dateStart)   ,\(timeStart)  ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "parameters              ,\(difficulty)  ,              ,\(speed) s     ,               ,               ,               \n" +
						  "comments                ,               ,\(comments)   ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n" +
						  "                        ,               ,              ,               ,               ,               ,               \n"			
		}
		
		return returnValue
	}
}

