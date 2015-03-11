//
//  RedAppleBoard.swift
//  ECAB
//
//  Created by Boris Yurkevich on 25/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class RedAppleBoard {
    var numberOfCells = 0
    private var numberOfObjectTypes = 3
    var data = Array<GamePeace>()
    private let apples: Int
    private let whiteApples: Int
    private let strawberries: Int
    
    init(targets realTargets: Int,
                 fakeTargers: Int,
                otherTargets: Int){
                    
        apples = realTargets
        whiteApples = fakeTargers
        strawberries = otherTargets
                    
        numberOfCells = apples + whiteApples + strawberries
        
        if numberOfCells == 0 {
            fatalError("🚫 You need to add at least one game object to board")
        }
        generateDifferentFruits()
    }
    
    func generateDifferentFruits(){

        var fruits = Array<GamePeace>()
        
        for var i = 0; i < apples; i++ {
            let freshApple = GamePeace(type: GamePeace.Fruit.🍎)
            fruits.append(freshApple)
        }
        
        for var i = 0; i < whiteApples; i++ {
            let freshWhiteApple = GamePeace(type: GamePeace.Fruit.🍏)
            fruits.append(freshWhiteApple)
        }
        
        for var i = 0; i < strawberries; i++ {
            let strawberry = GamePeace(type: GamePeace.Fruit.🍓)
            fruits.append(strawberry)
        }
        // Added all 3 types of fruits to the fruits collection
        
        self.data = shuffle(fruits)
    }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let countNumber = count(list)
        for i in 0..<(countNumber - 1) {
            let j = Int(arc4random_uniform(UInt32(countNumber - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
    // http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

}
