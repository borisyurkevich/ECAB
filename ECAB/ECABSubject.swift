//
//  ECABSubject.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABSubject {
    
    var name: String
    var surname: String
    var age: Int
    
    init() {
        self.name = "New subject"
        self.surname = ""
        self.age = 0
    }
    
    init(name: String, surname: String, age: Int) {
        self.name = name
        self.surname = surname
        self.age = age
    }
    
}
