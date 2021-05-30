//
//  MenuView.swift
//  ECAB
//
//  Created by Boris Yurkevich on 30/05/2021.
//  Copyright © 2021 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit
import os

protocol MenuViewDelegate: AnyObject {
    func handleTouch(location: CGPoint)
    func highlight(location: CGPoint)
    func reset(location: CGPoint)
}

final class MenuView: UIView {

    weak var delegate: MenuViewDelegate?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        for touch in touches {
            let location = touch.location(in: self)
            os_log(.debug, "menu touch: %@", location.debugDescription)
            delegate?.highlight(location: location)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        for touch in touches {
            let location = touch.location(in: self)
            os_log(.debug, "menu touch: %@", location.debugDescription)
            delegate?.handleTouch(location: location)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        for touch in touches {
            let location = touch.location(in: self)
            os_log(.debug, "menu touch cancelled: %@", location.debugDescription)
            delegate?.reset(location: location)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        os_log(.debug, "menu touch moved")
    }
}
