//
//  ECABSubjectPickerDataSourceTVC.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

protocol SubjectPickerDelegate {
    func pickDefaultSubject()
    func createNewSubject()
}

class ECABSubjectPickerDataSourceTVC: UITableViewController {
    
    let subjectPickerOptions = ["Current subject", "Add new subject"]
    var delegate: SubjectPickerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false;
        // Make row selections persist.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        delegate?.pickDefaultSubject()
    }
}
