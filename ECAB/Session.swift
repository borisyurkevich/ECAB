//
//  Session.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/1/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var dateEnd: NSDate
    @NSManaged var dateStart: NSDate
    @NSManaged var failureScore: NSNumber
    @NSManaged var gameType: AnyObject
    @NSManaged var repeatCount: NSNumber
    @NSManaged var score: NSNumber
    @NSManaged var empty: NSNumber
    @NSManaged var data: Data
    @NSManaged var moves: NSOrderedSet
    @NSManaged var player: Player

}
