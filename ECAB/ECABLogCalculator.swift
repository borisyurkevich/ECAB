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

struct CounterpointingResult {
    let timeBlockNonConflict: NSTimeInterval
    let timeBlockConflict: NSTimeInterval
    let conflictTimeMean: Double
    let conflictTimeMedian: Double
    let nonConflictTimeMean: Double
    let nonConflictTimeMedian: Double
}

struct FlankerResult {
    let timeBlock1:NSTimeInterval
    let timeBlock2:NSTimeInterval
    let timeBlock3:NSTimeInterval
    let timeBlock4:NSTimeInterval
    let conflictTime:NSTimeInterval
    let nonConflictTime:NSTimeInterval
    
    let conflictTimeMean: Double
    let conflictTimeMedian: Double
    let conflictTimeStandardDeviation: Double
    let nonConflictTimeMean: Double
    let nonConflictTimeMedian: Double
    let nonConflictTimeStandardDeviation: Double
}

struct VisualSustaineResult {
    let delay: Double
    
    let totalPeriod: Double
    let totalExposure: Double
    let maxDelay: Double
    
    let totalHits: Int
    let totalMisses: Int
    let totalFalseAndVE: Int
    let totalPicturesDisplayd: Int
    let totalAnimalsDisplayed: Int
}

// Time per target
struct Average {
    var motor: Double
    var search: Double
}


class ECABLogCalculator {
    
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
    
    class func getCounterpintingResult(session: CounterpointingSession) -> CounterpointingResult {
        
        var timeBlock1NonConflict:NSTimeInterval = 0
        var timeBlock2Conflict:NSTimeInterval = 0
        var countBlock1 = 0
        var countBlock2 = 0
        
        var conflictIntervals: Array<NSTimeInterval> = []
        var nonConflictIntervals: Array<NSTimeInterval> = []
        
        for m in session.moves {
            if let move = m as? CounterpointingMove {
                if let inerval = move.intervalDouble as? Double {
                    // Real test begin after 3 practice blocks.
                    // on screen number 24
                    switch move.poitionX.integerValue {
                    case 4 ... 23:
                        timeBlock1NonConflict += inerval
                        countBlock1 += 1
                        nonConflictIntervals.append(inerval)
                    case 29 ... 48:
                        timeBlock2Conflict += inerval
                        countBlock2 += 1
                        conflictIntervals.append(inerval)
                    default:
                        break
                    }
                }
                
            } else {
                print("Error in getFlankerResult()")
                exit(0)
            }
            
        }
        
        let nonConflictTimeMean = timeBlock1NonConflict / Double(countBlock1)
        let conflictTimeMean = timeBlock2Conflict / Double(countBlock2)
        
        // Sort intervals in ascending order
        nonConflictIntervals = nonConflictIntervals.sort({$0 < $1})
        conflictIntervals = conflictIntervals.sort({$0 < $1})
        
        var nonConflictMedian: NSTimeInterval
        if nonConflictIntervals.isEmpty {
            nonConflictMedian = 0
        } else {
            let nonConflictMedianIndex = (Double(countBlock1) + 1) / 2
            nonConflictMedian = nonConflictIntervals[Int(nonConflictMedianIndex)]
        }
        
        var conflictMedian: NSTimeInterval
        if conflictIntervals.isEmpty {
            conflictMedian = 0
        } else {
            let conflictMedianIndex = (Double(countBlock2) + 1) / 2
            conflictMedian = conflictIntervals[Int(conflictMedianIndex)]
        }
        
        // Calculate the deviations of each data point from the mean,
        // and square the result of each:
        var nonConflictDeviation = 0.0
        for value in nonConflictIntervals {
            nonConflictDeviation += pow((value - nonConflictMedian), 2)
        }
        var conflictDeviation = 0.0
        for value in conflictIntervals {
            conflictDeviation += pow((value - conflictMedian), 2)
        }
        
        let result = CounterpointingResult(timeBlockNonConflict: timeBlock1NonConflict, timeBlockConflict: timeBlock2Conflict, conflictTimeMean: conflictTimeMean, conflictTimeMedian: conflictMedian, nonConflictTimeMean: nonConflictTimeMean, nonConflictTimeMedian: nonConflictMedian)
        
        return result
    }
    
    class func getFlankerResult(session: CounterpointingSession) -> FlankerResult {
    
        var timeBlock1:NSTimeInterval = 0
        var timeBlock2:NSTimeInterval = 0
        var timeBlock3:NSTimeInterval = 0
        var timeBlock4:NSTimeInterval = 0
        var countBlock1 = 0
        var countBlock2 = 0
        var countBlock3 = 0
        var countBlock4 = 0
        
        var conflictIntervals: Array<NSTimeInterval> = []
        var nonConflictIntervals: Array<NSTimeInterval> = []
        
