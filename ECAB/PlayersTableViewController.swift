//
//  PlayersTableViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

protocol SubjectPickerDelegate {
    func pickSubject(isDefault: Bool)
}

class PlayersTableViewController: UITableViewController {
    
    var delegate: SubjectPickerDelegate!
    
    private let model: Model = Model.sharedInstance
    private let reuseIdentifier = "Subject picker cell"
    
    @IBAction func addPlayerHandler(sender: UIBarButtonItem) {
        
        var alert = UIAlertController(title: "New player",
            message: "Add a name for a new player",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
                
                let textField = alert.textFields![0] as! UITextField
                
                let newPlayer = Player(name: textField.text)
                self.model.players.append(newPlayer)
                
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Cancel) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
        
    }
    
    // MARK: - View Controller life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: reuseIdentifier)
        
        self.clearsSelectionOnViewWillAppear = true;
        // Make row selections not persist.
        
        tableView.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.preferredContentSize = CGSizeMake(200, 200)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath
                            indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier)
            as! UITableViewCell
        
        let player = model.players[indexPath.row]
        let label: UILabel! = cell.textLabel
        label.text = player.name
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.players.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == 0 {
            delegate?.pickSubject(true)
        } else {
            delegate?.pickSubject(false)
        }
    }
}
