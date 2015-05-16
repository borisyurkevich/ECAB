//
//  Success.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/13/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Success: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var column: NSNumber
    @NSManaged var row: NSNumber
    @NSManaged var session: Session

}
