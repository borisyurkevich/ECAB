//
//  Player.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/17/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Player: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var data: Data
    @NSManaged var selectedPlayer: Data
    @NSManaged var sessions: Session

}
