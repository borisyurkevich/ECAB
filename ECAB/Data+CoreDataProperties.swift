//
//  Data+CoreDataProperties.swift
//  ECAB
//
//  Created by Boris Yurkevich on 10/10/2015.
//  Copyright © 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Data {
	
	@NSManaged var id: String
	@NSManaged var selectedGame: NSNumber
	@NSManaged var visSearchDifficulty: NSNumber
	@NSManaged var visSearchSpeed: NSNumber
	@NSManaged var visSustSpeed: NSNumber // Exposure
	@NSManaged var visSearchSpeedHard: NSNumber
	@NSManaged var counterpointingSessions: NSOrderedSet
	@NSManaged var players: NSOrderedSet
	@NSManaged var selectedPlayer: Player
	@NSManaged var sessions: NSOrderedSet
    @NSManaged var visSustAcceptedDelay: NSNumber? // Max reponse delay
	
}
