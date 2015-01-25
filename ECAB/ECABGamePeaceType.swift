//
//  ECABGamePeaceType.swift
//  ECAB
//
//  Created by Boris Yurkevich on 25/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABGamePeaceType: NSObject {
    
    let 🍎 = "ECABGamePeaceTypeRedApple"
    let 🍏 = "ECABGamePeaceTyeGreenApple"
    let 🍓 = "ECABGamePeaceTypeRedStrawberry"
    
    let type: String
    var isCrossed = false
    let isValuable: Bool
    let image: UIImage!
    
    init(type: String) {
        if (type == self.🍎) {
            self.type = self.🍎
            self.isValuable = true
            self.image = UIImage(named: "red_apple")
        } else if (type == self.🍏) {
            self.type = self.🍏
            self.isValuable = false
        } else if (type == self.🍓) {
            self.type = 🍓
            self.isValuable = false
        } else {
            fatalError("Game peace can be only of certain type: 🍎, 🍏, or 🍓")
        }
        
        
    }
   
}
