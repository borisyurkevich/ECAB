//
//  ECABLogCalculator.swift
//  ECAB
//
//  Created by Boris Yurkevich on 31/01/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

struct TotalVisualSearch {
    var motorOneTotal: Double
    var motorTwoTotal: Double
    var motorThreeTotal: Double
    var searachOneTotal: Double
    var searchTwoTotal: Double
    var searhThreeTotal: Double
    var average: Average
}

// Time per target
struct Average {
    var motor: Double
    var search: Double
}


class ECABLogCalculator {
    
    // 1000.0 is Milliseconds in one second
    class func r(x:NSTimeInterval) -> Double {
        return Double(round(100.0 * x) / 100.0)
    }
    
    class func getVisualSearchTotals(session: Session) -> TotalVisualSearch {
        
        let avg = Average(motor: 0, search: 0)
        
        var totals = TotalVisualSearch(motorOneTotal: 0, motorTwoTotal: 0, motorThreeTotal: 0, searachOneTotal: 0, searchTwoTotal: 0, searhThreeTotal: 0, average: avg)
        
        var motorOneStart: NSDate?
        var motorOneEnd: NSDate?
        var motorTwoStart: NSDate?
        var motorTwoEnd: NSDate?
        var motorThreeStart: NSDate?
        var motorThreeEnd: NSDate?
        var searchOneStart: NSDate?
        var searchOneEnd: NSDate?
        var searchTwoStart: NSDate?
        var searchTwoEnd: NSDate?
        var searchThreeStart:NSDate?
        var searchThreeEnd:NSDate?
        
        var motorHits = 0
        var searchHits = 0
        
        for move in session.moves {
            let gameMove = move as! Move
            
            let screenNum = gameMove.screenNumber.integerValue
            
            // Every part inlude onset date in the empty move entity
            
            if screenNum == VisualSearchEasyModeView.MotorOne.rawValue || screenNum == VisualSearchHardModeView.MotorOne.rawValue {
                if (motorOneStart == nil) {
                    motorOneStart = gameMove.date
                }
                // End date will shift to the latest possible move on the screen
                motorOneEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    motorHits += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.MotorTwo.rawValue || screenNum == VisualSearchHardModeView.MotorTwo.rawValue{
                if (motorTwoStart == nil) {
                    motorTwoStart = gameMove.date
                }
                motorTwoEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    motorHits += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.MotorThree.rawValue {
                if (motorThreeStart == nil) {
                    motorThreeStart = gameMove.date
                }
                motorThreeEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    motorHits += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.One.rawValue || screenNum == VisualSearchHardModeView.One.rawValue {
                if (searchOneStart == nil) {
                    searchOneStart = gameMove.date
                }
                searchOneEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    searchHits += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.Two.rawValue || screenNum == VisualSearchHardModeView.Two.rawValue {
                if (searchTwoStart == nil) {
                    searchTwoStart = gameMove.date
                }
                searchTwoEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    searchHits += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.Three.rawValue {
                if (searchThreeStart == nil) {
                    searchThreeStart = gameMove.date
                }
                searchThreeEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    searchHits += 1
                }
            }
            
        }
        if let m1s = motorOneStart, let m1e = motorOneEnd {
            totals.motorOneTotal = r(m1e.timeIntervalSinceDate(m1s))
        }
        if let m2s = motorTwoStart, let m2e = motorTwoEnd {
            totals.motorTwoTotal = r(m2e.timeIntervalSinceDate(m2s))
        }
        if let m3s = motorThreeStart, let m3e = motorThreeEnd {
            totals.motorThreeTotal = r(m3e.timeIntervalSinceDate(m3s))
        }
        if let s1s = searchOneStart, let s1e = searchOneEnd {
            totals.searachOneTotal = r(s1e.timeIntervalSinceDate(s1s))
        }
        if let s2s = searchTwoStart, let s2e = searchTwoEnd {
            totals.searchTwoTotal = r(s2e.timeIntervalSinceDate(s2s))
        }
        if let s3s = searchThreeStart, let s3e = searchThreeEnd {
            totals.searhThreeTotal = r(s3e.timeIntervalSinceDate(s3s))
        }
        
        let totalTimeMotor = totals.motorOneTotal + totals.motorTwoTotal + totals.motorThreeTotal
        let totalTimeSearch = totals.searachOneTotal + totals.searchTwoTotal + totals.searhThreeTotal
        
        totals.average.motor = r(totalTimeMotor / Double(motorHits))
        totals.average.search = r(totalTimeSearch / Double(searchHits))
    
        return totals
    }
}
