//
//  Player.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/10/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Player: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var data: Data
    @NSManaged var playedSessions: NSSet
    @NSManaged var selected: Data
    @NSManaged var playedCounterpointingSessions: NSSet

}
