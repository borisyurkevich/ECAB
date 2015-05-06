//
//  Session.swift
//  ECAB
//
//  Created by Boris Yurkevich on 05/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class Session {
    let type: Game
    let subject: Player
    let score = Result()
    
    // For Red Apple Game, describes selected index
    var selectedItemsIndex = [Int]()
    
    init(with gameType: Game, subject: Player) {
        self.type = gameType
        self.subject = subject
    }
    // To start session call init
    
    func end() {
        println("Session ended with total scores: \(score.scores)")
    }
}
