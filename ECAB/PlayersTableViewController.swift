//
//  PlayersTableViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

protocol SubjectPickerDelegate {
    func pickSubject()
}

class PlayersTableViewController: UITableViewController {
    
    var delegate: SubjectPickerDelegate!
    
    private let model: Model = Model.sharedInstance
    private let reuseIdentifier = "Subject picker cell"
    
    @IBAction func addPlayerHandler(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New player",
            message: "Add a name for a new player",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction) -> Void in
                
                let textField = alert.textFields![0] 
                
                self.model.addPlayer(textField.text!)
                
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Cancel) { (action: UIAlertAction) -> Void in
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
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as UITableViewCell!
        
		let data = model.data as Data
		let players = data.players
		let player = players[indexPath.row] as! Player
								
        let label: UILabel! = cell.textLabel
        label.text = player.name
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.data.players.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Make selected player current player
		let data = model.data as Data
        let selectedPlayerEntity = data.players[indexPath.row] as! Player
        model.data.selectedPlayer = selectedPlayerEntity
		
		model.save()
		
        delegate?.pickSubject()
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle
        editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete{

            let player: Player = model.data.players[indexPath.row] as! Player
            model.managedContext.deleteObject(player)
            
            var error: NSError?
            do {
                try model.managedContext.save()
            } catch let error1 as NSError {
                error = error1
                print("Could not save after delete: \(error)")
            }
            
            // Last step
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
}
