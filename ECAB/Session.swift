//
//  Session.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/10/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var dateStart: NSDate
    @NSManaged var failureScore: NSNumber
    @NSManaged var repeatCount: NSNumber
    @NSManaged var score: NSNumber
    @NSManaged var data: Data
    @NSManaged var moves: NSOrderedSet
    @NSManaged var player: Player

}
