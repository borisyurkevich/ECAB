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
	var optionalSelectedGameIndex: NSNumber?
	var pickedVisualSearchSession: Session? = nil
	var pickedCounterpointingSession: CounterpointingSession? = nil
	
	init() {
		optionalSelectedGameIndex = model.data.selectedGame
	}
	
	func export() -> String? {
		var returnValue: String? = nil
		
		if let selectedGameIndex: NSNumber = optionalSelectedGameIndex {
			
			switch selectedGameIndex {
			case GamesIndex.VisualSearch.rawValue:
				returnValue = createVisualSearchTable()
				break
			default:
				break
			}
		}
		
		return returnValue
	}
	
	func createVisualSearchTable() -> String? {
		var returnValue: String? = nil
		
		if let visualSearchSession: Session = pickedVisualSearchSession {
			let gameName = model.games[Int(model.data.selectedGame)]
			let playerName = visualSearchSession.player.name
			returnValue = "\(gameName),,,,,,,\n,,,,,,,,\nID,\(playerName),,,,,,,\nbirth,dd/mm/yy,,,\n"
		}
		
		return returnValue
	}
}

