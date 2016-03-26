//
//  CounterpointingMove+CoreDataProperties.swift
//  ECAB
//
//  Created by Boris Yurkevich on 26/03/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CounterpointingMove {

    @NSManaged var delay: NSNumber?
    @NSManaged var intervalDouble: NSNumber?
}
