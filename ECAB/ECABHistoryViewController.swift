//
//  ECABHistoryViewController.swift
//  ECAB
//
//  Created by Boris Yurkevich on 18/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABHistoryViewController: UIViewController {

    @IBOutlet var labels: [UILabel]!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var gameNameLabel: UILabel!
    @IBOutlet weak var scoresLabel: UILabel!
    
    var currentSubject: ECABSubject?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentSubject = ECABData.sharedInstance.subject
        update()
    }
    
    func update() {
        nameLabel.text = currentSubject?.name
        surnameLabel.text = currentSubject?.surname
        ageLabel.text = String(currentSubject!.age)
        
        if (currentSubject?.sessions.last != nil) {
            let session = currentSubject?.sessions.last
            let score = session!.score
            scoresLabel.text = String(score.scores)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
