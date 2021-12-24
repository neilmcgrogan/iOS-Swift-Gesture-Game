//
//  Extensions.swift
//  game
//
//  Created by Neil McGrogan on 10/20/21.
//

import SwiftUI

extension Color {
    static var food = Color(red: 200/255, green: 200/255, blue: 240/255)
    static var bomb = Color(red: 200/255, green: 200/255, blue: 240/255)
    static var appBackground = Color(red: 25/255, green: 25/255, blue: 25/255)
    static var lockedTile = Color(red: 25/255, green: 25/255, blue: 25/255)
    static var life = Color(red: 0/255, green: 55/255, blue: 225/255)
    static var topColor = Color(red: 120/255, green: 130/255, blue: 140/255)
    static var bottomColor = Color(red: 55/255, green: 85/255, blue: 110/255)
    
    static var backgroundColor = LinearGradient(gradient: Gradient(colors: [.topColor, .bottomColor]), startPoint: .top, endPoint: .bottom)
}
