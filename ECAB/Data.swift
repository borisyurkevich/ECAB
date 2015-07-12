//
//  Data.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/10/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Data: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var selectedGame: NSNumber
    @NSManaged var players: NSOrderedSet
    @NSManaged var selectedPlayer: Player
    @NSManaged var sessions: NSOrderedSet
    @NSManaged var counterpointingSessions: NSOrderedSet

}
