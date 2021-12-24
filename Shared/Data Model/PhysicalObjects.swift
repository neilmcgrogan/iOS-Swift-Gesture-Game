//
//  PhysicalObjects.swift
//  game
//
//  Created by Neil McGrogan on 12/23/21.
//

import SwiftUI

struct BombObject: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))

        return path
    }
}


struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        //path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        //path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        //path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        //path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        
        return path
    }
}
