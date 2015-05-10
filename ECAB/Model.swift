//
//  Model.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Model {
    var players = [NSManagedObject]()
    var currentPlayerName: String = "No name"
    
    let games = [RedAppleGame()]
    
    init() {
        
        self.fetchFromCoreData()
        
        if players.count == 0 {
            
            // We extracted all objects from CoreData
            // If this object is not there, create default one
            savePlayer("Default")
            println("Default test subject created")
        }
        
        // Make first player default one
        let playerEntity = players[0]
        let name = playerEntity.valueForKey("name") as? String
        currentPlayerName = name!
    }
    
    class var sharedInstance: Model {
        struct Singleton {
            static let instance = Model()
        }
        
        return Singleton.instance
    }
    
    func fetchFromCoreData() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName:"Player")
        
        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as? [NSManagedObject]
        
        if let results = fetchedResults {
            players = results
        } else {
            println("Could not fetch \(error), \(error!.userInfo)")
        }
    }
    
    func savePlayer(name: String) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("Player",
            inManagedObjectContext:
            managedContext)
        let player = NSManagedObject(entity: entity!,
            insertIntoManagedObjectContext:managedContext)
        player.setValue(name, forKey: "name")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \(error), \(error?.userInfo)")
        }
        
        players.append(player)
        
        
    }
}
