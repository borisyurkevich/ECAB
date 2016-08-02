//
//  SettingsFactory.swift
//  ECAB
//
//  Created by Raphaël Bertin on 01/08/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation

class SettingsFactory {
    
    static let list: [Setting] = [
        Setting(c: "Voice", v: "0.2", t: "Rate", tt: SettingType.Slider, vt: ValueType.Double),
        Setting(c: "Voice", v: "1.1", t: "Pitch", tt: SettingType.Slider, vt: ValueType.Double),
    ]
}
