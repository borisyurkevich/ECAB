//
//  CoreDataStack.swift
//  ECAB
//
//  Created by Boris Yurkevich on 5/12/15.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack
{
	let context: NSManagedObjectContext
	let psc: NSPersistentStoreCoordinator
	let model: NSManagedObjectModel
	let store: NSPersistentStore?
	
	init() {
		//1
		let bundle = NSBundle.mainBundle()
		let modelURL =
		bundle.URLForResource("Model", withExtension:"momd")
		model = NSManagedObjectModel(contentsOfURL: modelURL!)!
		
		//2
		psc = NSPersistentStoreCoordinator(managedObjectModel:model)
		
		//3
		context = NSManagedObjectContext()
		context.persistentStoreCoordinator = psc
		
		//4
		let documentsURL =
		CoreDataStack.applicationDocumentsDirectory()
		
		let storeURL =
		documentsURL.URLByAppendingPathComponent("Model")
		
		let options = [NSMigratePersistentStoresAutomaticallyOption: true,
			NSInferMappingModelAutomaticallyOption: true]

		
		var error: NSError? = nil
		do {
			store = try psc.addPersistentStoreWithType(NSSQLiteStoreType,
				configuration: nil,
				URL: storeURL,
				options: options)
		} catch let error1 as NSError {
			error = error1
			store = nil
		}
		
		if store == nil {
			print("Error adding persistent store: \(error)")
			abort()
		}
	}
	
	func saveContext() {
		var error: NSError? = nil
		if context.hasChanges {
			do {
				try context.save()
			} catch let error1 as NSError {
				error = error1
				print("Could not save: \(error), \(error?.userInfo)")
			}
		}
	}
	
	class func applicationDocumentsDirectory() -> NSURL {
		let fileManager = NSFileManager.defaultManager()
		
		let urls = fileManager.URLsForDirectory(.DocumentDirectory,
			inDomains: .UserDomainMask) 
		
		return urls[0]
	}
	
}