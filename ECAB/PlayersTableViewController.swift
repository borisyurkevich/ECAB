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
    
    fileprivate let model: Model = Model.sharedInstance
    fileprivate let reuseIdentifier = "Subject picker cell"
    
    @IBAction func addPlayerHandler(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New player",
            message: "Add a name for a new player",
            preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .default) { (action: UIAlertAction) -> Void in
                
                let textField = alert.textFields![0] 
                
                self.model.addPlayer(textField.text!)
                
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .cancel) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextField {
            (textField: UITextField!) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert,
            animated: true,
            completion: nil)
        
    }
    
    // MARK: - View Controller life
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self,
            forCellReuseIdentifier: reuseIdentifier)
        
        self.clearsSelectionOnViewWillAppear = true;
        // Make row selections not persist.
        
        tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.preferredContentSize = CGSize(width: 200, height: 200)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, cellForRowAt
                            indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        
		let data = model.data as Data
		let players = data.players
		let player = players[indexPath.row] as! Player
								
        let label: UILabel! = cell!.textLabel
        label.text = player.name
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.data.players.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Make selected player current player
		let data = model.data as Data
        let selectedPlayerEntity = data.players[indexPath.row] as! Player
        model.data.selectedPlayer = selectedPlayerEntity
		
		model.save()
		
        delegate?.pickSubject()
    }
}
