//
//  ThemeManager.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import Foundation
import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            // Force UI refresh when theme changes
            objectWillChange.send()
        }
    }
    
    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
    
    var colorScheme: ColorScheme? {
        return isDarkMode ? .dark : .light
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
}
