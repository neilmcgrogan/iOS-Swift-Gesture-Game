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
        ZStack {
            Image("logo")
            
            VStack(alignment: .center) {
                Text("swipe")
                    .font(.largeTitle)
                    .bold()
                
                Text("each level gets harder")
                    .font(.title3)
                    .bold()
                
                Text("beat all 100 to win the game")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        viewRouter.currentPage = .gameView
                        level.level = 1
                    }) {
                        VStack {
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .fill(Color.backgroundColor)
                                
                                Image(systemName: "play.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(Color.textColor)
                            }
                            .frame(width: 100, height: 100, alignment: .bottom)
                            .shadow(radius: 0.5)
                        }
                    }
                }
            }.padding()
        }
    }
}
