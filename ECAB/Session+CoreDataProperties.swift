//
//  Session+CoreDataProperties.swift
//  ECAB
//
//  Created by Boris Yurkevich on 28/11/2015.
//  Copyright © 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Session {
    @NSManaged var bundleVersion: String?
    @NSManaged var imageSizeComment: String?
    
    @NSManaged var pictures: NSNumber?
    @NSManaged var sounds: NSNumber?
    
    @NSManaged var blank: NSNumber?
    @NSManaged var miss: NSNumber?
    @NSManaged var objects: NSNumber?
    @NSManaged var acceptedDelay: NSNumber?
}
