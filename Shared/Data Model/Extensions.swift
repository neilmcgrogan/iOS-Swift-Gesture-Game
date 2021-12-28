//
//  Extensions.swift
//  game
//
//  Created by Neil McGrogan on 10/20/21.
//

import SwiftUI

extension Color {
    static var food = Color(red: 200/255, green: 200/255, blue: 240/255)
    static var point = Color(red: 230/255, green: 220/255, blue: 200/255)
    static var bomb = Color(red: 300/255, green: 20/255, blue: 50/255)
    static var bullet = Color(red: 230/255, green: 220/255, blue: 200/255)
    static var appBackground = Color(red: 25/255, green: 25/255, blue: 25/255)
    static var lockedTile = Color(red: 25/255, green: 25/255, blue: 25/255)
    static var life = Color(red: 0/255, green: 55/255, blue: 225/255)
    static var textColor = Color(red: 230/255, green: 220/255, blue: 200/255)
    static var redTextColor = Color(red: 300/255, green: 20/255, blue: 50/255)
    static var topColor = Color(red: 30/255, green: 30/255, blue: 30/255)
    static var bottomColor = Color(red: 20/255, green: 20/255, blue: 20/255)
    static var backgroundColor = LinearGradient(gradient: Gradient(colors: [.topColor, .bottomColor]), startPoint: .top, endPoint: .bottom)
}
