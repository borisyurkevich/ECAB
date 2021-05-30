//
//  GameMenuDelegate.swift
//  ECAB
//
//  Created by Boris Yurkevich on 30/05/2021.
//  Copyright © 2021 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

protocol GameMenuDelegate: AnyObject {
    func presentPreviousScreen()
    func presentNextScreen()
    func skip()
    func presentPause()
    func resumeTest()
}
