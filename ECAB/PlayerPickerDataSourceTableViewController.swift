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
    
    let subjectPickerOptions = ["Current subject", "Other subject"]
    var delegate: SubjectPickerDelegate!
    private let reuseIdentifier = "Subject picker cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false;
        // Make row selections persist.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.preferredContentSize = CGSizeMake(200, 200)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath
                            indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell(style: UITableViewCellStyle.Value1,
                         reuseIdentifier: nil)
        let name: String = subjectPickerOptions[indexPath.row]
        let label: UILabel! = cell.textLabel
        label.text = name
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjectPickerOptions.count
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row == 0 {
            delegate?.pickSubject(true)
        } else {
            delegate?.pickSubject(false)
        }
    }
}
