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

// Needed to show blank space in the log between moves.
let blankSpaceTag:CGFloat = -1.0

// 1000.0 is Milliseconds in one second
func r(x:NSTimeInterval) -> Double {
    return Double(round(100.0 * x) / 100.0)
}

class Model {
    let games = [GameTitle.visual,
                 GameTitle.counterpointing,
                 GameTitle.flanker,
                 GameTitle.visualSust,
                 GameTitle.auditorySust,
                 GameTitle.dualSust,
                 GameTitle.verbal,
                 GameTitle.balloon
    ]
	
	var managedContext: NSManagedObjectContext!
	
	var data: Data!
	
	let kMinDelay = 1.0
	
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
		
		do {
			let result = try managedContext.executeFetchRequest(dataFetch)
			// Success
			let fetchedData = result
		
			if fetchedData.count == 0 {
				
				data = Data(entity: dataEntity!, insertIntoManagedObjectContext: managedContext)
				data!.id = dataIdentifier
				
				do {
					try managedContext.save()
				} catch let error1 as NSError {
					error = error1
					print("Could not save the Data: \(error)")
				}
			} else {
				data = fetchedData[0] as! Data
			}
			
			// If there's no current player,
			// create new one
            if data?.selectedPlayer == nil {
				if data.players.count == 0 {
					addPlayer("Default")
					// Default player added
					data.selectedPlayer = data.players.firstObject as! Player
				}
				// Players exist, but default not selected.
				data.selectedPlayer = data.players.firstObject as! Player
				data.selectedGame = 0
			}
			
			// NSNotificationCenter.defaultCenter().addObserver(self, selector: "dataLoaded", name: "dataLoaded", object: nil)
			NSNotificationCenter.defaultCenter().postNotificationName("dataLoaded", object: nil)
			
		
		} catch let fetchError as NSError {
			 print("Fetch failed: \(fetchError.localizedDescription)")
		}
    }
    
    func addPlayer(playerName: String) {
		
		// Insert new Player entity into Core Data
		
		let playerEntity = NSEntityDescription.entityForName("Player", inManagedObjectContext: managedContext)
		
		let player = Player(entity: playerEntity!, insertIntoManagedObjectContext: managedContext)
		
		player.name = playerName
		
		// Insert the new Player into the Data set
		let players = data.players.mutableCopy() as! NSMutableOrderedSet
		players.addObject(player)
		data.players = players.copy() as! NSOrderedSet
		
		save()
    }
	
	func addSession(player: Player, type: Int) {
		let sessionEntity = NSEntityDescription.entityForName("Session", inManagedObjectContext: managedContext)
		
		let session = Session(entity: sessionEntity!, insertIntoManagedObjectContext: managedContext)
		
		session.dateStart = NSDate()
		session.player = player
		session.type = type
		
		// Build number
		let bundleInfo = NSBundle.mainBundle().infoDictionary
		let bundleVersion = bundleInfo!["CFBundleVersion"]
		session.bundleVersion = bundleVersion! as? String
		
		// Insert the new Session into the Data set
		let sessions = data.sessions.mutableCopy() as! NSMutableOrderedSet
		sessions.addObject(session)
		data.sessions = sessions.copy() as! NSOrderedSet
		
		save()
	}
	
	func save() {
		//Save the managed object context
		var error: NSError?
		do {
			try managedContext!.save()
		} catch let error1 as NSError {
			error = error1
			print("Could not save counter. session: \(error)")
		}
	}
	
	func addMove(row: Int, column: Int, session: Session, isSuccess: Bool, isRepeat: Bool, isTraining: Bool, screen: Int, isEmpty:Bool, extraTime: Double) {
		
		// Insert new Success entity into Core Data
		
		let successMoveEntity = NSEntityDescription.entityForName("Move", inManagedObjectContext: managedContext)
		let move = Move(entity: successMoveEntity!, insertIntoManagedObjectContext: managedContext)
		
		move.row = row
		move.column = column
		move.session = session
		move.date = NSDate()
		move.success = isSuccess
		move.`repeat` = isRepeat
		move.training = isTraining
		move.screenNumber = screen
		move.empty = isEmpty
		move.extraTimeLeft = extraTime
		
		let allSessions = data.sessions
		let lastSession = allSessions.lastObject as! Session
		
		let allMoves = lastSession.moves.mutableCopy() as! NSMutableOrderedSet
		allMoves.addObject(move)
		lastSession.moves = allMoves.copy() as! NSOrderedSet
		
		save()
	}
	
    func addMove(positionX: CGFloat, positionY: CGFloat, success: Bool, interval: Double, inverted: Bool, delay:Double, type:NSNumber) {
		let successMoveEntity = NSEntityDescription.entityForName("Move", inManagedObjectContext: managedContext)
		let move = Move(entity: successMoveEntity!, insertIntoManagedObjectContext: managedContext)
		
		move.positionX = positionX
		move.positionY = positionY
		move.success = success
		move.date = NSDate()
		move.intervalDouble = NSNumber(double: interval)
		move.inverted = inverted
		move.delay = delay
        move.type = type
		
		let allSessions = data.sessions
		let lastSession = allSessions.lastObject as! Session
		
		let allMoves = lastSession.moves.mutableCopy() as! NSMutableOrderedSet
		allMoves.addObject(move)
		lastSession.moves = allMoves.copy() as! NSOrderedSet
		
		save()
	}
}
