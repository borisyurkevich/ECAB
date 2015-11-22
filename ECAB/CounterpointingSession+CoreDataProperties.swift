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

    @NSManaged var bundleVersion: String
    @NSManaged var comment: String
    @NSManaged var dateStart: NSDate
    @NSManaged var errors: NSNumber
    @NSManaged var imageSizeComment: String
    @NSManaged var misses: NSNumber
    @NSManaged var score: NSNumber
    @NSManaged var speed: NSNumber
    @NSManaged var totalOne: NSNumber
    @NSManaged var totalTwo: NSNumber
    @NSManaged var type: NSNumber
    @NSManaged var vsustMiss: NSNumber
    @NSManaged var vsustBlank: NSNumber
    @NSManaged var vsustAnimals: NSNumber
    @NSManaged var vsustObjects: NSNumber
    @NSManaged var data: Data
    @NSManaged var moves: NSOrderedSet
    @NSManaged var player: Player

}
