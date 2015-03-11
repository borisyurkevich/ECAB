//
//  Player.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class Player {
    
    var name: String
    var surname: String
    var age: Int
    var sessions = [Session]()
    
    init() {
        self.name = "New"
        self.surname = "Player"
        self.age = 0
    }
    
    init(name: String, surname: String, age: Int) {
        self.name = name
        self.surname = surname
        self.age = age
    }
    
}
