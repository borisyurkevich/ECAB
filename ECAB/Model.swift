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

enum GamesIndex: NSNumber {
	case visualSearch = 0
	case counterpointing = 1
	case flanker = 2
	case visualSust = 3
}

enum Difficulty: NSNumber {
	case easy = 0
	case hard = 1
}

struct MenuConstants {
	static let second = "s"
}

struct GameTitle {
	static let visual = "Visual Search"
	static let counterpointing = "Counterpointing"
	static let flanker = "Flanker"
	static let visualSust = "Visual Sustained"
}

enum VisualSustainMistakeType: Double {
	case miss = 100.0
	case falsePositive = 200.0
    case repeated = 300.0
	case unknown = 0.0
}

enum VisualSustainSkip: CGFloat {
	case noSkip = 0
	case fourSkips = -100
}

// Needed to show blank space in the log between moves.
let blankSpaceTag:CGFloat = -1.0

// 1000.0 is Milliseconds in one second
func r(_ x:TimeInterval) -> Double {
    return Double(round(100.0 * x) / 100.0)
}

class Model {
    let games = [GameTitle.visual, GameTitle.counterpointing, GameTitle.flanker, GameTitle.visualSust]
	
	var managedContext: NSManagedObjectContext!
	
	var data: Data!
	
	let titles = GameTitle()
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
	
	func setupWithContext(_ context: NSManagedObjectContext) {
		
		managedContext = context
		
		fetchFromCoreData()
	}
	
    func fetchFromCoreData() {
		
		// Data entity
		let dataEntity = NSEntityDescription.entity(forEntityName: "Data", in: managedContext)
		
		let dataIdentifier = "Default"
		let dataFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
		dataFetch.predicate = NSPredicate(format: "id == %@", dataIdentifier)
				
		do {
			let result = try managedContext.fetch(dataFetch)
			// Success
			let fetchedData = result
		
			if fetchedData.count == 0 {
				
				data = Data(entity: dataEntity!, insertInto: managedContext)
				data!.id = dataIdentifier
				
				do {
					try managedContext.save()
				} catch let error1 as NSError {
					print("Could not save the Data: \(error1.localizedDescription)")
				}
			} else {
				data = fetchedData[0] as! Data
			}
			
			// If there's no current player,
			// create new one
			if data?.selectedPlayer != nil {
				// Selected player found
			} else {
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
			NotificationCenter.default.post(name: Notification.Name(rawValue: "dataLoaded"), object: nil)
			
		
		} catch let fetchError as NSError {
			 print("Fetch failed: \(fetchError.localizedDescription)")
		}
    }
    
    func addPlayer(_ playerName: String) {
		
		// Insert new Player entity into Core Data
		
		let playerEntity = NSEntityDescription.entity(forEntityName: "Player", in: managedContext)
		
		let player = Player(entity: playerEntity!, insertInto: managedContext)
		
		player.name = playerName
		
		// Insert the new Player into the Data set
		let players = data.players.mutableCopy() as! NSMutableOrderedSet
		players.add(player)
		data.players = players.copy() as! NSOrderedSet
		
		save()
    }
	
	func addSession(_ player: Player) {
		
		// Insert new Session entity into Core Data
		
		let sessionEntity = NSEntityDescription.entity(forEntityName: "Session", in: managedContext)
		
		let session = Session(entity: sessionEntity!, insertInto: managedContext)
		
		session.dateStart = NSDate()
		session.player = player
		
		// Build number
		let bundleInfo = Bundle.main.infoDictionary
		let bundleVersion = bundleInfo!["CFBundleVersion"]
		session.bundleVersion = bundleVersion! as? String
		
		// Insert the new Session into the Data set
		let sessions = data.sessions.mutableCopy() as! NSMutableOrderedSet
		sessions.add(session)
		data.sessions = sessions.copy() as! NSOrderedSet
		
		save()
	}
	
	func addCounterpointingSession(_ player: Player, type: Int) {
		let sessionEntity = NSEntityDescription.entity(forEntityName: "CounterpointingSession", in: managedContext)
		
		let session = CounterpointingSession(entity: sessionEntity!, insertInto: managedContext)
		
		session.dateStart = NSDate()
		session.player = player
		session.type = NSNumber(value: type)
		
		// Build number
		let bundleInfo = Bundle.main.infoDictionary
		let bundleVersion = bundleInfo!["CFBundleVersion"]
		session.bundleVersion = bundleVersion! as? String
		
		// Insert the new Session into the Data set
		let sessions = data.counterpointingSessions.mutableCopy() as! NSMutableOrderedSet
		sessions.add(session)
		data.counterpointingSessions = sessions.copy() as! NSOrderedSet
		
		save()
	}
	
	func save() {
		//Save the managed object context
		do {
			try managedContext!.save()
		} catch let error1 as NSError {
			print("Could not save counter. session: \(error1.localizedDescription)")
		}
	}
	
	func addMove(_ row: Int, column: Int, session: Session, isSuccess: Bool, isRepeat: Bool, isTraining: Bool, screen: Int, isEmpty:Bool, extraTime: Double) {
		
		// Insert new Success entity into Core Data
		
		let successMoveEntity = NSEntityDescription.entity(forEntityName: "Move", in: managedContext)
		let move = Move(entity: successMoveEntity!, insertInto: managedContext)
		
		move.row = NSNumber(value: row)
		move.column = NSNumber(value: column)
		move.session = session
		move.date = NSDate()
		move.success = isSuccess as NSNumber
		move.`repeat` = isRepeat as NSNumber
		move.training = isTraining as NSNumber
		move.screenNumber = NSNumber(value: screen)
		move.empty = isEmpty as NSNumber
		move.extraTimeLeft = extraTime as NSNumber
		
		let allSessions = data.sessions
		let lastSession = allSessions.lastObject as! Session
		
		let allMoves = lastSession.moves.mutableCopy() as! NSMutableOrderedSet
		allMoves.add(move)
		lastSession.moves = allMoves.copy() as! NSOrderedSet
		
		save()
	}
	
	func addCounterpointingMove(_ positionX: CGFloat, positionY: CGFloat, success: Bool, interval: Double, inverted: Bool, delay:Double) {
		let successMoveEntity = NSEntityDescription.entity(forEntityName: "CounterpointingMove", in: managedContext)
		let move = CounterpointingMove(entity: successMoveEntity!, insertInto: managedContext)
		
		move.poitionX = NSNumber(value: Double(positionX))
		move.poitionY = NSNumber(value: Double(positionY))
		move.success = success as NSNumber
		move.date = NSDate()
		move.intervalDouble = NSNumber(value: interval as Double)
		move.inverted = inverted as NSNumber
		move.delay = delay as NSNumber
        move.interval = NSNumber(value: interval)
		
		let allSessions = data.counterpointingSessions
		let lastSession = allSessions.lastObject as! CounterpointingSession
		
		let allMoves = lastSession.moves.mutableCopy() as! NSMutableOrderedSet
		allMoves.add(move)
		lastSession.moves = allMoves.copy() as! NSOrderedSet
		
		save()
	}
}
