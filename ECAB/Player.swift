//
//  Player.swift
//  ECAB
//
//  Created by Boris Yurkevich on 11/07/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Player: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var data: Data
    @NSManaged var playedCounterpointingSessions: NSSet
    @NSManaged var playedSessions: NSSet
    @NSManaged var selected: Data

}
