//
//  ECABGameBoard.swift
//  ECAB
//
//  Created by Boris Yurkevich on 25/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABGameBoard {
    var numberOfCells = 0
    private var numberOfObjectTypes = 3
    var data = Array<ECABGamePeace>()
    
    init(targets realTargets: Int,
              fakeTargers: Int,
              otherTargets: Int){
        self.numberOfCells = realTargets + fakeTargers + otherTargets
        generateDifferentFruits(targets: realTargets, whiteApples: fakeTargers, strawberries: otherTargets)
    }
    
    func generateDifferentFruits(targets apples: Int, whiteApples: Int, strawberries: Int){
        let summ = apples+whiteApples+strawberries
        var fruits = Array<ECABGamePeace>()
        
        for var i = 0; i <= apples; i++ {
            let freshApple = ECABGamePeace(type: ECABGamePeace.Fruit.🍎)
            fruits.append(freshApple)
        }
        
        for var i = 0; i <= whiteApples; i++ {
            let freshWhiteApple = ECABGamePeace(type: ECABGamePeace.Fruit.🍏)
            fruits.append(freshWhiteApple)
        }
        
        for var i = 0; i <= whiteApples; i++ {
            let strawberry = ECABGamePeace(type: ECABGamePeace.Fruit.🍓)
            fruits.append(strawberry)
        }
        // Added all 3 types of fruits to the fruits collection
        
        self.data = shuffle(fruits)
    }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let count = countElements(list)
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
    // http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

}
