//
//  ECABApplesViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABApplesViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func openPopUp(sender: UIBarButtonItem) {
        let popOverContentVC = ECABSubjectPickerDataSourceTVC()
        let popOver = UIPopoverController(contentViewController: popOverContentVC)

        popOverContentVC.modalPresentationStyle = .Popover
        popOverContentVC.preferredContentSize = CGSizeMake(200, 200)
        
        popOver.presentPopoverFromBarButtonItem(sender, permittedArrowDirections: UIPopoverArrowDirection(1), animated: true)
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
