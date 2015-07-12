//
//  Data.swift
//  ECAB
//
//  Created by Boris Yurkevich on 12/07/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Data: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var selectedGame: NSNumber
    @NSManaged var visSearchDifficulty: NSNumber
    @NSManaged var visSearchSpeed: NSNumber
    @NSManaged var visSustSpeed: NSNumber
    @NSManaged var counterpointingSessions: NSOrderedSet
    @NSManaged var players: NSOrderedSet
    @NSManaged var selectedPlayer: Player
    @NSManaged var sessions: NSOrderedSet

}
