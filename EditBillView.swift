//
//  EditBillView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

struct EditBillView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var billManager: BillManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    let bill: Bill
    
    @State private var billName: String
    @State private var amount: String
    @State private var paymentDate: Int
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var selectedIcon: String
    @State private var selectedImage: UIImage?
    @State private var isYearlyPayment: Bool
    @State private var yearlyPaymentDate: Date
    @State private var showingYearlyDatePicker = false
    @State private var selectedDay = 1
    @State private var selectedMonth = 1
    @State private var showingIconPicker = false
    @State private var showingDeleteAlert = false
    @State private var showingDatePicker = false
    @State private var showingDueDatePicker = false
    @State private var selectedCategory: String
    @State private var showingKnownBillsPicker = false
    @State private var selectedKnownBill: KnownBill?
    @State private var hasNotification: Bool
    @State private var notificationDaysBefore: Int
    @State private var notificationTime: Date
    @State private var showingTimePicker = false
    
    private let currencies = ["USD", "EUR", "GBP", "ILS", "CAD", "AUD"]
    private let paymentDates = Array(1...31)
    private let categories = ["None", "Housing & Utilities", "Transportation", "Healthcare", "Finance", "Subscriptions", "Other"]
    private let notificationOptions = [1, 2, 5]
    private let monthNames = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    // Helper function to detect large screen devices (iPhone 15 Plus, Pro Max, etc.)
    private var isLargeScreenDevice: Bool {
        let screenWidth = UIScreen.main.bounds.width
        // iPhone 15 Plus, Pro Max, and similar devices have width >= 430
        return screenWidth >= 430
    }
    
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
    
    init(bill: Bill, billManager: BillManager) {
        self.bill = bill
        self.billManager = billManager
        self._billName = State(initialValue: bill.name)
        self._amount = State(initialValue: String(bill.amount))
        self._paymentDate = State(initialValue: bill.paymentDate)
        self._dueDate = State(initialValue: bill.dueDate ?? Date().addingTimeInterval(365 * 24 * 60 * 60))
        self._hasDueDate = State(initialValue: bill.dueDate != nil)
        self._selectedIcon = State(initialValue: bill.icon)
        self._selectedImage = State(initialValue: bill.customImageData != nil ? UIImage(data: bill.customImageData!) : nil)
        self._isYearlyPayment = State(initialValue: bill.isYearlyPayment)
        self._yearlyPaymentDate = State(initialValue: bill.yearlyPaymentDate ?? Date())
        
        // Initialize selected day and month from yearlyPaymentDate
        let calendar = Calendar.current
        let yearlyDate = bill.yearlyPaymentDate ?? Date()
        self._selectedDay = State(initialValue: calendar.component(.day, from: yearlyDate))
        self._selectedMonth = State(initialValue: calendar.component(.month, from: yearlyDate))
        
        self._selectedCategory = State(initialValue: bill.category)
        self._hasNotification = State(initialValue: bill.hasNotification)
        self._notificationDaysBefore = State(initialValue: bill.notificationDaysBefore)
        self._notificationTime = State(initialValue: bill.notificationTime)
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
                
                // Delete Section
                Button(languageManager.localized("delete_bill")) {
                    showingDeleteAlert = true
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red)
                .cornerRadius(12)
                .listRowBackground(Color.clear)
            }
            .navigationTitle(languageManager.localized("edit_bill"))
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

            .alert("Delete Bill", isPresented: $showingDeleteAlert) {
                Button(languageManager.localized("cancel"), role: .cancel) { }
                Button(languageManager.localized("delete"), role: .destructive) {
                    deleteBill()
                }
            } message: {
                Text("\(languageManager.localized("are_you_sure_delete")) '\(bill.name)'?")
            }
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
        
        // Create updated bill with the same ID as the original
            let updatedBill = Bill(
                id: bill.id, // Preserve the original bill's ID
                name: billName,
                amount: amountValue,
                currency: currencyManager.defaultCurrency, // Use global currency
                paymentDate: paymentDate,
                dueDate: hasDueDate ? dueDate : nil,
                icon: selectedIcon,
                customImageData: imageData,
                isActive: bill.isActive,
                isYearlyPayment: isYearlyPayment,
                yearlyPaymentDate: yearlyDate,
                category: selectedCategory,
                hasNotification: hasNotification,
                notificationDaysBefore: notificationDaysBefore,
                notificationTime: notificationTime
            )
        
        // Update the bill using BillManager method
        billManager.updateBill(updatedBill)
        
        dismiss()
    }
    
    private func deleteBill() {
        // Delete the bill using BillManager method
        billManager.deleteBill(bill)
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



#Preview {
    EditBillView(bill: Bill(name: "Netflix", amount: 15.99, currency: "USD", paymentDate: 15, dueDate: Date().addingTimeInterval(7 * 24 * 60 * 60), icon: "tv"), billManager: BillManager())
        .environmentObject(ThemeManager())
}
