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
    let games = ["Visual Search", "Counterpointing"]
	
	var managedContext: NSManagedObjectContext!
	
	var data: Data!
	
	let titles = GameTitle()
	
	var visualSearchOnEasy = true
    
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
			if let currPl = data?.selectedPlayer {
				println("Default player found")
			} else {
				if data.players.count == 0 {
					addPlayer("Default")
				}
				data.selectedPlayer = data.players.firstObject as! Player
				data.selectedGame = 0
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
	
	func addSession(player: Player) {
		
		// Insert new Session entity into Core Data
		
		let sessionEntity = NSEntityDescription.entityForName("Session", inManagedObjectContext: managedContext)
		
		let session = Session(entity: sessionEntity!, insertIntoManagedObjectContext: managedContext)
		
		session.dateStart = NSDate()
		session.player = player
		
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
	
	func addCounterpointingSession(player: Player) {
		let sessionEntity = NSEntityDescription.entityForName("CounterpointingSession", inManagedObjectContext: managedContext)
		
		let session = CounterpointingSession(entity: sessionEntity!, insertIntoManagedObjectContext: managedContext)
		
		session.dateStart = NSDate()
		session.player = player
		
		// Insert the new Session into the Data set
		var sessions = data.counterpointingSessions.mutableCopy() as! NSMutableOrderedSet
		sessions.addObject(session)
		data.counterpointingSessions = sessions.copy() as! NSOrderedSet
		
		//Save the managed object context
		var error: NSError?
		if !managedContext!.save(&error) {
			println("Could not save counter. session: \(error)")
		}
	}
	
	func addMove(row: Int, column: Int, session: Session, isSuccess: Bool, isRepeat: Bool, isTraining: Bool, screen: Int, isEmpty:Bool) {
		
		// Insert new Success entity into Core Data
		
		let successMoveEntity = NSEntityDescription.entityForName("Move", inManagedObjectContext: managedContext)
		let move = Move(entity: successMoveEntity!, insertIntoManagedObjectContext: managedContext)
		
		move.row = row
		move.column = column
		move.session = session
		move.date = NSDate()
		move.success = isSuccess
		move.repeat = isRepeat
		move.training = isTraining
		move.screenNumber = screen
		move.empty = isEmpty
		
		let allSessions = data.sessions
		let lastSession = allSessions.lastObject as! Session
		
		var allMoves = lastSession.moves.mutableCopy() as! NSMutableOrderedSet
		allMoves.addObject(move)
		lastSession.moves = allMoves.copy() as! NSOrderedSet
		
		//Save the managed object context
		var error: NSError?
		if !managedContext!.save(&error) {
			println("Could not save new visual search move move: \(error)")
		}
	}
	
	func addCounterpointingMove(positionX: CGFloat, positionY: CGFloat, success: Bool, interval: Int, inverted: Bool) {
		let successMoveEntity = NSEntityDescription.entityForName("CounterpointingMove", inManagedObjectContext: managedContext)
		let move = CounterpointingMove(entity: successMoveEntity!, insertIntoManagedObjectContext: managedContext)
		
		move.poitionX = positionX
		move.poitionY = positionY
		move.success = success
		move.date = NSDate()
		move.interval = interval
		move.inverted = inverted
		
		let allSessions = data.counterpointingSessions
		let lastSession = allSessions.lastObject as! CounterpointingSession
		
		var allMoves = lastSession.moves.mutableCopy() as! NSMutableOrderedSet
		allMoves.addObject(move)
		lastSession.moves = allMoves.copy() as! NSOrderedSet
		
		//Save the managed object context
		var error: NSError?
		if !managedContext!.save(&error) {
			println("Could not save new counterpointing move: \(error)")
		}
	}
	
	func updateData() {
		
		//Save the managed object context
		var error: NSError?
		if !managedContext!.save(&error) {
			println("Could not update the data: \(error)")
		}
		
	}
	
	struct GameTitle {
		let visual = "Visual Search"
		let counterpointing = "Counterpointing"
	}
}
