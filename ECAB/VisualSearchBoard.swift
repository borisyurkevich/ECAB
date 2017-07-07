//
//  RedAppleBoard.swift
//  ECAB
//
//  Created by Boris Yurkevich on 25/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

enum VisualSearchEasyModeView: Int {
    case trainingOne = 0
    case trainingTwo = 1
    case trainingThree = 2
    case motorOne = 3
    case motorTwo = 4
    case motorThree = 5
    case one = 6
    case two = 7
    case three = 8
}

enum VisualSearchHardModeView: Int {
    case trainingOne = 11
    case trainingTwo = 12
    case trainingThree = 13
    case motorOne = 14
    case motorTwo = 15
    case one = 16
    case two = 17
}

struct VisualSearchTargets {
    static let easyMode = [1, 1, 2, 6, 6, 6, 6, 6, 6]
    static let hardMode = [1, 1, 2, 9, 9, 9, 9]
}

struct VisualSearchSpeed {
    static let easyMode = 20.0
    static let hardMode = 30.0 // Default value, can be changed in CoreData
}

class VisualSearchBoard {
    var numberOfCells = 0
    fileprivate var numberOfObjectTypes = 3
    var data = Array<TestItem>()
    fileprivate var apples = 0
    fileprivate var whiteApples = 0
    fileprivate var strawberries = 0
    
    
    init(stage number: Int) { // From 1 to 3

        generateDefaultPattern(forScreen: number)
        
        numberOfCells = data.count
    }
    
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
			
		case VisualSearchEasyModeView.trainingOne.rawValue:
			f.append(s); f.append(w); f.append(t);
		case VisualSearchEasyModeView.trainingTwo.rawValue:
			f.append(s); f.append(w); f.append(t);
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(s);
		case VisualSearchEasyModeView.trainingThree.rawValue:
			f.append(s); f.append(t); f.append(w); f.append(s); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(s); f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(w); f.append(s); f.append(t); f.append(w);
		case VisualSearchEasyModeView.motorOne.rawValue:
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
		case VisualSearchEasyModeView.motorTwo.rawValue:
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
		case VisualSearchEasyModeView.motorThree.rawValue:
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
		case VisualSearchEasyModeView.one.rawValue:
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
		case VisualSearchEasyModeView.two.rawValue:
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
		case VisualSearchEasyModeView.three.rawValue:
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
		case VisualSearchHardModeView.trainingOne.rawValue:
			f.append(s); f.append(w); f.append(t);
		case VisualSearchHardModeView.trainingTwo.rawValue:
			f.append(s); f.append(w); f.append(t);
			f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(s);
		case VisualSearchHardModeView.trainingThree.rawValue:
			f.append(s); f.append(t); f.append(w); f.append(s); f.append(w); f.append(s);
			f.append(w); f.append(s); f.append(s); f.append(w); f.append(s); f.append(w);
			f.append(w); f.append(s); f.append(w); f.append(s); f.append(t); f.append(w);
		case VisualSearchHardModeView.motorOne.rawValue:
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
		case VisualSearchHardModeView.motorTwo.rawValue:
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
		case VisualSearchHardModeView.one.rawValue:
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
		case VisualSearchHardModeView.two.rawValue:
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
