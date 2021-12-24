//
//  gameApp.swift
//  Shared
//
//  Created by Neil McGrogan on 10/4/21.
//

import SwiftUI
import UIKit

@main
struct gameApp: App {
    var body: some Scene {
        WindowGroup {
            ViewController()
                .environmentObject(ViewModel())
                .environmentObject(LevelModel())
        }
    }
}
