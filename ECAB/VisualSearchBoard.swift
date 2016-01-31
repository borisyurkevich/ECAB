//
//  RedAppleBoard.swift
//  ECAB
//
//  Created by Boris Yurkevich on 25/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

enum VisualSearchEasyModeView: Int {
    case TrainingOne = 0
    case TrainingTwo = 1
    case TrainingThree = 2
    case MotorOne = 3
    case MotorTwo = 4
    case MotorThree = 5
    case One = 6
    case Two = 7
    case Three = 8
}

enum VisualSearchHardModeView: Int {
    case TrainingOne = 11
    case TrainingTwo = 12
    case TrainingThree = 13
    case MotorOne = 14
    case MotorTwo = 15
    case One = 16
    case Two = 17
}

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
			
		case VisualSearchEasyModeView.TrainingOne.rawValue:
			f.append(s); f.append(w); f.append(t);
		case VisualSearchEasyModeView.TrainingTwo.rawValue:
			f.append(s); f.append(w); f.append(t);
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(s);
		case VisualSearchEasyModeView.TrainingThree.rawValue:
			f.append(s); f.append(t); f.append(w); f.append(s); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(s); f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(w); f.append(s); f.append(t); f.append(w);
		case VisualSearchEasyModeView.MotorOne.rawValue:
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
		case VisualSearchEasyModeView.MotorTwo.rawValue:
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
		case VisualSearchEasyModeView.MotorThree.rawValue:
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
		case VisualSearchEasyModeView.One.rawValue:
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
		case VisualSearchEasyModeView.Two.rawValue:
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
		case VisualSearchEasyModeView.Three.rawValue:
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
		case 10:
            break
		case VisualSearchHardModeView.TrainingOne.rawValue:
			f.append(s); f.append(w); f.append(t);
		case VisualSearchHardModeView.TrainingTwo.rawValue:
			f.append(s); f.append(w); f.append(t);
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(s);
		case VisualSearchHardModeView.TrainingThree.rawValue:
			f.append(s); f.append(t); f.append(w); f.append(s); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(s); f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(w); f.append(s); f.append(t); f.append(w);
		case VisualSearchHardModeView.MotorOne.rawValue:
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
		case VisualSearchHardModeView.MotorTwo.rawValue:
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
		case VisualSearchHardModeView.One.rawValue:
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
		case VisualSearchHardModeView.Two.rawValue:
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
        default:
            print("⛔️ Set correct screen!")
        }
        data = f
    }
}
