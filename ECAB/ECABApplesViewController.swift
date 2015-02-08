//
//  ECABApplesViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABApplesViewController: UIViewController, SubjectPickerDelegate
{
    var isStatusBarHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func pickSubject(isDefault: Bool) {
        self.performSegueWithIdentifier("startApplesGame", sender: self)
        
        self.isStatusBarHidden = true
        self.setNeedsStatusBarAppearanceUpdate()
        
        if isDefault {
            println("Def sub picked")
        } else {
            println("Not default subject picked")
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return self.isStatusBarHidden
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.destinationViewController.isKindOfClass(UINavigationController) {
            var nav = segue.destinationViewController as UINavigationController
            var popOver = nav.topViewController as ECABSubjectPickerDataSourceTVC
            popOver.delegate = self
        }
    }

}
