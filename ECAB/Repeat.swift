//
//  Repeat.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/13/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class Repeat: NSManagedObject {

    @NSManaged var column: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var row: NSNumber
    @NSManaged var session: Session

}
