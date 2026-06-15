//
//  CalendarView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var billManager: BillManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var currentDate = Date()
    @State private var selectedDate: Date?
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Month Navigation
                    monthNavigationView
                    
                    // Calendar Grid
                    calendarGridView
                    
                    // Bill Details for Selected Date
                    if let selectedDate = selectedDate {
                        billDetailsView(for: selectedDate)
                    }
                    
                    // Monthly Summary
                    monthlySummaryView
                }
                .padding()
            }
            .navigationTitle("Bill Calendar")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var monthNavigationView: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.appRed)
            }
            
            Spacer()
            
            Text(monthYearString)
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.appRed)
            }
        }
        .padding(.horizontal)
    }
    
    private var calendarGridView: some View {
        VStack(spacing: 0) {
            // Day headers
            HStack(spacing: 0) {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                }
            }
            
            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 0) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        calendarDayView(for: date)
                    } else {
                        // Empty cell for padding
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 60)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func calendarDayView(for date: Date) -> some View {
        let billsForDate = billsForDate(date)
        let isToday = calendar.isDate(date, inSameDayAs: Date())
        let isSelected = selectedDate.map { calendar.isDate(date, inSameDayAs: $0) } ?? false
        
        return Button(action: {
            selectedDate = date
        }) {
            VStack(spacing: 2) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isToday ? .white : .primary)
                
                // Bill indicators
                if !billsForDate.isEmpty {
                    HStack(spacing: 2) {
                        ForEach(billsForDate.prefix(3), id: \.id) { bill in
                            Circle()
                                .fill(billColor(for: bill))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor(for: date, isToday: isToday, isSelected: isSelected))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func billDetailsView(for date: Date) -> some View {
        let billsForDate = billsForDate(date)
        
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dateString(for: date))
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                if !billsForDate.isEmpty {
                    Text("\(billsForDate.count) bill\(billsForDate.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            if billsForDate.isEmpty {
                Text("No bills scheduled")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
            } else {
                ForEach(billsForDate) { bill in
                    billRowView(for: bill)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func billRowView(for bill: Bill) -> some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(billColor(for: bill).opacity(0.15))
                    .frame(width: 40, height: 40)
                
                if let imageData = bill.customImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                } else {
                    Image(systemName: bill.icon)
                        .font(.title3)
                        .foregroundColor(billColor(for: bill))
                }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(bill.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(bill.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(currencyManager.formatAmount(bill.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(bill.isYearlyPayment ? "Yearly" : "Monthly")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var monthlySummaryView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            HStack(spacing: 20) {
                summaryCard(
                    title: "Total Bills",
                    value: "\(activeBills.count)",
                    color: .appRed
                )
                
                summaryCard(
                    title: "Total Amount",
                    value: currencyManager.formatAmount(totalMonthlyAmount),
                    color: .green
                )
            }
            
            HStack(spacing: 20) {
                summaryCard(
                    title: "Upcoming",
                    value: "\(upcomingBills.count)",
                    color: .orange
                )
                
                summaryCard(
                    title: "Overdue",
                    value: "\(overdueBills.count)",
                    color: .red
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func summaryCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    // MARK: - Helper Methods
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: currentDate)?.start ?? currentDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentDate)?.count ?? 30
        
        var days: [Date?] = []
        
        // Add padding for first week
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add all days in month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Add padding for last week
        let remainingCells = 7 - (days.count % 7)
        if remainingCells < 7 {
            for _ in 0..<remainingCells {
                days.append(nil)
            }
        }
        
        return days
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
    
    private func billColor(for bill: Bill) -> Color {
        let category = bill.category.lowercased()
        let name = bill.name.lowercased()
        
        if category.contains("entertainment") || name.contains("netflix") || name.contains("spotify") || name.contains("apple one") || name.contains("amazon prime") || name.contains("disney") || name.contains("hulu") || name.contains("youtube") {
            return .red
        } else if category.contains("software") || name.contains("adobe") || name.contains("microsoft") || name.contains("google") || name.contains("jetbrains") || name.contains("figma") || name.contains("sketch") || name.contains("slack") || name.contains("zoom") || name.contains("github") || name.contains("jira") || name.contains("notion") || name.contains("canva") || name.contains("chatgpt") || name.contains("claude") || name.contains("apple developer") {
            return .purple
        } else if category.contains("fitness") || name.contains("gym") || name.contains("peloton") {
            return .green
        } else if category.contains("healthcare") || name.contains("health") || name.contains("dental") || name.contains("vision") {
            return .pink
        } else if category.contains("housing") || name.contains("rent") || name.contains("mortgage") || name.contains("internet") || name.contains("electricity") || name.contains("water") || name.contains("gas") {
            return .orange
        } else if category.contains("transportation") || name.contains("car") || name.contains("bus") || name.contains("train") || name.contains("uber") || name.contains("lyft") {
            return .yellow
        } else if category.contains("finance") || name.contains("loan") || name.contains("credit card") || name.contains("insurance") {
            return .blue
        } else {
            return .gray
        }
    }
    
    private func backgroundColor(for date: Date, isToday: Bool, isSelected: Bool) -> Color {
        if isToday {
            return .appRed
        } else if isSelected {
            return .appRed.opacity(0.2)
        } else {
            return Color(.systemBackground)
        }
    }
    
    private func dateString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
            selectedDate = nil
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
            selectedDate = nil
        }
    }
    
    // MARK: - Computed Properties
    
    private var activeBills: [Bill] {
        billManager.bills.filter { $0.isActive }
    }
    
    private var totalMonthlyAmount: Double {
        billManager.totalMonthlyAmount
    }
    
    private var upcomingBills: [Bill] {
        billManager.upcomingBills
    }
    
    private var overdueBills: [Bill] {
        billManager.overdueBills
    }
}

#Preview {
    CalendarView()
        .environmentObject(BillManager())
        .environmentObject(CurrencyManager())
        .environmentObject(ThemeManager())
}
