//
//  Model.swift
//  game
//
//  Created by Neil McGrogan on 11/7/21.
//

import Foundation

class LevelModel: ObservableObject {
    @Published var level: Int = 0
    @Published var lockStatus: [Bool] = Array(repeating: true, count: 101)
    @Published var bombsLeft: Int = 0
    @Published var bombAlternateSpawnsLeft: Int = 0
    @Published var bombSpawnsLeft: Int = 0
    
    var scale: Int {
        return self.level
    }
    
    var bulletScale: Int {
        return 10 + self.level
    }
    
    var bossSpawns: Int {
        return self.level
    }
    
    // Game play
    
    var POINT_SPAWN_COUNT: Int {
        if self.level < 5 {
            return 1
        } else if self.level < 15 {
            return 2
        } else if self.level < 25 {
            return 3
        } else if self.level < 45 {
            return 4
        } else if self.level < 60 {
            return 5
        } else {
            return 6
        }
    }
    
    let BULLET_SPEED_INIT = 12//2
    
    // higher harder
    // lower laxer
    var BOMB_SPAWN_RATE: Double { return Double(480 / (0.7 * Double(level) + 1)) }
    var BOMB_ALTERNATE_SPAWN_RATE: Double { return Double(560 / (0.7 * Double(level) + 1)) }
    
    var BOMB_SPAWN_COUNT: Int { return self.level * 2 }
    var BOMB_ALTERNATE_SPAWN_COUNT: Int { return self.level }
    
    let BOMB_FALL_INIT = 0.40
    var BOMB_FALL_SPEED: Double { return BOMB_FALL_INIT + (Double(level) / 120.0) }
    
    let BOMB_ALTERNATE_FALL_INIT_X = 0.5
    var BOMB_ALTERNATE_FALL_SPEED_X: Double { return BOMB_ALTERNATE_FALL_INIT_X + Double(Double(level) / 60.0) }
    
    let BOMB_ALTERNATE_FALL_INIT_Y = 0.50
    var BOMB_ALTERNATE_FALL_SPEED_Y: Double { return BOMB_ALTERNATE_FALL_INIT_Y + Double(Double(level) / 120.0) }
    
    let POINT_FALL_INIT = 1.0
    var POINT_FALL_SPEED: Double { return POINT_FALL_INIT + Double(Double(level) / 60.0) }
}
