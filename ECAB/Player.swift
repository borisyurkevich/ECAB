//
//  Player.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/13/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Player: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var sessions: Session
    @NSManaged var data: Data
    @NSManaged var selectedPlayer: Data

}
