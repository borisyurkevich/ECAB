//
//  ECABData.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABData {
    private var subjects = Array<ECABSubject>()
    var subject: ECABSubject
    
    init() {
        if subjects.count == 0 {
            let subject = ECABSubject()
            subjects.append(subject)
            println("Default test subject created")
            // Creates default test subject
        }
        self.subject = subjects[0]
    }
    
    class var sharedInstance: ECABData {
        struct Singleton {
            static let instance = ECABData()
        }
        
        return Singleton.instance
    }
}
