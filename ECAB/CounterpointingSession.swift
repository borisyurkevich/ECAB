//
//  CounterpointingSession.swift
//  ECAB
//
//  Created by Boris Yurkevich on 11/07/2015.
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
    @NSManaged var comment: String
    @NSManaged var speed: NSNumber
    @NSManaged var falsePositives: NSNumber
    @NSManaged var data: Data
    @NSManaged var moves: NSOrderedSet
    @NSManaged var player: Player

}
