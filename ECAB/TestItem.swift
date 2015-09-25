//
//  GamePeaceType.swift
//  ECAB
//
//  Created by Boris Yurkevich on 25/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class TestItem {
    
    enum Fruit {
        case 🍎, 🍏, 🍓
    }
    
    let type: Fruit
    let isValuable: Bool
    let image: UIImage!
    
    init(type: Fruit) {
        if (type == .🍎) {
            self.type = .🍎
            self.isValuable = true
            self.image = UIImage(named: "red_apple")
        } else if (type == .🍏) {
            self.type = .🍏
            self.isValuable = false
            self.image = UIImage(named: "white_apple")
        } else if (type == .🍓) {
            self.type = .🍓
            self.isValuable = false
            self.image = UIImage(named: "red_strawberry")
        } else {
            fatalError("Game peace can be only of certain type: 🍎, 🍏, or 🍓")
        }
        
        
    }
   
}
