//
//  BillTrackerApp.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

@main
struct BillTrackerApp: App {
    @AppStorage(WelcomeStorage.skipWelcomeKey) private var skipWelcomeScreen = false
    @State private var showMainApp = false

    var body: some Scene {
        WindowGroup {
            if skipWelcomeScreen || showMainApp {
                ContentView()
            } else {
                OnboardingView {
                    showMainApp = true
                }
            }
        }
    }
}
