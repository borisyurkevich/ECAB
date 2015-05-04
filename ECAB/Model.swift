//
//  Model.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class Model {
    private var subjects = Array<Player>()
    var subject: Player
    
    let games = [RedAppleGame(), FishesAndMiceGame()]
    let currentView = 0
    
    init() {
        if subjects.count == 0 {
            let subject = Player()
            subjects.append(subject)
            println("Default test subject created")
            // Creates default test subject
        }
        self.subject = subjects[0]
    }
    
    class var sharedInstance: Model {
        struct Singleton {
            static let instance = Model()
        }
        
        return Singleton.instance
    }
}
