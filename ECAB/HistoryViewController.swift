//
//  HistoryViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    
    var currentSubject: Player?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentSubject = Model.sharedInstance.subject
        update()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        update()
    }
    
    func update() {
        
        var name: String
        var surname: String
        var age: Int
        
        if currentSubject?.name != nil {
            name = currentSubject!.name
        } else {
            name = "New"
        }
        if currentSubject?.surname != nil {
            surname = currentSubject!.surname
        } else {
            surname = "Player"
        }
        if (currentSubject?.age != nil) {
            age = currentSubject!.age
            ageLabel.text = String(age)
        } else {
            ageLabel.text = "Unknown"
        }
        
        self.title = "\(name) \(surname)"
        
        if (currentSubject?.sessions.last != nil) {
            let session = currentSubject?.sessions.last
            let score = session!.score
            scoresLabel.text = String(score.scores)
        }
    }
}
