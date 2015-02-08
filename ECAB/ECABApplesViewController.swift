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

    @IBAction func openPopUp(sender: UIBarButtonItem) {
        let popOverContentVC = ECABSubjectPickerDataSourceTVC()
        let popOver = UIPopoverController(contentViewController: popOverContentVC)
        
        popOverContentVC.delegate = self

        popOverContentVC.modalPresentationStyle = .Popover
        popOverContentVC.preferredContentSize = CGSizeMake(200, 140)
        
        popOver.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: UIPopoverArrowDirection(1), animated: true)
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
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.destinationViewController.isKindOfClass(ECABSubjectPickerDataSourceTVC) {
            var popOver = segue.destinationViewController as ECABSubjectPickerDataSourceTVC
            popOver.delegate = self
        }
    }

}
