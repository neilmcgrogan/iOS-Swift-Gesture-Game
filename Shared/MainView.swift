//
//  MainView.swift
//  game
//
//  Created by Neil McGrogan on 10/25/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewRouter: ViewModel
    @EnvironmentObject var level: LevelModel
    
    @State private var locked = false
    
    let data = (1...100).map { "\($0)" }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Gauntlet")
                .font(.title)
                .bold()
            Text("each level gets more difficult, try and beat all 100 levels to win the game")
            
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    viewRouter.currentPage = .gameView
                    level.level = 1
                }) {
                    Text("Begin")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            Spacer()
        }.padding()
    }
}
