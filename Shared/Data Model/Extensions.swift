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
    static var bombAlternate = Color(red: 175/255, green: 20/255, blue: 200/255)
    static var bullet = Color(red: 230/255, green: 220/255, blue: 200/255)
    static var lockedTile = Color(red: 25/255, green: 25/255, blue: 25/255)
    static var life = Color(red: 0/255, green: 55/255, blue: 225/255)
    static var textColor = Color(red: 230/255, green: 220/255, blue: 200/255)
    static var redTextColor = Color(red: 300/255, green: 20/255, blue: 50/255)
    static var playButton = Color(red: 250/255, green: 200/255, blue: 10/255)
    static var topColor = Color(red: 34/255, green: 34/255, blue: 34/255)
    static var bottomColor = Color(red: 24/255, green: 24/255, blue: 24/255)
    static var backgroundColor = LinearGradient(gradient: Gradient(colors: [.topColor, .bottomColor]), startPoint: .top, endPoint: .bottom)
}

struct ColorView: View {
    var body: some View {
        Color.bombAlternate
    }
}

