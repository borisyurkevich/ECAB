//
//  ECABGameBoard.swift
//  ECAB
//
//  Created by Boris Yurkevich on 25/01/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABGameBoard {
    private var numberOfCells = 0
    private var numberOfObjectTypes = 3
    private var field: Field
    
    init(with rows: Int,
            colums: Int,
  realTouchTargets: Int,
  fakeTouchTargers: Int,
  otherFakeTargets: Int)
    {
        self.field = Field(rows: rows, columns: colums)
        self.numberOfCells = self.field.columns * self.field.rows
        
        if ((realTouchTargets +
            fakeTouchTargers +
            otherFakeTargets) != self.numberOfCells) {
            fatalError("Please set correct field size and game peaces count")
        } else {
            for var i = 0; i < self.numberOfCells; i++ {
                println("adding one more \(i)")
            }
        }
    }
    
    struct Field {
        let rows: Int, columns: Int
        var grid: [ECABGamePeace]
        init(rows: Int, columns: Int) {
            self.rows = rows
            self.columns = columns
            grid = Array(count: rows * columns, repeatedValue: ECABGamePeace(type: ECABGamePeace.Fruit.🍎))
        }
    }
}
