//
//  Properties.swift
//  game
//
//  Created by Neil McGrogan on 1/5/22.
//

import Foundation
import SwiftUI

class PropertiesModel: ObservableObject {
    @EnvironmentObject var level: LevelModel

    // UI elements
    let PLAY_BUTTON_SIZE = 80.0
    
    // Game setup
    let BULLET_COUNT = 25
    let BULLET_PER_SECOND = 5
    let SPEED_UPGRADE = 0.05
    func RATE_UPGRADE(level: Int) -> Double {
        if level < 15 {
            return 1
        } else {
            return CGFloat.random(in: 0..<1)
        }
    }
}
