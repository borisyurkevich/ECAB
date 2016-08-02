//
//  Setting.swift
//  ECAB
//
//  Created by Raphaël Bertin on 01/08/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import Foundation
class Setting {
    
    let category: String
    let type: SettingType
    let title: String
    let value: String
    let valueType: ValueType

    init(c: String, v: String, t: String, tt: SettingType, vt: ValueType) {
        category = c;
        value = v;
        title = t;
        type = tt;
        valueType = vt;
    }
}
