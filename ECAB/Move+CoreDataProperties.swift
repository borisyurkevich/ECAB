//
//  Move+CoreDataProperties.swift
//  ECAB
//
//  Created by Boris Yurkevich on 24/10/2015.
//  Copyright © 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Move {

	@NSManaged var column: NSNumber
	@NSManaged var empty: NSNumber
	@NSManaged var `repeat`: NSNumber
	@NSManaged var row: NSNumber
	@NSManaged var screenNumber: NSNumber
	@NSManaged var training: NSNumber
    @NSManaged var extraTimeLeft: NSNumber?
    
    @NSManaged var delay: NSNumber?
    @NSManaged var intervalDouble: NSNumber?

}
