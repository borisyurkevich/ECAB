//
//  CounterpointingMove.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/10/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class CounterpointingMove: NSManagedObject {

    @NSManaged var success: NSNumber
    @NSManaged var inverted: NSNumber
    @NSManaged var date: NSDate
    @NSManaged var poitionX: NSNumber
    @NSManaged var poitionY: NSNumber
    @NSManaged var session: NSManagedObject

}
