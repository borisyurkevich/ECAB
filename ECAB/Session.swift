//
//  Session.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/17/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var dateEnd: NSDate
    @NSManaged var dateStart: NSDate
    @NSManaged var gameType: AnyObject
    @NSManaged var score: NSNumber
    @NSManaged var failureScore: NSNumber
    @NSManaged var repeatCount: NSNumber
    @NSManaged var data: Data
    @NSManaged var player: Player
    @NSManaged var moves: NSOrderedSet

}
