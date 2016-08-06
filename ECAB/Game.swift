//
//  Game.swift
//  ECAB
//
//  Created by Raphaël Bertin on 13/06/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
import UIKit



protocol GameType: class {
    func setupProperties()
    func show()
    func launch()

    var id: NSInteger { get }
    var title: String { get }
    var icon: UIImage { get }
    var viewController: TestViewController { get }

    var difControl:Bool { get }
    var speedLabel:Bool { get }
    var speedLabelDescription:Bool { get }
    
    var speedStepper:Bool { get }
    var secondSpeedLabel:Bool { get }
    var secondSpeedStepper:Bool { get }
    var secondSpeedLabelDescription:Bool { get }

    var periodControl:Bool { get }
    var periodTitle:Bool { get }
    var periodHelp:Bool { get }
    var periodValue:Bool { get }
}

class Game: GameType {
    var id: NSInteger = 0
    var title: String = ""
    var icon: UIImage = UIImage(named: "icon_visual")!
    var viewController: TestViewController = TestViewController()

    var difControl:Bool = false
    var speedLabel:Bool = false
    var speedLabelDescription:Bool = false
    
    var speedStepper:Bool = false
    var secondSpeedLabel:Bool = false
    var secondSpeedStepper:Bool = false
    var secondSpeedLabelDescription:Bool = false
    
    var periodControl:Bool = false
    var periodTitle:Bool = false
    var periodHelp:Bool = false
    var periodValue:Bool = false

    func setupProperties() {}
    func show() {}
    func launch() {}
    
    init(id: NSInteger, title: String) {
        self.id = id
        self.title = title
        setupProperties()
    }
}