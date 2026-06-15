//
//  WelcomeView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var billManager: BillManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingAddBill = false
    @State private var selectedBill: Bill?
    @State private var showingLoginSheet = false
    
    // Check if device is iPad
    private var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                homeHeaderBar
                
                // Fixed Upper Section
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    // Summary Card
                    summaryCard
                }
                .padding()
                .background(Color(.systemGroupedBackground))
                
                // Scrollable Bills Section
                if billManager.bills.filter({ $0.isActive }).isEmpty {
                    emptyStateView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(.systemGroupedBackground))
                } else {
                    billsListSection
                        .background(Color(.systemGroupedBackground))
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: Binding(
                get: { showingAddBill && userManager.isLoggedIn },
                set: { showingAddBill = $0 }
            )) {
                AddBillView(billManager: billManager)
                    .environmentObject(themeManager)
                    .environmentObject(languageManager)
            }
            .sheet(item: $selectedBill) { bill in
                EditBillView(bill: bill, billManager: billManager)
                    .environmentObject(themeManager)
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingLoginSheet) {
                LoginView(userManager: userManager)
                    .environmentObject(languageManager)
            }
        }
    }
    
    private var homeHeaderBar: some View {
        HStack(spacing: 12) {
            Button(action: {
                if !userManager.isLoggedIn {
                    showingLoginSheet = true
                }
            }) {
                toolbarProfileAvatar
            }
            .buttonStyle(.plain)
            
            Text(headerText)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.appRed)
            
            Spacer()
            
            Button(action: {
                if userManager.isLoggedIn {
                    showingAddBill = true
                } else {
                    showingLoginSheet = true
                }
            }) {
                Image(systemName: "plus")
                    .font(.title3.weight(.bold))
                    .foregroundColor(userManager.isLoggedIn ? .appRed : .gray)
            }
            .buttonStyle(.plain)
            .disabled(!userManager.isLoggedIn)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Empty header section
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    @ViewBuilder
    private var toolbarProfileAvatar: some View {
        if userManager.isLoggedIn, let profileImage = userManager.getProfileImage() {
            Image(uiImage: profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else if userManager.isLoggedIn, let avatarName = userManager.getAvatarName() {
            Image(avatarName)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.appRed.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.title3)
                        .foregroundColor(.appRed)
                )
        }
    }
    
    private var welcomeText: String {
        if userManager.isLoggedIn, let firstName = userManager.currentUser?.firstName {
            return "Welcome \(firstName)!"
        } else {
            return "Welcome back!"
        }
    }
    
    // Get greeting based on time of day
    private func getGreeting(for firstName: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        let greeting: String
        if hour >= 5 && hour < 12 {
            greeting = languageManager.localized("good_morning")
        } else if hour >= 12 && hour < 17 {
            greeting = languageManager.localized("good_afternoon")
        } else if hour >= 17 && hour < 22 {
            greeting = languageManager.localized("good_evening")
        } else {
            greeting = languageManager.localized("good_night")
        }
        
        return "\(greeting) \(firstName)"
    }
    
    // Get header text based on login status
    private var headerText: String {
        if userManager.isLoggedIn, let firstName = userManager.currentUser?.firstName {
            return getGreeting(for: firstName)
        } else {
            return languageManager.localized("sign_in")
        }
    }
    

    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top section with bank info
            HStack {
                VStack(alignment: .leading, spacing: 1) {
                    Text(userManager.isLoggedIn ? (userManager.currentUser?.fullName ?? "John Doe") : "John Doe")
                        .font(.system(size: isIPad ? 12 : 10, weight: .bold))
                        .foregroundColor(.black.opacity(0.9))
                    
                    Text(languageManager.localized("premium_card"))
                        .font(.system(size: isIPad ? 12 : 10))
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.bottom, 10)
                }
                
                Spacer()
                
                Image("wifi")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
            }
            
