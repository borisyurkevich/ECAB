//
//  ECABLogCalculator.swift
//  ECAB
//
//  Created by Boris Yurkevich on 31/01/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

struct TotalVisualSearch {
    var motorOneTotal: NSTimeInterval
    var motorTwoTotal: NSTimeInterval
    var motorThreeTotal: NSTimeInterval
    var searchOneTotal: NSTimeInterval
    var searchTwoTotal: NSTimeInterval
    var searchThreeTotal: NSTimeInterval
    var average: Average
    var motorHits1 = 0
    var motorHits2 = 0
    var motorHits3 = 0
    var searchHits1 = 0
    var searchHits2 = 0
    var searchHits3 = 0
    var motorFalse1 = 0
    var motorFalse2 = 0
    var motorFalse3 = 0
    var searchFalse1 = 0
    var searchFalse2 = 0
    var searchFalse3 = 0
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
        
        var totals = TotalVisualSearch(motorOneTotal: 0, motorTwoTotal: 0, motorThreeTotal: 0, searchOneTotal: 0, searchTwoTotal: 0, searchThreeTotal: 0, average: avg, motorHits1: 0, motorHits2: 0, motorHits3: 0, searchHits1: 0, searchHits2: 0, searchHits3: 0, motorFalse1:  0, motorFalse2: 0, motorFalse3: 0, searchFalse1: 0, searchFalse2: 0, searchFalse3: 0)
        
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
                    totals.motorHits1 += 1
                } else {
                    totals.motorFalse1 += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.MotorTwo.rawValue || screenNum == VisualSearchHardModeView.MotorTwo.rawValue{
                if (motorTwoStart == nil) {
                    motorTwoStart = gameMove.date
                }
                motorTwoEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    totals.motorHits2 += 1
                } else {
                    totals.motorFalse2 += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.MotorThree.rawValue {
                if (motorThreeStart == nil) {
                    motorThreeStart = gameMove.date
                }
                motorThreeEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    totals.motorHits3 += 1
                } else {
                    totals.motorFalse3 += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.One.rawValue || screenNum == VisualSearchHardModeView.One.rawValue {
                if (searchOneStart == nil) {
                    searchOneStart = gameMove.date
                }
                searchOneEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    totals.searchHits1 += 1
                } else {
                    totals.searchFalse1 += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.Two.rawValue || screenNum == VisualSearchHardModeView.Two.rawValue {
                if (searchTwoStart == nil) {
                    searchTwoStart = gameMove.date
                }
                searchTwoEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    totals.searchHits2 += 1
                } else {
                    totals.searchFalse2 += 1
                }
                
            } else if screenNum == VisualSearchEasyModeView.Three.rawValue {
                if (searchThreeStart == nil) {
                    searchThreeStart = gameMove.date
                }
                searchThreeEnd = gameMove.date
                
                if gameMove.success.boolValue == true {
                    totals.searchHits3 += 1
                } else {
                    totals.searchFalse3 += 1
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
            totals.searchOneTotal = r(s1e.timeIntervalSinceDate(s1s))
        }
        if let s2s = searchTwoStart, let s2e = searchTwoEnd {
            totals.searchTwoTotal = r(s2e.timeIntervalSinceDate(s2s))
        }
        if let s3s = searchThreeStart, let s3e = searchThreeEnd {
            totals.searchThreeTotal = r(s3e.timeIntervalSinceDate(s3s))
        }
        
        // When not all targets hits totals need to be increased to the 
        // amount of time screen is visible
        if session.difficulty == Difficulty.Easy.rawValue {
            
            if totals.motorHits1 < VisualSearchTargets.easyMode[3] {
               totals.motorOneTotal = session.speed.doubleValue
            }
            if totals.motorHits2 < VisualSearchTargets.easyMode[4] {
                totals.motorTwoTotal = session.speed.doubleValue
            }
            if totals.motorHits3 < VisualSearchTargets.easyMode[5] {
                totals.motorThreeTotal = session.speed.doubleValue
            }
            if totals.searchHits1 < VisualSearchTargets.easyMode[6] {
                totals.searchOneTotal = session.speed.doubleValue
            }
            if totals.searchHits2 < VisualSearchTargets.easyMode[7] {
                totals.searchTwoTotal = session.speed.doubleValue
            }
            if totals.searchHits3 < VisualSearchTargets.easyMode[8] {
                totals.searchThreeTotal = session.speed.doubleValue
            }
            
        } else if session.difficulty == Difficulty.Hard.rawValue {
            
            if totals.motorHits1 < VisualSearchTargets.hardMode[3] {
                totals.motorOneTotal = session.speed.doubleValue
            }
            if totals.motorHits2 < VisualSearchTargets.hardMode[4] {
                totals.motorTwoTotal = session.speed.doubleValue
            }
            if totals.searchHits1 < VisualSearchTargets.hardMode[5] {
                totals.searchOneTotal = session.speed.doubleValue
            }
            if totals.searchHits2 < VisualSearchTargets.hardMode[6] {
                totals.searchTwoTotal = session.speed.doubleValue
            }
        }
        
        let totalTimeMotor = totals.motorOneTotal + totals.motorTwoTotal + totals.motorThreeTotal
        let totalTimeSearch = totals.searchOneTotal + totals.searchTwoTotal + totals.searchThreeTotal
        
        let motorHits = totals.motorHits1 + totals.motorHits2 + totals.motorHits3
        let searchHits = totals.searchHits1 + totals.searchHits2 + totals.searchHits3
        
        totals.average.motor = r(totalTimeMotor / Double(motorHits))
        totals.average.search = r(totalTimeSearch / Double(searchHits))
    
        return totals
    }
}
