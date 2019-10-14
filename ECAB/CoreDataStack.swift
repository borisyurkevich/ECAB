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
		let bundle = Bundle.main
		let modelURL =
		bundle.url(forResource: "Model", withExtension:"momd")
		model = NSManagedObjectModel(contentsOf: modelURL!)!
		
		//2
		psc = NSPersistentStoreCoordinator(managedObjectModel:model)
		
		//3
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
		context.persistentStoreCoordinator = psc
		
		//4
		let documentsURL =
		CoreDataStack.applicationDocumentsDirectory()
		
		let storeURL =
		documentsURL.appendingPathComponent("Model")
		
		let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
		
		do {
			store = try psc.addPersistentStore(ofType: NSSQLiteStoreType,
				configurationName: nil,
				at: storeURL,
				options: options)
		} catch let error as NSError {
			store = nil
            print("error core data stack init: \(error.localizedDescription)")
		}
		
		if store == nil {
			print("Error adding persistent store.")
			abort()
		}
	}
	
	func saveContext() {
		if context.hasChanges {
			do {
				try context.save()
			} catch let error1 as NSError {
				print("Could not save: \(error1.localizedDescription)")
			}
		}
	}
	
	class func applicationDocumentsDirectory() -> URL {
		let fileManager = FileManager.default
		
		let urls = fileManager.urls(for: .documentDirectory,
			in: .userDomainMask) 
		
		return urls[0]
	}
	
}
