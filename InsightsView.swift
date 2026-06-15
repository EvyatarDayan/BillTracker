//
//  InsightsView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var billManager: BillManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var incomeManager: IncomeManager
    @EnvironmentObject var languageManager: LanguageManager
    
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
        } else if category.contains("healthcare") || name.contains("health") || name.contains("dental") || name.contains("vision") || name.contains("insurance") {
            return .pink
        } else if category.contains("utilities") || name.contains("internet") || name.contains("electricity") || name.contains("phone") || name.contains("water") || name.contains("gas") || name.contains("wifi") || name.contains("bolt") {
            return .blue
        } else if category.contains("transportation") || name.contains("car") || name.contains("bus") || name.contains("uber") || name.contains("lyft") || name.contains("gas") || name.contains("fuel") {
            return .orange
        } else if category.contains("finance") || name.contains("credit") || name.contains("loan") || name.contains("mortgage") || name.contains("rent") || name.contains("bank") || name.contains("student") {
            return .indigo
        } else if category.contains("food") || name.contains("grocery") || name.contains("restaurant") || name.contains("coffee") || name.contains("delivery") {
            return .brown
        } else if category.contains("housing") || name.contains("house") || name.contains("apartment") {
            return .teal
        } else {
            return .gray
        }
    }
    
    private func upcomingPaymentDateString(for bill: Bill) -> String {
        if bill.isYearlyPayment, let yearlyPaymentDate = bill.yearlyPaymentDate {
            // For yearly payments, show "Due every" with the actual date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return "Due every \(formatter.string(from: yearlyPaymentDate))"
        } else {
            // For monthly payments, show "Due on the Xth"
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            let ordinalDay = formatter.string(from: NSNumber(value: bill.paymentDate)) ?? "\(bill.paymentDate)"
            return "Due on the \(ordinalDay)"
        }
    }
    
    private func completedPaymentDateString(for bill: Bill) -> String {
        if bill.isYearlyPayment, let yearlyPaymentDate = bill.yearlyPaymentDate {
            // For yearly payments, show "Paid on the" with the actual date
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return "Paid on the \(formatter.string(from: yearlyPaymentDate))"
        } else {
            // For monthly payments, show "Paid on the Xth"
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            let ordinalDay = formatter.string(from: NSNumber(value: bill.paymentDate)) ?? "\(bill.paymentDate)"
            return "Paid on the \(ordinalDay)"
        }
    }
    
    @State private var showAllUpcoming = false
    @State private var showAllDone = false
    @State private var showingAddIncome = false
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    @State private var slideDirection: SlideDirection = .none
    
    private let categoryPalette: [Color] = [
        Color(red: 38/255, green: 70/255, blue: 83/255),   // #264653
        Color(red: 42/255, green: 157/255, blue: 143/255), // #2a9d8f
        Color(red: 233/255, green: 196/255, blue: 106/255),// #e9c46a
        Color(red: 244/255, green: 162/255, blue: 97/255), // #f4a261
        Color(red: 231/255, green: 111/255, blue: 81/255)  // #e76f51
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Monthly Overview Card
                    monthlyOverviewCard
                    
                    // Spending by Category (Pie Chart)
                    spendingByCategoryCard
                    
                    // Upcoming Payments
                    upcomingPaymentsCard
                    
                    // Done Payments
                    donePaymentsCard
                    
                    // Calendar View
                    calendarCard
                }
                .padding()
                .padding(.bottom, 70) // Extra padding to account for custom tab bar
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(languageManager.localized("insights"))
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAddIncome) {
                AddIncomeView()
                    .environmentObject(incomeManager)
                    .environmentObject(currencyManager)
                    .environmentObject(languageManager)
                    .environmentObject(themeManager)
            }
        }
    }
    
    private var monthlyOverviewCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(languageManager.localized("monthly_overview"))
                .font(.title2)
                .fontWeight(.semibold)
            
            // Total this month - centered
            VStack(spacing: 8) {
                Text(currencyManager.formatAmount(billManager.totalMonthlyAmount))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Text(languageManager.localized("total_this_month"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            // Other metrics in one horizontal line
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("\(billManager.bills.filter { $0.isActive }.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.appRed)
                    
                    Text(languageManager.localized("active_bills"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("\(billManager.upcomingBills.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text(languageManager.localized("upcoming"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("\(billManager.overdueBills.count)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    
                    Text(languageManager.localized("overdue"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Income Percentage Analytics
            if incomeManager.hasIncomeSet() {
                Divider()
                
                HStack {
                        Text(languageManager.localized("bills"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Text(incomeManager.getBillsPercentageText(totalBills: billManager.totalMonthlyAmount))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("%")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text(languageManager.localized("of_income"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    
                    Button(action: {
                        showingAddIncome = true
                    }) {
                        Text(languageManager.localized("update"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.appRed)
                            .cornerRadius(8)
                    }
                }
            } else {
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(languageManager.localized("add_income"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(languageManager.localized("to_see_bill_share"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showingAddIncome = true
                    }) {
                        Text(languageManager.localized("add"))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.appRed)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var spendingByCategoryCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(languageManager.localized("category_breakdown"))
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    EnhancedPieChartView(slices: pieSlices, lineWidth: 60, showsCenterHole: true)
                    VStack(spacing: 4) {
                        Text(languageManager.localized("total"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(currencyManager.formatAmount(totalSpending))
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .frame(height: 280)
                .frame(maxWidth: .infinity, alignment: .center)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(categorySpendingColored, id: \.category) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.color)
                                .frame(width: 10, height: 10)
                            Text(item.category)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(percentage(of: item.amount), specifier: "%.0f")%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(currencyManager.formatAmount(item.amount))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(themeManager.isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var upcomingPaymentsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(languageManager.localized("upcoming_payments"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !billManager.upcomingBills.isEmpty && billManager.upcomingBills.count > 5 {
                    Button(showAllUpcoming ? "Show less" : "Show all") {
                        showAllUpcoming.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.appRed)
                }
            }
            
            let upcoming = showAllUpcoming ? billManager.upcomingBills : Array(billManager.upcomingBills.prefix(5))
            if upcoming.isEmpty {
                Text(languageManager.localized("no_upcoming_payments"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    ForEach(upcoming, id: \.id) { bill in
                        HStack {
                            // Icon - same as dashboard
                            if let customImageData = bill.customImageData, let customImage = UIImage(data: customImageData) {
                                // Custom image - fill entire circle
                                Image(uiImage: customImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                // System icon with dynamic color
                                let iconColor = getIconColor(for: bill)
                                ZStack {
                                    Circle()
                                        .fill(iconColor.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: bill.icon)
                                        .font(.title3)
                                        .foregroundColor(iconColor)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(bill.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                
                                Text(upcomingPaymentDateString(for: bill))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text(bill.formattedAmount)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var donePaymentsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(languageManager.localized("completed_payments"))
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !billManager.overdueBills.isEmpty && billManager.overdueBills.count > 5 {
                    Button(showAllDone ? "Show less" : "Show all") {
                        showAllDone.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.appRed)
                }
            }
            
            let done = showAllDone ? billManager.overdueBills : Array(billManager.overdueBills.prefix(5))
            if done.isEmpty {
                Text(languageManager.localized("no_payments_done_yet_this_month"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    ForEach(done, id: \.id) { bill in
                        HStack {
                            // Icon - same as dashboard
                            if let customImageData = bill.customImageData, let customImage = UIImage(data: customImageData) {
                                // Custom image - fill entire circle
                                Image(uiImage: customImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                // System icon with dynamic color
                                let iconColor = getIconColor(for: bill)
                                ZStack {
                                    Circle()
                                        .fill(iconColor.opacity(0.15))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: bill.icon)
                                        .font(.title3)
                                        .foregroundColor(iconColor)
                                }
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(bill.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                Text(completedPaymentDateString(for: bill))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(bill.formattedAmount)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .padding()
        .background(themeManager.isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var categorySpending: [(category: String, amount: Double)] {
        // Group by bill.category using monthly-equivalent amounts
        let activeBills = billManager.bills.filter { $0.isActive }
        var totals: [String: Double] = [:]
        for bill in activeBills {
            let monthlyAmount = bill.isYearlyPayment ? bill.amount / 12 : bill.amount
            totals[bill.category, default: 0] += monthlyAmount
        }
        let items = totals.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
        return items
    }
    
    private var totalSpending: Double {
        categorySpending.reduce(0) { $0 + $1.amount }
    }
    
    private func percentage(of amount: Double) -> Double {
        let total = max(totalSpending, 0.000001)
        return (amount / total) * 100
    }
    
    private var categorySpendingColored: [(category: String, amount: Double, color: Color)] {
        let items = categorySpending
        return items.enumerated().map { index, item in
            let color = categoryPalette[index % categoryPalette.count]
            return (category: item.category, amount: item.amount, color: color)
        }
    }
    
    private var pieSlices: [PieSliceData] {
        categorySpendingColored.map { item in
            PieSliceData(value: item.amount, color: item.color)
        }
    }
    
    // MARK: - Calendar Card
    
    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(languageManager.localized("monthly_calendar"))
                .font(.title2)
                .fontWeight(.semibold)
            
            // Month Navigation
            HStack {
                Button(action: {
                    slideDirection = .right
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.appRed)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.appRed)
                
                Spacer()
                
                Button(action: {
                    slideDirection = .left
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentDate = Calendar.current.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.appRed)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                // Day headers
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(height: 30)
                }
                
                // Calendar days
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        Button(action: {
                            selectedDate = date
                        }) {
                            VStack(spacing: 2) {
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(isToday(date) ? .white : .primary)
                                
                                // Bill indicators
                                if !billsForDate(date).isEmpty {
                                    HStack(spacing: 2) {
                                        ForEach(Array(billsForDate(date).prefix(3)), id: \.id) { bill in
                                            Circle()
                                                .fill(getIconColor(for: bill))
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                }
                            }
                            .frame(width: 35, height: 35)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedDate == date ? Color(.systemGray5) : (isToday(date) ? Color.appRed : Color.clear))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Color.clear
                            .frame(width: 35, height: 35)
                    }
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: slideDirection == .left ? .trailing : .leading),
                removal: .move(edge: slideDirection == .left ? .leading : .trailing)
            ))
            .id(currentDate)
            
            // Selected Date Bills
            if let selectedDate = selectedDate {
                Divider()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("\(languageManager.localized("bills_on")) \(selectedDateString)")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Button(languageManager.localized("clear")) {
                            self.selectedDate = nil
                        }
                        .font(.caption)
                        .foregroundColor(.appRed)
                    }
                    
                    if billsForDate(selectedDate).isEmpty {
                        Text(languageManager.localized("no_bills_scheduled"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(billsForDate(selectedDate), id: \.id) { bill in
                                HStack {
                                    // Icon
                                    if let customImageData = bill.customImageData, let customImage = UIImage(data: customImageData) {
                                        Image(uiImage: customImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                    } else {
                                        let iconColor = getIconColor(for: bill)
                                        ZStack {
                                            Circle()
                                                .fill(iconColor.opacity(0.15))
                                                .frame(width: 30, height: 30)
                                            
                                            Image(systemName: bill.icon)
                                                .font(.caption)
                                                .foregroundColor(iconColor)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(bill.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        
                                        Text(bill.formattedAmount)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    if let dueDate = bill.dueDate {
                                        Text(dueDateString(for: dueDate))
                                            .font(.caption2)
                                            .foregroundColor(.orange)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(themeManager.isDarkMode ? Color(.systemGray6) : Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Calendar Helper Functions
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offsetDays = firstWeekday - 1
        
        let startDate = calendar.date(byAdding: .day, value: -Int(offsetDays), to: startOfMonth) ?? startOfMonth
        let endDate = calendar.date(byAdding: .day, value: 41, to: startDate) ?? startDate
        
        var dates: [Date?] = []
        var tempDate = startDate
        
        while tempDate < endDate {
            if calendar.isDate(tempDate, equalTo: startOfMonth, toGranularity: .month) {
                dates.append(tempDate)
            } else {
                dates.append(nil)
            }
            tempDate = calendar.date(byAdding: .day, value: 1, to: tempDate) ?? tempDate
        }
        
        return dates
    }
    
    private func isToday(_ date: Date) -> Bool {
        calendar.isDateInToday(date)
    }
    
    private func billsForDate(_ date: Date) -> [Bill] {
        let day = calendar.component(.day, from: date)
        return billManager.bills.filter { bill in
            // Only show active bills
            guard bill.isActive else { return false }
            
            // Check if the bill is due on this day of the month
            guard bill.paymentDate == day else { return false }
            
            // If the bill has a due date, check if it hasn't passed
            if let dueDate = bill.dueDate {
                // Only show if the due date is today or in the future
                return dueDate >= calendar.startOfDay(for: date)
            }
            
            // If no due date (forever), always show
            return true
        }
    }
    
    private var selectedDateString: String {
        guard let selectedDate = selectedDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: selectedDate)
    }
    
    private func dueDateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Slide Direction Enum
enum SlideDirection {
    case left
    case right
    case none
}

#Preview {
    InsightsView()
        .environmentObject(ThemeManager())
}
