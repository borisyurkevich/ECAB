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
    
    func pickDefaultSubject() {
        let gameController = ECABApplesCollectionViewController()
//        self.presentViewController(gameController, animated: true, completion: nil)
        self.performSegueWithIdentifier("startApplesGame", sender: self)
        println("Show default delgate")
    }
    
    func createNewSubject() {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
