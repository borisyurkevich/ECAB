//
//  CounterpointingSession.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/10/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class CounterpointingSession: NSManagedObject {

    @NSManaged var score: NSNumber
    @NSManaged var dateStart: NSDate
    @NSManaged var errors: NSNumber
    @NSManaged var moves: NSOrderedSet
    @NSManaged var data: Data
    @NSManaged var player: Player

}
