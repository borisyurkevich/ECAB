//
//  Move.swift
//  ECAB
//
//  Created by Boris Yurkevich on 12/07/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Move: NSManagedObject {

    @NSManaged var column: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var empty: NSNumber
    @NSManaged var `repeat`: NSNumber
    @NSManaged var row: NSNumber
    @NSManaged var screenNumber: NSNumber
    @NSManaged var success: NSNumber
    @NSManaged var training: NSNumber
    @NSManaged var session: Session

}
