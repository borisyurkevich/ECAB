//
//  SettingsViewController.swift
//  ECAB
//
//  Created by Raphaël Bertin on 01/08/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    var data: [[String]] = [["Voice", "Text to speech setting"]]
    
    func showSettings(row: Int) {
        
        switch row {
            case 0:
                let alert = UIAlertController(title: "Voice", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                break
            default:
            
                break
        }
    }
}

