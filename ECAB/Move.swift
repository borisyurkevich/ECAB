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
    
    @NSManaged var date: NSDate
    @NSManaged var interval: NSNumber
    @NSManaged var inverted: NSNumber
    @NSManaged var positionX: NSNumber
    @NSManaged var positionY: NSNumber
    @NSManaged var success: NSNumber
    
    @NSManaged var type: NSNumber
    
    @NSManaged var session: Session

}
