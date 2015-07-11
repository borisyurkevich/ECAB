//
//  Session.swift
//  ECAB
//
//  Created by Boris Yurkevich on 11/07/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var dateStart: NSDate
    @NSManaged var extraMode: NSNumber
    @NSManaged var extraSpeed: NSNumber
    @NSManaged var failureScore: NSNumber
    @NSManaged var normalSpeed: NSNumber
    @NSManaged var repeatCount: NSNumber
    @NSManaged var score: NSNumber
    @NSManaged var comment: String
    @NSManaged var speed: NSNumber
    @NSManaged var data: Data
    @NSManaged var moves: NSOrderedSet
    @NSManaged var player: Player

}
