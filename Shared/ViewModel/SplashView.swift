//
//  SplashView.swift
//  game
//
//  Created by Neil McGrogan on 12/27/21.
//

import SwiftUI

struct SplashView: View {
    @State var animate = false
    @State var endSplash = false
    @State var hideAnimation = false
    
    var body: some View {
        if !hideAnimation {
            ZStack(alignment: .center) {
                Color.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                Image("logo")
                    .resizable()
                    .renderingMode(.original)
                    .edgesIgnoringSafeArea(.all)
                    .aspectRatio(contentMode: animate ? .fill : .fit)
                    .frame(width: animate ? nil : 1, height: animate ? nil : 1)
                    .scaleEffect(animate ? 3 : 1)
                    .frame(width: UIScreen.main.bounds.width)
            }
            .ignoresSafeArea(.all, edges: .all)
            .onAppear(perform: animateSplash)
            .opacity(endSplash ? 0 : 1)
        } else {
            ViewController()
                .environmentObject(ViewModel())
                .environmentObject(LevelModel())
        }
    }
    
    func animateSplash() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(Animation.easeOut(duration: 0.45)) {
                animate.toggle()
            }
            withAnimation(Animation.linear(duration: 0.35)) {
                endSplash.toggle()
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                print("Animation finished")
                self.hideAnimation.toggle()
            }
        }
    }
}
