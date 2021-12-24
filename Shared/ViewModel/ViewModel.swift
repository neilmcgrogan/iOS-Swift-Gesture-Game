//
//  ViewModel.swift
//  game
//
//  Created by Neil McGrogan on 11/7/21.
//

import Foundation

class ViewModel: ObservableObject {
    
    @Published var currentPage: Page = .homeView
}