        if session.type == SessionType.Flanker.rawValue {
            
            for m in session.moves {
                if let move = m as? CounterpointingMove {
                    if let interval = move.intervalDouble as? Double {
                        // Real test begin after 3 practice blocks.
                        // on screen number 24
                        switch move.poitionX.integerValue {
                        case 24 ... 33:
                            timeBlock1 += interval
                            countBlock1 += 1
                            nonConflictIntervals.append(interval)
                        case 36 ... 45:
                            timeBlock2 += interval
                            countBlock2 += 1
                            conflictIntervals.append(interval)
                        case 48 ... 57:
                            timeBlock3 += interval
                            countBlock3 += 1
                            conflictIntervals.append(interval)
                        case 60 ... 69:
                            timeBlock4 += interval
                            countBlock4 += 1
                            nonConflictIntervals.append(interval)
                        default:
                            break
                        }
                    }
                    
                } else {
                    print("Error in getFlankerResult()")
                    exit(0)
                }
            }
        } else if session.type == SessionType.FlankerRandomized.rawValue {
            
            for m in session.moves {
                guard let move = m as? CounterpointingMove else {
                    exit(0)
                }
                guard let interval = move.intervalDouble as? Double else {
                    exit(0)
                }
                
                // Separate this screens on conflict and not conflict.
                switch move.poitionX.integerValue {
                
                // Inversed false.
                case 24, 25, 27, 29, 30, 31, 32, 35, 36, 41, 42, 46, 47, 49, 50, 54, 55:
                    timeBlock1 += interval
                    countBlock1 += 1
                    nonConflictIntervals.append(interval)
                    
                // Inversed true.
                case 26, 28, 33, 34, 37, 38, 43, 44, 45, 48, 51, 52, 53:
                    timeBlock2 += interval
                    countBlock2 += 1
                    conflictIntervals.append(interval)
                default:
                    break
                }
            }
        }
        

        let nonConflictTimeMean = (timeBlock1 + timeBlock4) / Double(countBlock1 + countBlock4)
        let conflictTimeMean = (timeBlock2 + timeBlock3) / Double(countBlock2 + countBlock3)
        
        // Sort intervals in ascending order
        nonConflictIntervals = nonConflictIntervals.sort({$0 < $1})
        conflictIntervals = conflictIntervals.sort({$0 < $1})
        
        var nonConflictMedian: NSTimeInterval
        if nonConflictIntervals.isEmpty {
            nonConflictMedian = 0
        } else {
            let nonConflictMedianIndex = (Double(countBlock1 + countBlock4) + 1) / 2
            nonConflictMedian = nonConflictIntervals[Int(nonConflictMedianIndex)]
        }
        
        var conflictMedian: NSTimeInterval
        if conflictIntervals.isEmpty {
            conflictMedian = 0
        } else {
            let conflictMedianIndex = (Double(countBlock2 + countBlock3) + 1) / 2
            conflictMedian = conflictIntervals[Int(conflictMedianIndex)]
        }
        
        // Calculate the deviations of each data point from the mean,
        // and square the result of each:
        var nonConflictDeviation = 0.0
        for value in nonConflictIntervals {
            nonConflictDeviation += pow((value - nonConflictMedian), 2)
        }
        var conflictDeviation = 0.0
        for value in conflictIntervals {
            conflictDeviation += pow((value - conflictMedian), 2)
        }
        
        // The variance is the mean of these values:
        let nonConflictVariance = nonConflictDeviation / Double(countBlock1 + countBlock4)
        let conflictVariance = conflictDeviation / Double(countBlock2 + countBlock3)
        
        let nonConflictStandardDeviation = sqrt(nonConflictVariance)
        let conflictStandardDeviation = sqrt(conflictVariance)
        
        let result = FlankerResult(timeBlock1: timeBlock1,
                                   timeBlock2: timeBlock2,
                                   timeBlock3: timeBlock3,
                                   timeBlock4: timeBlock4,
                                 conflictTime: timeBlock2 + timeBlock3,
                              nonConflictTime: timeBlock1 + timeBlock4,
                             conflictTimeMean: conflictTimeMean,
                           conflictTimeMedian: conflictMedian,
                conflictTimeStandardDeviation: conflictStandardDeviation,
                          nonConflictTimeMean: nonConflictTimeMean,
                        nonConflictTimeMedian: nonConflictMedian,
             nonConflictTimeStandardDeviation: nonConflictStandardDeviation)
        
        return result
    }
    
    class func getVisualSustainResult(session: CounterpointingSession) -> VisualSustaineResult {
        
        let delay = session.vsustAcceptedDelay!.doubleValue
        let exposure = session.speed.doubleValue
        let mdelay = session.vsustAcceptedDelay!.doubleValue
        let score = session.score.integerValue
        let misses = session.vsustMiss?.integerValue
        let objectsTotal = session.vsustObjects!.integerValue
        let animalsTotal = session.vsustAnimals!.integerValue
        let totalPics = objectsTotal + animalsTotal
        let falsePositives = session.errors.integerValue
        
        let blank = session.vsustBlank!.doubleValue
        let interval = exposure + blank
        
        let result = VisualSustaineResult(delay: delay, totalPeriod: interval, totalExposure: exposure, maxDelay: mdelay, totalHits: score, totalMisses: misses!, totalFalseAndVE: falsePositives, totalPicturesDisplayd: totalPics, totalAnimalsDisplayed: animalsTotal)
        
        return result
    }
}
