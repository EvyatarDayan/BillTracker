//
//  MainTabView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var userManager = UserManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var currencyManager = CurrencyManager()
    @StateObject private var billManager = BillManager()
    @StateObject private var incomeManager = IncomeManager()
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var languageManager = LanguageManager()
    @State private var selectedTab = 0
    @State private var showingAddBill = false
    @State private var showingEditProfile = false
    @State private var showingLogin = false
    
    var body: some View {
        ZStack {
            // Main content
            contentView
            
            // Custom Tab Bar
            customTabBar
        }
        .preferredColorScheme(themeManager.colorScheme)
        .id(themeManager.isDarkMode) // Force refresh when theme changes
        .sheet(isPresented: Binding(
            get: { showingAddBill && userManager.isLoggedIn },
            set: { showingAddBill = $0 }
        )) {
            AddBillView(billManager: billManager)
                .environmentObject(themeManager)
                .environmentObject(currencyManager)
                .environmentObject(notificationManager)
                .environmentObject(languageManager)
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView(userManager: userManager)
                .environmentObject(languageManager)
        }
        .sheet(isPresented: $showingLogin) {
            LoginView(userManager: userManager)
                .environmentObject(languageManager)
        }
        .onAppear {
            // Connect UserManager and BillManager
            userManager.setBillManager(billManager)
            
            // Request notification permission when app starts
            Task {
                await notificationManager.requestPermission()
            }
        }
    }
    
    
    @ViewBuilder
    private var contentView: some View {
        Group {
            switch selectedTab {
            case 0:
                WelcomeView()
                    .environmentObject(billManager)
                    .environmentObject(userManager)
                    .environmentObject(themeManager)
                    .environmentObject(currencyManager)
                    .environmentObject(notificationManager)
                    .environmentObject(languageManager)
            case 1:
                InsightsView()
                    .environmentObject(billManager)
                    .environmentObject(themeManager)
                    .environmentObject(currencyManager)
                    .environmentObject(incomeManager)
                    .environmentObject(notificationManager)
                    .environmentObject(languageManager)
            case 2:
                SettingsView()
                    .environmentObject(billManager)
                    .environmentObject(userManager)
                    .environmentObject(themeManager)
                    .environmentObject(currencyManager)
                    .environmentObject(notificationManager)
                    .environmentObject(languageManager)
            default:
                WelcomeView()
                    .environmentObject(billManager)
                    .environmentObject(userManager)
                    .environmentObject(themeManager)
                    .environmentObject(currencyManager)
                    .environmentObject(notificationManager)
                    .environmentObject(languageManager)
            }
        }
    }
    
    @ViewBuilder
    private var customTabBar: some View {
        VStack {
            Spacer()
            HStack(spacing: 0) {
                // Home Tab
                TabButton(
                    title: languageManager.localized("home"),
                    icon: "house",
                    isSelected: selectedTab == 0,
                    action: { selectedTab = 0 }
                )
                
                // Analytics Tab
                TabButton(
                    title: languageManager.localized("analytics"),
                    icon: "chart.bar",
                    isSelected: selectedTab == 1,
                    action: { selectedTab = 1 }
                )
                
                // Floating Add Button
                Button(action: {
                    if userManager.isLoggedIn {
                        showingAddBill = true
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(userManager.isLoggedIn ? Color.appRed : Color.gray)
                            .frame(width: 50, height: 50)
                            .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 6)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        Image(systemName: "plus")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .disabled(!userManager.isLoggedIn)
                .offset(y: -25)
                .frame(maxWidth: .infinity)
                
                // Settings Tab
                TabButton(
                    title: languageManager.localized("settings"),
                    icon: "gear",
                    isSelected: selectedTab == 2,
                    action: { selectedTab = 2 }
                )
                
                // Profile Tab
                TabButton(
                    title: languageManager.localized("profile"),
                    icon: "person.circle",
                    isSelected: false,
                    action: {
                        if userManager.isLoggedIn {
                            showingEditProfile = true
                        } else {
                            showingLogin = true
                        }
                    }
                )
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, -2)
            .background(Color(.systemBackground))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(.gray.opacity(0.3))
                    .offset(y: -0.25),
                alignment: .top
            )
        }
    }
}

struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(isSelected ? .appRed : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MainTabView()
}