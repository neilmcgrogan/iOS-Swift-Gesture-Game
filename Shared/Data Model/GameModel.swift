//
//  GameModel.swift
//  game
//
//  Created by Neil McGrogan on 11/9/21.
//

import Foundation
import SwiftUI

struct Player : GameElement{
    var pos = CGPoint(x:0,y:0)
    var target = CGPoint(x:0,y:0)
    var radius = CGFloat(22.0)
    var vel = CGPoint(x:0, y:0)
}

struct Item : GameElement, Equatable{
    var id = UUID()
    var pos = CGPoint(x:0,y:0)
    var radius = CGFloat(12.0)
    var lastMovement = CGFloat.random(in: 0...1)
    
    static func spawn(within : GeometryProxy, level: Int) -> Item{
        var f = Item()
        
        f.pos.x = CGFloat.random(in: 15..<within.size.width - 15)
        f.pos.y = -CGFloat.random(in: 0..<(1 + (within.size.height / 2) * Double(level / 10)))
        
        return f
    }
    
    static func spawnBomb(within : GeometryProxy) -> Item {
        var f = Item()
        
        f.pos.x = CGFloat.random(in: 5..<within.size.width - 5)
        f.pos.y = -CGFloat.random(in: 10..<20)
        
        return f
    }
    
    static func spawnBullet(pos: CGPoint) -> Item {
        var f = Item()
        
        f.pos = pos
        
        return f
    }
}

protocol GameElement  {
    var pos: CGPoint { get }
    var radius: CGFloat { get }
    
}

extension GameElement {
    func collide(to : GameElement) -> Bool{
        let p1 = self.pos
        let p2 = to.pos
        let r1 = self.radius
        let r2 = to.radius
        
        let distance = pow(p2.x - p1.x, 2) + pow(p1.y - p2.y, 2)
        let minDistance = pow(r1+r2, 2)
        
        return distance <= minDistance
    }
}
