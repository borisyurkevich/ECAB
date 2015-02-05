//
//  ECABSession.swift
//  ECAB
//
//  Created by Boris Yurkevich on 05/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABSession {
    let type: ECABGame
    let subject: ECABSubject
    let score = ECABResult()
    
    init(with gameType: ECABGame, subject: ECABSubject) {
        self.type = gameType
        self.subject = subject
    }
    // To start session call init
    
    func end() {
        println("Session ended with total scores: \(score.scores)")
    }
}
