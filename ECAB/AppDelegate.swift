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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
		
		let tabBarController = self.window!.rootViewController as! UITabBarController
		let allTabs: Array = tabBarController.viewControllers!;
		let splitController = allTabs[0] as! UISplitViewController
		let navigationController = splitController.viewControllers.last as! UINavigationController
		let viewController = navigationController.topViewController  as! MenuViewController
		viewController.managedContext = coreDataStack.context
		
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
		coreDataStack.saveContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
		coreDataStack.saveContext()
    }

    // MARK: - UIGuidedAccessRestrictionDelegate
    
    let controlsRestrictionId = "net.borisy.ecab.ControlsRestrictionId"
    let notificationId = "kECABGuidedAccessNotification"
    
    var guidedAccessRestrictionIdentifiers: [String]? {
        return [controlsRestrictionId]
    }
    
    func textForGuidedAccessRestriction(withIdentifier restrictionIdentifier: String) -> String? {
        if restrictionIdentifier == controlsRestrictionId {
            return "Pause button"
        }
        return nil
    }
    
    func detailTextForGuidedAccessRestriction(withIdentifier restrictionIdentifier: String) -> String? {
        if restrictionIdentifier == controlsRestrictionId {
            return "Pause and quit game at any time"
        }
        return nil
    }
    
    func guidedAccessRestriction(withIdentifier restrictionIdentifier: String,
        didChange newRestrictionState: UIGuidedAccessRestrictionState) {
            
            if restrictionIdentifier == controlsRestrictionId
            {
                let enabled = newRestrictionState != UIGuidedAccessRestrictionState.deny
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationId), object: nil, userInfo: ["restriction":enabled])
            }
    }
}

