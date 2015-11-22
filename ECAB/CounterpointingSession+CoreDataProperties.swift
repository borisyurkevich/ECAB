//
//  CounterpointingSession+CoreDataProperties.swift
//  ECAB
//
//  Created by Boris Yurkevich on 22/11/2015.
//  Copyright © 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CounterpointingSession {

    @NSManaged var bundleVersion: String?
    @NSManaged var imageSizeComment: String?
    @NSManaged var vsustAnimals: NSNumber?
    @NSManaged var vsustBlank: NSNumber?
    @NSManaged var vsustMiss: NSNumber?
    @NSManaged var vsustObjects: NSNumber?

}
