//
//  Success.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/17/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Move: NSManagedObject {

    @NSManaged var column: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var row: NSNumber
    @NSManaged var success: NSNumber
    @NSManaged var failure: NSNumber
    @NSManaged var repeat: NSNumber
    @NSManaged var session: Session

}
