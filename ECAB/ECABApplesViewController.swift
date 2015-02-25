//
//  ECABApplesViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABApplesViewController: UIViewController, SubjectPickerDelegate, UIPopoverPresentationControllerDelegate
{
    private struct Segues {
        static let startApplesGame = "Start apples game"
        static let openSubjectsPopover = "Open subjects popover"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let identifier = segue.identifier {
            switch identifier {
            case Segues.openSubjectsPopover:
                if let tvc = segue.destinationViewController as? ECABSubjectPickerDataSourceTVC {
                    if let ppc = tvc.popoverPresentationController {
                        ppc.delegate = self;
                    }
                    tvc.delegate = self
                }
            case Segues.startApplesGame:
                if let cvc = segue.destinationViewController as? ECABApplesCollectionViewController {
                    cvc.presenter = self
                }
            default: break;
            }
        }
    }
    
    // MARK: <SubjectPickerDelegate>
    
    func pickSubject(isDefault: Bool) {
        // TODO implement this
    }
}
