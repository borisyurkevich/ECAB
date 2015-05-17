//
//  Model.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Model {
    let games = [RedAppleGame()]
	
	var managedContext: NSManagedObjectContext!
	
	var data: Data!
    
    init() {
        
        // To configure call the setupWithContext function from VC
    }
    
    class var sharedInstance: Model {
        struct Singleton {
            static let instance = Model()
        }
        
        return Singleton.instance
    }
	
	func setupWithContext(let context: NSManagedObjectContext) {
		
		managedContext = context
		
		fetchFromCoreData()
	}
	
    func fetchFromCoreData() {
		
		// Data entity
		let dataEntity = NSEntityDescription.entityForName("Data", inManagedObjectContext: managedContext)
		
		let dataIdentifier = "Default"
		let dataFetch = NSFetchRequest(entityName: "Data")
		dataFetch.predicate = NSPredicate(format: "id == %@", dataIdentifier)
		
		var error: NSError?
		
		let result = managedContext.executeFetchRequest(dataFetch, error: &error) as! [Data]?
		
		if let fetchedData = result {
			
			if fetchedData.count == 0 {
				data = Data(entity: dataEntity!, insertIntoManagedObjectContext: managedContext)
				data!.id = dataIdentifier
				
				if !managedContext.save(&error) {
					println("Could not save the Data: \(error)")
				}
			} else {
				data = fetchedData[0]
			}
			
			// If there's no current player,
			// create new one
			if let currPl = data?.currentPlayer {
				println("Default player found")
			} else {
				if data.players.count == 0 {
					addPlayer("Default")
				}
				data.currentPlayer = data.players.firstObject as! Player
			}
			
		} else {
			println("Could not fetch: \(error)")
		}
    }
    
    func addPlayer(playerName: String) {
		
		// Insert new Player entity into Core Data
		
		let playerEntity = NSEntityDescription.entityForName("Player", inManagedObjectContext: managedContext)
		
		let player = Player(entity: playerEntity!, insertIntoManagedObjectContext: managedContext)
		
		player.name = playerName
		
		// Insert the new Player into the Data set
		var players = data.players.mutableCopy() as! NSMutableOrderedSet
		players.addObject(player)
		data.players = players.copy() as! NSOrderedSet
		
		//Save the managed object context
		var error: NSError?
		if !managedContext!.save(&error) {
			println("Could not save player: \(error)")
		}
    }
	
	func addSession(type: String) {
		
		// Insert new Session entity into Core Data
		
		let sessionEntity = NSEntityDescription.entityForName("Session", inManagedObjectContext: managedContext)
		
		let session = Session(entity: sessionEntity!, insertIntoManagedObjectContext: managedContext)
		
		session.gameType = type
		session.dateStart = NSDate()
		
		// Insert the new Session into the Data set
		var sessions = data.sessions.mutableCopy() as! NSMutableOrderedSet
		sessions.addObject(session)
		data.sessions = sessions.copy() as! NSOrderedSet
		
		//Save the managed object context
		var error: NSError?
		if !managedContext!.save(&error) {
			println("Could not save session: \(error)")
		}
	}
	
	func addMove(row: Int, column: Int, session: Session, isSuccess: Bool, isRepeat: Bool) {
		
		// Insert new Success entity into Core Data
		
		let successMoveEntity = NSEntityDescription.entityForName("Success", inManagedObjectContext: managedContext)
		
		let successObj = Success(entity: successMoveEntity!, insertIntoManagedObjectContext: managedContext)
		
		successObj.row = row
		successObj.column = column
		successObj.session = session
		successObj.date = NSDate()
		
		let allSessions = data.sessions
		let lastSession = allSessions.lastObject as! Session
		
		var allSuccessMoves = lastSession.success.mutableCopy() as! NSMutableSet
		allSuccessMoves.addObject(successObj)
		lastSession.success = allSuccessMoves.copy() as! NSSet
		
		//Save the managed object context
		var error: NSError?
		if !managedContext!.save(&error) {
			println("Could not save new success move: \(error)")
		}
	}
}
