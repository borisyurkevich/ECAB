//
//  SettingsTableViewController.swift
//  ECAB
//
//  Created by Raphaël Bertin on 02/08/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    // MARK: - Table view data source
    
    var data: [[String]] = [["Voice", "Text to speech setting"]]
    
    // MARK: - UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    // MARK: — Table View delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let navVC = splitViewController!.viewControllers.last as! UINavigationController
        let settingslVC = navVC.topViewController as! SettingsViewController
        settingslVC.showSettings(indexPath.row)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingCell", forIndexPath: indexPath) 
        cell.textLabel?.text = data[indexPath.row][0]
        cell.detailTextLabel?.text = data[indexPath.row][1]
        return cell
    }
}