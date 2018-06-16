//
//  FlankerBlock.swift
//  ECAB
//
//  Created by Boris Yurkevich on 16/06/2018.
//  Copyright © 2018 Oliver Braddick and Jan Atkinson. All rights reserved.
//

enum FlankerBlock: Int {
    case example
    case practice1
    case practice2
    case nonConflict1
    case conflict2
    case conflict3
    case nonConflict4
    
    var title: String {
        switch self {
        case .example:
            return "Example"
        case .practice1:
            return "Practice 1"
        case .practice2:
            return "Practice 2"
        case .nonConflict1:
            return "Block 1 Non Conflict"
        case .conflict2:
            return "Block 2 Conflict"
        case .conflict3:
            return "Block 3 Conflict"
        case .nonConflict4:
            return "Block 3 Non Conflict"
        }
    }
}
