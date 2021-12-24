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
    
    
    var scale: Int {
        return self.level
    }
    var bombScale: Int {
        return 5 + (self.level / 2)
    }
    var bulletScale: Int {
        return 10 + self.level
    }
    var foodScale: Int {
        return 2 + (self.level)
    }
    var bossSpawns: Int {
        return self.level
    }
}
