//
//  RedAppleBoard.swift
//  ECAB
//
//  Created by Boris Yurkevich on 25/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class VisualSearchBoard {
    var numberOfCells = 0
    private var numberOfObjectTypes = 3
    var data = Array<TestItem>()
    private var apples = 0
    private var whiteApples = 0
    private var strawberries = 0
    
    init(stage number: Int) { // From 1 to 3

        generateDefaultPattern(forScreen: number)
        
        numberOfCells = data.count
    }
    
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

        var fruits = Array<TestItem>()
        
        for var i = 0; i < apples; i++ {
            let freshApple = TestItem(type: TestItem.Fruit.🍎)
            fruits.append(freshApple)
        }
        
        for var i = 0; i < whiteApples; i++ {
            let freshWhiteApple = TestItem(type: TestItem.Fruit.🍏)
            fruits.append(freshWhiteApple)
        }
        
        for var i = 0; i < strawberries; i++ {
            let strawberry = TestItem(type: TestItem.Fruit.🍓)
            fruits.append(strawberry)
        }
        // Added all 3 types of fruits to the fruits collection
        
        self.data = shuffle(fruits)
    }
    
    func shuffle<C: MutableCollectionType where C.Index == Int>(var list: C) -> C {
        let countNumber = list.count
        for i in 0..<(countNumber - 1) {
            let j = Int(arc4random_uniform(UInt32(countNumber - i))) + i
            swap(&list[i], &list[j])
        }
        return list
    }
    // http://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
    
    func generateDefaultPattern(forScreen section: Int){
        var f = [TestItem]()
        let t = TestItem(type: .🍎) // target (red apple)
        let w = TestItem(type: .🍏) // white apple
        let s = TestItem(type: .🍓) // strawverry
        
        // This is complicated patters copied from PDF file. I separated matrix
        // of fruits in the files to 4 different sections, 5 rows each,
        // 9 fruits in each row
        
        // Typical game will have 3 screens. Which means we have to devide all fruits on three screens.
        // screen == 0 means we wil add all fruits
        
        switch section {
			
		case 0:
			f.append(s); f.append(w); f.append(t);
			break
		case 1:
			f.append(s); f.append(w); f.append(t);
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(s);
			break
		case 2:
			f.append(s); f.append(t); f.append(w); f.append(s); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(s); f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(w); f.append(s); f.append(t); f.append(w);
			break
		case 3:
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(t);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(t); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(t);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(t); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			break;
		case 4:
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(t); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(t);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w);
			
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(t); f.append(w); f.append(w);
			f.append(w);
			break;
		case 5:
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(t); f.append(w); f.append(w);
			f.append(t);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w);
			
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			break;
		case 6:
			f.append(t); f.append(s); f.append(s);
			f.append(w); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(w);
			f.append(s);
			
			f.append(w); f.append(t); f.append(w);
			f.append(s); f.append(w); f.append(s);
			f.append(s); f.append(w); f.append(w);
			f.append(s);
			
			f.append(w); f.append(w); f.append(s);
			f.append(s); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(s);
			f.append(t);
			
			f.append(w); f.append(s); f.append(s);
			f.append(w); f.append(w); f.append(w);
			f.append(t); f.append(s); f.append(s);
			f.append(w);
			
			f.append(t); f.append(w); f.append(s);
			f.append(s); f.append(s); f.append(s);
			f.append(w); f.append(s); f.append(t);
			f.append(w);
			
			f.append(s); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(w); f.append(s);
			f.append(s);
			break;
		case 7:
			f.append(s); f.append(w); f.append(s);
			f.append(s); f.append(w); f.append(s);
			f.append(s); f.append(s); f.append(s);
			f.append(s);
			
			f.append(s);f.append(s); f.append(w);
			f.append(s); f.append(w); f.append(s);
			f.append(t); f.append(w); f.append(t);
			f.append(s);
			
			f.append(w); f.append(s); f.append(s);
			f.append(t); f.append(w); f.append(s);
			f.append(s); f.append(w); f.append(w);
			f.append(s);
			
			f.append(s); f.append(w); f.append(t);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(s); f.append(w);
			f.append(s);
			
			f.append(s); f.append(s); f.append(s);
			f.append(w); f.append(w); f.append(w);
			f.append(s); f.append(w); f.append(s);
			f.append(t);
			
			f.append(s); f.append(s); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(t); f.append(s); f.append(s);
			f.append(w);
			break;
		case 8:
			f.append(t); f.append(s); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(w); f.append(s); f.append(w);
			f.append(w);
			
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(t); f.append(s);
			f.append(s);
			
			f.append(s); f.append(w); f.append(w);
			f.append(s); f.append(s); f.append(s);
			f.append(w); f.append(s); f.append(w);
			f.append(s);
			
			f.append(s); f.append(s); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(s); f.append(s); f.append(s);
			f.append(w);
			
			f.append(w); f.append(t); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(w);
			
			f.append(t); f.append(s); f.append(w);
			f.append(t); f.append(w); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(w);
			break
		case 10:
			break
		case 11:
			f.append(s); f.append(w); f.append(t);
			break
		case 12:
			f.append(s); f.append(w); f.append(t);
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(s);
			break
		case 13:
			f.append(s); f.append(t); f.append(w); f.append(s); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(s); f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(w); f.append(s); f.append(t); f.append(w);
			break
		case 14:
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(t);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(t); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(t);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(t); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(t); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(t);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			break
		case 15:
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w);
			
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(t); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(t); f.append(w); f.append(w);
			f.append(t);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w);
			
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(w); f.append(w);
			f.append(w);
			break
		case 16:
			f.append(t); f.append(s); f.append(s);
			f.append(w); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(w);
			f.append(s);
			
			f.append(w); f.append(t); f.append(w);
			f.append(s); f.append(w); f.append(s);
			f.append(s); f.append(w); f.append(w);
			f.append(s);
			
			f.append(w); f.append(w); f.append(s);
			f.append(s); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(s);
			f.append(t);
			
			f.append(w); f.append(s); f.append(s);
			f.append(w); f.append(w); f.append(w);
			f.append(t); f.append(s); f.append(s);
			f.append(w);
			
			f.append(t); f.append(w); f.append(s);
			f.append(s); f.append(s); f.append(s);
			f.append(w); f.append(s); f.append(t);
			f.append(w);
			
			f.append(s); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(w); f.append(s);
			f.append(s);
			
			f.append(s); f.append(w); f.append(s);
			f.append(s); f.append(w); f.append(s);
			f.append(s); f.append(s); f.append(s);
			f.append(s);
			
			f.append(s);f.append(s); f.append(w);
			f.append(s); f.append(w); f.append(s);
			f.append(t); f.append(w); f.append(t);
			f.append(s);
			
			f.append(w); f.append(s); f.append(s);
			f.append(t); f.append(w); f.append(s);
			f.append(s); f.append(w); f.append(w);
			f.append(s);
			break
		case 17:
			f.append(s); f.append(w); f.append(t);
			f.append(w); f.append(w); f.append(w);
			f.append(w); f.append(s); f.append(w);
			f.append(s);
			
			f.append(s); f.append(s); f.append(s);
			f.append(w); f.append(w); f.append(w);
			f.append(s); f.append(w); f.append(s);
			f.append(t);
			
			f.append(s); f.append(s); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(t); f.append(s); f.append(s);
			f.append(w);
			
			f.append(t); f.append(s); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(w); f.append(s); f.append(w);
			f.append(w);
			
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(t); f.append(w);
			f.append(w); f.append(t); f.append(s);
			f.append(s);
			
			f.append(s); f.append(w); f.append(w);
			f.append(s); f.append(s); f.append(s);
			f.append(w); f.append(s); f.append(w);
			f.append(s);
			
			f.append(s); f.append(s); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(s); f.append(s); f.append(s);
			f.append(w);
			
			f.append(w); f.append(t); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(w);
			
			f.append(t); f.append(s); f.append(w);
			f.append(t); f.append(w); f.append(w);
			f.append(s); f.append(w); f.append(w);
			f.append(w);
			break
        default:
            print("⛔️ Set correct screen!")
        }
        data = f
    }
}