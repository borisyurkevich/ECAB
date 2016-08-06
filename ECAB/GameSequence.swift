//
//  GameSequence.swift
//  ECAB
//  Represent a screen during a Game
//
//  Created by Raphaël Bertin on 29/06/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class GameSequence {
    
    let picture: Picture
    let sound: String

    init(p: Picture) {
        picture = p;
        sound = "";
    }
    
    init(s: String) {
        picture = Picture.Empty;
        sound = s;
    }
    
    init(p: Picture, s: String) {
        picture = p;
        sound = s;
    }
}