//            Spacer()
            
            // Main amount display
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 2) {
                    Text(languageManager.localized("total_monthly_bills"))
//                        .font(.caption2)
                        .font(.system(size: isIPad ? 22 : 16, weight: .bold, design: .rounded))
                        .foregroundColor(.black.opacity(0.8))
                    
                    Text(currencyManager.formatAmount(billManager.totalMonthlyAmount))
                        .font(.system(size: isIPad ? 42 : 32, weight: .bold, design: .rounded))
                        .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.top, 8)
            .padding(.bottom, 10)
            
            // Card number
            Text("**** **** **** 7412")
                .font(.system(size: isIPad ? 16 : 12, weight: .medium, design: .monospaced))
                .foregroundColor(.black.opacity(0.8))
                .padding(.top, 6)
            
            // Bottom section
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(languageManager.localized("expires"))
                        .font(.system(size: isIPad ? 12 : 10))
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text("12/29")
                        .font(.system(size: isIPad ? 12 : 10, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                // Card type logo
                HStack(spacing: 2) {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 10, height: 10)
                    
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                        .offset(x: -5)
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("mästercärd")
                        .font(.system(size: isIPad ? 12 : 10))
                        .foregroundColor(.black)
                        .offset(x: -2)
                }
            }
            .padding(.top, 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, isIPad ? 20 : 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.8, green: 0.6, blue: 0.2), // Gold
                    Color(red: 0.9, green: 0.7, blue: 0.3), // Lighter gold
                    Color(red: 0.7, green: 0.5, blue: 0.1)  // Darker gold
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .frame(maxWidth: isIPad ? 450 : .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
                .frame(height: 40)
            
            if userManager.isLoggedIn {
                // Small + Button (only shown when logged in)
                Button(action: {
                    showingAddBill = true
                }) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.appRed)
                }
                
                // Text
                VStack(spacing: 8) {
                    Text(languageManager.localized("you_havent_added_any_bills"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(languageManager.localized("start_by_adding_your_first_bill"))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                // Login required message
                VStack(spacing: 16) {
                    Text(languageManager.localized("sign_in_to_your_account_and_start_adding_bills"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        showingLoginSheet = true
                    }) {
                        Text(languageManager.localized("sign_in_sign_up"))
                            .font(.headline)
                            .foregroundColor(.appRed)
                    }
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var billsListSection: some View {
        VStack(spacing: 0) {
            // Section Header (Fixed)
            HStack {
                Text(languageManager.localized("my_bills"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 16)
            .background(Color(.systemGroupedBackground))
            
            // Scrollable Bills List
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(billManager.bills.filter { $0.isActive }) { bill in
                        BillRowView(bill: bill, themeManager: themeManager)
                            .onTapGesture {
                                selectedBill = bill
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 70) // Extra padding to account for custom tab bar
            }
        }
    }
}

struct BillRowView: View {
    let bill: Bill
    let themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    
    private func getIconColor(for bill: Bill) -> Color {
        // Assign colors based on bill category or name
        let category = bill.category.lowercased()
        let name = bill.name.lowercased()
        
        if category.contains("entertainment") || name.contains("netflix") || name.contains("spotify") || name.contains("apple one") || name.contains("amazon prime") || name.contains("disney") || name.contains("hulu") || name.contains("youtube") {
            return .red
        } else if category.contains("software") || name.contains("adobe") || name.contains("microsoft") || name.contains("google") || name.contains("jetbrains") || name.contains("figma") || name.contains("sketch") || name.contains("slack") || name.contains("zoom") || name.contains("github") || name.contains("jira") || name.contains("notion") || name.contains("canva") || name.contains("chatgpt") || name.contains("claude") {
            return .purple
        } else if category.contains("fitness") || name.contains("gym") || name.contains("peloton") || name.contains("fitness") {
            return .green
        } else if category.contains("utilities") || name.contains("electric") || name.contains("water") || name.contains("gas") || name.contains("internet") || name.contains("phone") {
            return .orange
        } else if category.contains("insurance") || name.contains("health") || name.contains("car") || name.contains("home") {
            return .blue
        } else if category.contains("transportation") || name.contains("uber") || name.contains("lyft") || name.contains("gas") || name.contains("parking") {
            return .yellow
        } else if category.contains("food") || name.contains("restaurant") || name.contains("grocery") || name.contains("delivery") {
            return .pink
        } else if category.contains("education") || name.contains("course") || name.contains("book") || name.contains("school") {
            return .indigo
        } else if category.contains("healthcare") || name.contains("doctor") || name.contains("pharmacy") || name.contains("medical") {
            return .mint
        } else {
            return .gray
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            if let customImageData = bill.customImageData, let customImage = UIImage(data: customImageData) {
                // Custom image - fill entire circle
                Image(uiImage: customImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                // System icon with dynamic color
                let iconColor = getIconColor(for: bill)
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: bill.icon)
                        .font(.title2)
                        .foregroundColor(iconColor)
                }
            }
            
            // Bill Details
            VStack(alignment: .leading, spacing: 4) {
                Text(bill.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Text(dashboardPaymentDateString(for: bill))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatBillAmount(bill))
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(currencyManager.defaultCurrency)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(themeManager.isDarkMode ? Color(.systemGray6) : Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 1)
    }
    
    private func formatBillAmount(_ bill: Bill) -> String {
        // For yearly payments, show the monthly equivalent
        let displayAmount = bill.isYearlyPayment ? bill.amount / 12 : bill.amount
        return currencyManager.formatAmount(displayAmount)
    }
    
    private func dashboardPaymentDateString(for bill: Bill) -> String {
        if bill.isYearlyPayment, let yearlyPaymentDate = bill.yearlyPaymentDate {
            // For yearly payments, show "Every" with day and abbreviated month (e.g., "Every 11 Oct")
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return "Every \(formatter.string(from: yearlyPaymentDate))"
        } else {
            // For monthly payments, show "Due every Xth"
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            let ordinalDay = formatter.string(from: NSNumber(value: bill.paymentDate)) ?? "\(bill.paymentDate)"
            return "Due every \(ordinalDay)"
        }
    }
}

#Preview {
    WelcomeView()
        .environmentObject(UserManager())
        .environmentObject(ThemeManager())
}
