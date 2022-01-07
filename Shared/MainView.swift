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
    @EnvironmentObject var defaults: PropertiesModel
    
    @State private var animationAmount: CGFloat = 1
    @State private var locked = false
    
    let data = (1...100).map { "\($0)" }
    
    var body: some View {
        ZStack {
            Image("logo")
                .foregroundColor(Color.textColor)
            
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
                                    .fill(Color.playButton)
                                
                                Image(systemName: "play.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(Color.topColor)
                            }
                            .frame(width: CGFloat(defaults.PLAY_BUTTON_SIZE), height: CGFloat(defaults.PLAY_BUTTON_SIZE), alignment: .bottom)
                            .shadow(radius: 0.5)
                            .scaleEffect(animationAmount)
                            .animation(.linear(duration: 0.75).delay(0.2).repeatForever(autoreverses: true))
                            .onAppear {
                                animationAmount = 1.1
                            }
                        }
                    }
                }
            }.padding()
        }
    }
}
