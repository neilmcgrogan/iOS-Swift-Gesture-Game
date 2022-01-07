//
//  StatusBar.swift
//  game
//
//  Created by Neil McGrogan on 1/6/22.
//

import SwiftUI

struct ProgressBar: View {
    @EnvironmentObject var level: LevelModel
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 3.0)
                    .foregroundColor(Color.red)
                    .opacity(0.10)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress(), 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 3.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.redTextColor)
                    .rotationEffect(Angle(degrees: -90))
                    .animation(.linear)
                    .opacity(0.90)
            }.frame(width: 75, height: 75, alignment: .center)
        }
    }
    
    func progress() -> CGFloat {
        return CGFloat(CGFloat(level.bombsLeft) / CGFloat(level.level * 3))
    }
}
