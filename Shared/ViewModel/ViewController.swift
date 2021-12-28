//
//  ViewController.swift
//  game
//
//  Created by Neil McGrogan on 10/25/21.
//

import SwiftUI

struct ViewController: View {
    @EnvironmentObject var viewRouter: ViewModel
    @State private var level = 0
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .edgesIgnoringSafeArea(.all)
            
            switch viewRouter.currentPage {
            case .homeView:
                HomeView()
            case .gameView:
                GameView()
            }
        }
        .foregroundColor(Color.textColor)
        .onAppear {
            //preferredScreenEdgesDeferringSystemGestures()
        }
    }
    
    func preferredScreenEdgesDeferringSystemGestures() -> UIRectEdge {
        return [.bottom]
    }
}
