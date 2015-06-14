//
//  CounterpointingMove.swift
//  ECAB
//
//  Created by Boris Yurkevich on 6/14/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class CounterpointingMove: NSManagedObject {

    @NSManaged var date: NSDate
    @NSManaged var inverted: NSNumber
    @NSManaged var poitionX: NSNumber
    @NSManaged var poitionY: NSNumber
    @NSManaged var success: NSNumber
    @NSManaged var interval: NSNumber
    @NSManaged var session: CounterpointingSession

}
