//
//  AddBillView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

struct AddBillView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var billManager: BillManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var billName = ""
    @State private var amount = ""
    @State private var paymentDate = 1
    @State private var dueDate = Date().addingTimeInterval(365 * 24 * 60 * 60) // Default to 1 year from now
    @State private var hasDueDate = false // Checkbox state for due date
    @State private var selectedIcon = "creditcard"
    @State private var selectedImage: UIImage?
    @State private var showingIconPicker = false
    @State private var isYearlyPayment = false
    @State private var yearlyPaymentDate = Date()
    @State private var showingYearlyDatePicker = false
    @State private var selectedDay = 1
    @State private var selectedMonth = 1
    @State private var showingDatePicker = false
    @State private var showingDueDatePicker = false
    @State private var selectedCategory = "None"
    @State private var showingKnownBillsPicker = false
    @State private var selectedKnownBill: KnownBill?
    @State private var hasNotification = true
    @State private var notificationDaysBefore = 1
    @State private var notificationTime = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showingTimePicker = false
    
    private let currencies = ["USD", "EUR", "GBP", "ILS", "CAD", "AUD"]
    
    // Helper function to detect large screen devices (iPhone 15 Plus, Pro Max, etc.)
    private var isLargeScreenDevice: Bool {
        let screenWidth = UIScreen.main.bounds.width
        // iPhone 15 Plus, Pro Max, and similar devices have width >= 430
        return screenWidth >= 430
    }
    private let paymentDates = Array(1...31)
    private let categories = ["None", "Housing & Utilities", "Transportation", "Healthcare", "Finance", "Subscriptions", "Other"]
    private let notificationOptions = [1, 2, 5]
    private let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    private var dueDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dueDate)
    }
    
    private var notificationTimeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: notificationTime)
    }
    
    private var yearlyPaymentDateString: String {
        let monthName = monthNames[selectedMonth - 1]
        return "\(selectedDay) \(monthName.prefix(3))"
    }
    
    private func localizedCategory(_ category: String) -> String {
        switch category {
        case "None":
            return languageManager.localized("category")
        case "Housing & Utilities":
            return languageManager.localized("housing_utilities")
        case "Transportation":
            return languageManager.localized("transportation")
        case "Healthcare":
            return languageManager.localized("healthcare")
        case "Finance":
            return languageManager.localized("finance")
        case "Subscriptions":
            return languageManager.localized("subscriptions")
        case "Other":
            return languageManager.localized("other")
        default:
            return category
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Bill Name Section
                Section(languageManager.localized("bill_information")) {
                    HStack {
                        TextField(languageManager.localized("bill_name_placeholder"), text: $billName)
                        
                        Button(action: {
                            showingKnownBillsPicker = true
                        }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.appRed)
                        }
                    }
                    
                    Menu {
                        ForEach(categories, id: \.self) { category in
                            Button(localizedCategory(category)) {
                                selectedCategory = category
                            }
                        }
                    } label: {
                        HStack {
                            Text(localizedCategory(selectedCategory))
                                .foregroundColor(selectedCategory == "None" ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.appRed)
                        }
                    }
                }
                
                // Amount Section
                Section(languageManager.localized("amount")) {
                    TextField(languageManager.localized("amount_placeholder"), text: $amount)
                        .keyboardType(.decimalPad)
                }
                
                // Payment Date Section
                Section(languageManager.localized("payment_date")) {
                    Button(action: {
                        showingDatePicker = true
                    }) {
                        HStack {
                            Text(languageManager.localized("day_of_month"))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text("\(paymentDate)\(ordinalSuffix(for: paymentDate))")
                                .foregroundColor(.appRed)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.appRed)
                        }
                    }
                    .disabled(isYearlyPayment)
                    .opacity(isYearlyPayment ? 0.5 : 1.0)
                    
                    Toggle(languageManager.localized("yearly_payment"), isOn: $isYearlyPayment)
                    
                    if isYearlyPayment {
                        HStack {
                            Text(languageManager.localized("payment_date"))
                            Spacer()
                            Text(yearlyPaymentDateString)
                                .foregroundColor(.appRed)
                            Button(action: {
                                showingYearlyDatePicker = true
                            }) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.appRed)
                            }
                        }
                    }
                }
                
                // Notification Section
                Section(languageManager.localized("notifications")) {
                    Toggle(languageManager.localized("enable_notifications"), isOn: $hasNotification)
                    
                    if hasNotification {
                        Menu {
                            ForEach(notificationOptions, id: \.self) { days in
                                Button("\(days)") {
                                    notificationDaysBefore = days
                                }
                            }
                        } label: {
                            HStack {
                                Text("\(notificationDaysBefore) \(notificationDaysBefore == 1 ? languageManager.localized("day_before") : languageManager.localized("days_before"))")
                                    .font(.system(size: isLargeScreenDevice ? 24 : 18))
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.appRed)
                            }
                        }
                        
                        Button(action: {
                            showingTimePicker = true
                        }) {
                            HStack {
                                Text(languageManager.localized("notification_time"))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(notificationTimeString)
                                    .foregroundColor(.appRed)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.appRed)
                            }
                        }
                    }
                }
                
                // Due Date Section
                Section(languageManager.localized("due_date")) {
                    Toggle(languageManager.localized("set_due_date"), isOn: $hasDueDate)
                    
                    if hasDueDate {
                        Button(action: {
                            showingDueDatePicker = true
                        }) {
                            HStack {
                                Text(languageManager.localized("due_date"))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text(dueDateString)
                                    .foregroundColor(.appRed)
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.appRed)
                            }
                        }
                    } else {
                        HStack {
                            Text(languageManager.localized("due_date"))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(languageManager.localized("forever"))
                                .foregroundColor(.appRed)
                        }
                    }
                }
                
                // Icon Selection Section
                Section(languageManager.localized("icon")) {
                    HStack {
                        if let selectedImage = selectedImage {
                            // Custom image - fill entire circle
                            Image(uiImage: selectedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        } else {
                            // System icon - keep current size
                            ZStack {
                                Circle()
                                    .fill(Color.appRed.opacity(0.1))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: selectedIcon)
                                    .font(.title2)
                                    .foregroundColor(.appRed)
                            }
                        }
                        
                        Spacer()
                        
                        Button(languageManager.localized("select")) {
                            showingIconPicker = true
                        }
                        .foregroundColor(.appRed)
                    }
                }
            }
            .navigationTitle(languageManager.localized("add_new_bill"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.localized("cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localized("save")) {
                        saveBill()
                    }
                    .disabled(billName.isEmpty || amount.isEmpty)
                }
            }
            .sheet(isPresented: $showingIconPicker) {
                IconPickerView(selectedIcon: $selectedIcon, selectedImage: $selectedImage, themeManager: themeManager)
            }
            .sheet(isPresented: $showingKnownBillsPicker) {
                KnownBillsPickerView(selectedBill: $selectedKnownBill)
                    .environmentObject(languageManager)
                    .onDisappear {
                        if let knownBill = selectedKnownBill {
                            billName = knownBill.name
                            selectedIcon = knownBill.icon
                            selectedCategory = knownBill.category
                            if let suggestedAmount = knownBill.suggestedAmount {
                                amount = String(format: "%.2f", suggestedAmount)
                            }
                        }
                    }
            }
            .popover(isPresented: $showingDatePicker) {
                VStack {
                    Picker("Day of month", selection: $paymentDate) {
                        ForEach(paymentDates, id: \.self) { date in
                            Text("\(date)\(ordinalSuffix(for: date))").tag(date)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 200)
                    .padding()
                }
                .frame(width: 300, height: 250)
                .presentationDetents([.height(250)])
            }
            .popover(isPresented: $showingDueDatePicker) {
                VStack {
                    DatePicker(
                        "Due Date",
                        selection: $dueDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(height: 200)
                    .padding()
                }
                .frame(width: 300, height: 250)
                .presentationDetents([.height(250)])
            }
            .popover(isPresented: $showingTimePicker) {
                VStack {
                    DatePicker(
                        "Notification Time",
                        selection: $notificationTime,
                        displayedComponents: [.hourAndMinute]
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .frame(height: 200)
                    .padding()
                }
                .frame(width: 300, height: 250)
                .presentationDetents([.height(250)])
            }
            .popover(isPresented: $showingYearlyDatePicker) {
                VStack {
//                    Text("Yearly Payment Date")
//                        .font(.headline)
//                        .padding(.top)
                    
                    HStack(spacing: 0) {
                        // Day Picker
                        Picker("Day", selection: $selectedDay) {
                            ForEach(1...31, id: \.self) { day in
                                Text("\(day)")
                                    .tag(day)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                        
                        // Month Picker
                        Picker("Month", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text(monthNames[month - 1])
                                    .tag(month)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150)
                    }
                    .frame(height: 200)
                    .padding()
                }
                .frame(width: 300, height: 250)
                .presentationDetents([.height(250)])
            }

        }
        .onAppear {
            // Initialize selected day and month from yearlyPaymentDate
            let calendar = Calendar.current
            selectedDay = calendar.component(.day, from: yearlyPaymentDate)
            selectedMonth = calendar.component(.month, from: yearlyPaymentDate)
        }
    }
    
    private func saveBill() {
        guard let amountValue = Double(amount), !billName.isEmpty else { return }
        
        // Convert UIImage to Data if selected
        let imageData = selectedImage?.jpegData(compressionQuality: 0.8)
        
        // Create yearly payment date from selected day and month
        let yearlyDate: Date?
        if isYearlyPayment {
            let calendar = Calendar.current
            let currentYear = calendar.component(.year, from: Date())
            yearlyDate = calendar.date(from: DateComponents(year: currentYear, month: selectedMonth, day: selectedDay))
        } else {
            yearlyDate = nil
        }
        
        let newBill = Bill(
            name: billName,
            amount: amountValue,
            currency: currencyManager.defaultCurrency,
            paymentDate: paymentDate,
            dueDate: hasDueDate ? dueDate : nil,
            icon: selectedIcon,
            customImageData: imageData,
            isActive: true,
            isYearlyPayment: isYearlyPayment,
            yearlyPaymentDate: yearlyDate,
            category: selectedCategory,
            hasNotification: hasNotification,
            notificationDaysBefore: notificationDaysBefore,
            notificationTime: notificationTime
        )
        
        billManager.addBill(newBill)
        dismiss()
    }
    
    private func ordinalSuffix(for number: Int) -> String {
        switch number {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
    

}



struct IconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedIcon: String
    @Binding var selectedImage: UIImage?
    let themeManager: ThemeManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var selectedTab = 0
    @State private var showingImagePicker = false
    
    private let icons = [
        "creditcard", "tv", "music.note", "applelogo", "paintbrush", 
        "figure.run", "wifi", "bolt", "phone", "house", "car", 
        "gamecontroller", "book", "graduationcap", "heart", "cross",
        "pills", "stethoscope", "building.2", "cart", "bag", 
        "gift", "star", "crown", "diamond", "leaf", "flame", 
        "drop", "snowflake", "sun.max", "moon", "cloud", "umbrella"
    ]
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Selection", selection: $selectedTab) {
                    Text(languageManager.localized("icons")).tag(0)
                    Text(languageManager.localized("photos")).tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Tab Content
                if selectedTab == 0 {
                    // Icons Tab
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(icons, id: \.self) { icon in
                                Button(action: {
                                    selectedIcon = icon
                                    selectedImage = nil // Clear any selected image
                                    dismiss()
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(selectedIcon == icon ? Color.appRed : (themeManager.isDarkMode ? Color(.systemGray5) : Color.gray.opacity(0.1)))
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: icon)
                                            .font(.title2)
                                            .foregroundColor(selectedIcon == icon ? .white : .appRed)
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    // Photos Tab
                    VStack(spacing: 20) {
                        Spacer()
                        
                        if let selectedImage = selectedImage {
                            VStack(spacing: 16) {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.appRed, lineWidth: 3))
                                
                                Text(languageManager.localized("selected_image"))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Button(languageManager.localized("use_this_image")) {
                                    selectedIcon = "" // Clear icon selection
                                    dismiss()
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "photo")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text(languageManager.localized("no_image_selected"))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("tap_to_select_image"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        
                        Button(selectedImage == nil ? languageManager.localized("select_image") : languageManager.localized("change_image")) {
                            showingImagePicker = true
                        }
                        .buttonStyle(.bordered)
                        
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle(languageManager.localized("select"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localized("done")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
        }
    }
}



#Preview {
    AddBillView(billManager: BillManager())
        .environmentObject(ThemeManager())
}
