//
//  Session.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/13/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Session: NSManagedObject {

    @NSManaged var dateStart: NSDate
    @NSManaged var dateEnd: NSDate
    @NSManaged var gameType: AnyObject
    @NSManaged var score: NSNumber
    @NSManaged var success: NSSet
    @NSManaged var failure: NSSet
    @NSManaged var repeat: NSSet
    @NSManaged var player: Player
    @NSManaged var data: Data

}
