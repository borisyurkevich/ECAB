//
//  AppDelegate.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIGuidedAccessRestrictionDelegate {

    var window: UIWindow?
	lazy var coreDataStack = CoreDataStack()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
		
		let tabBarController = self.window!.rootViewController as! UITabBarController
		let allTabs: Array = tabBarController.viewControllers!;
		let splitController = allTabs[0] as! UISplitViewController
		let navigationController = splitController.viewControllers.last as! UINavigationController
		let viewController = navigationController.topViewController  as! MenuViewController
		viewController.managedContext = coreDataStack.context
		
        return true
    }

    func applicationDidEnterBackground(application: UIApplication) {
		coreDataStack.saveContext()
    }

    func applicationWillTerminate(application: UIApplication) {
		coreDataStack.saveContext()
    }

    // MARK: - UIGuidedAccessRestrictionDelegate
    
    let controlsRestrictionId = "net.borisy.ecab.ControlsRestrictionId"
    let notificationId = "kECABGuidedAccessNotification"
    
    func guidedAccessRestrictionIdentifiers() -> [String]? {
        return [controlsRestrictionId]
    }
    
    func textForGuidedAccessRestrictionWithIdentifier(restrictionIdentifier: String) -> String? {
        if restrictionIdentifier == controlsRestrictionId {
            return "Pause button"
        }
        return nil
    }
    
    func detailTextForGuidedAccessRestrictionWithIdentifier(restrictionIdentifier: String) -> String? {
        if restrictionIdentifier == controlsRestrictionId {
            return "Pause and quit game at any time"
        }
        return nil
    }
    
    func guidedAccessRestrictionWithIdentifier(restrictionIdentifier: String,
        didChangeState newRestrictionState: UIGuidedAccessRestrictionState) {
            
            if restrictionIdentifier == controlsRestrictionId
            {
                let enabled = newRestrictionState != UIGuidedAccessRestrictionState.Deny
                NSNotificationCenter.defaultCenter().postNotificationName(notificationId, object: nil, userInfo: ["restriction":enabled])
            }
    }
}

