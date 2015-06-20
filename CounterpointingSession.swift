//
//  CounterpointingSession.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/20/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class CounterpointingSession: NSManagedObject {

    @NSManaged var dateStart: NSDate
    @NSManaged var errors: NSNumber
    @NSManaged var score: NSNumber
    @NSManaged var totalOne: NSNumber
    @NSManaged var totalTwo: NSNumber
    @NSManaged var type: NSNumber
    @NSManaged var data: Data
    @NSManaged var moves: NSOrderedSet
    @NSManaged var player: Player

}
