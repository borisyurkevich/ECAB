//
//  ECABData.swift
//  ECAB
//
//  Created by Boris Yurkevich on 01/02/2015.
//  Copyright (c) 2015 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class ECABData: NSObject {
    var subjects = Array<ECABSubject>()
    
    override init() {
        super.init()
        if subjects.count == 0 {
            let subject = ECABSubject()
            subjects.append(subject)
            println("Default test subject created")
            // Creates default test subject
        }
    }
    
    class var sharedInstance: ECABData {
        struct Singleton {
            static let instance = ECABData()
        }
        
        return Singleton.instance
    }
}
