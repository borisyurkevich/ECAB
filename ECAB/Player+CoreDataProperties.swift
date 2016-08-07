//
//  Player+CoreDataProperties.swift
//  ECAB
//
//  Created by Raphaël Bertin on 07/07/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Player {

    @NSManaged var name: String?
    @NSManaged var data: Data?
    @NSManaged var playedSessions: NSSet?
    @NSManaged var selected: Data?

}
