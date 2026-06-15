//
//  Bill.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import Foundation

struct Bill: Identifiable, Codable {
    let id: UUID
    let userId: UUID? // Associate bill with a specific user
    let name: String
    let amount: Double
    let currency: String
    let paymentDate: Int // Day of the month (1-31)
    let dueDate: Date? // When the bill is actually due
    let icon: String
    let customImageData: Data?
    let isActive: Bool
    let isYearlyPayment: Bool
    let yearlyPaymentDate: Date?
    let category: String
    let hasNotification: Bool
    let notificationDaysBefore: Int
    let notificationTime: Date
    
    init(name: String, amount: Double, currency: String = "USD", paymentDate: Int, dueDate: Date? = nil, icon: String = "creditcard", customImageData: Data? = nil, isActive: Bool = true, isYearlyPayment: Bool = false, yearlyPaymentDate: Date? = nil, category: String = "None", hasNotification: Bool = true, notificationDaysBefore: Int = 1, notificationTime: Date? = nil, userId: UUID? = nil) {
        self.id = UUID()
        self.userId = userId
        self.name = name
        self.amount = amount
        self.currency = currency
        self.paymentDate = paymentDate
        self.dueDate = dueDate
        self.icon = icon
        self.customImageData = customImageData
        self.isActive = isActive
        self.isYearlyPayment = isYearlyPayment
        self.yearlyPaymentDate = yearlyPaymentDate
        self.category = category
        self.hasNotification = hasNotification
        self.notificationDaysBefore = notificationDaysBefore
        
        // Set default notification time to 19:00 (7:00 PM) if not provided
        if let notificationTime = notificationTime {
            self.notificationTime = notificationTime
        } else {
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.year, .month, .day], from: now)
            var timeComponents = DateComponents()
            timeComponents.hour = 19
            timeComponents.minute = 0
            self.notificationTime = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: now) ?? now
        }
    }
    
    // Initializer for updating existing bills (preserves the original ID)
    init(id: UUID, name: String, amount: Double, currency: String = "USD", paymentDate: Int, dueDate: Date? = nil, icon: String = "creditcard", customImageData: Data? = nil, isActive: Bool = true, isYearlyPayment: Bool = false, yearlyPaymentDate: Date? = nil, category: String = "None", hasNotification: Bool = true, notificationDaysBefore: Int = 1, notificationTime: Date? = nil, userId: UUID? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.amount = amount
        self.currency = currency
        self.paymentDate = paymentDate
        self.dueDate = dueDate
        self.icon = icon
        self.customImageData = customImageData
        self.isActive = isActive
        self.isYearlyPayment = isYearlyPayment
        self.yearlyPaymentDate = yearlyPaymentDate
        self.category = category
        self.hasNotification = hasNotification
        self.notificationDaysBefore = notificationDaysBefore
        
        // Set default notification time to 19:00 (7:00 PM) if not provided
        if let notificationTime = notificationTime {
            self.notificationTime = notificationTime
        } else {
            let calendar = Calendar.current
            let now = Date()
            let components = calendar.dateComponents([.year, .month, .day], from: now)
            var timeComponents = DateComponents()
            timeComponents.hour = 19
            timeComponents.minute = 0
            self.notificationTime = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: now) ?? now
        }
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        
        // For yearly payments, show the monthly equivalent in the welcome view
        let displayAmount = isYearlyPayment ? amount / 12 : amount
        return formatter.string(from: NSNumber(value: displayAmount)) ?? "\(currencySymbol)\(displayAmount)"
    }
    
    var paymentDateString: String {
        if isYearlyPayment, let yearlyPaymentDate = yearlyPaymentDate {
            // For yearly payments, show "every" with the actual date in DD/MM/YYYY format
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            return "every \(formatter.string(from: yearlyPaymentDate))"
        } else {
            // For monthly payments, show "every Xth"
            let formatter = NumberFormatter()
            formatter.numberStyle = .ordinal
            let ordinalDay = formatter.string(from: NSNumber(value: paymentDate)) ?? "\(paymentDate)"
            return "every \(ordinalDay)"
        }
    }
    
    var dueDateString: String {
        guard let dueDate = dueDate else { return "Forever" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dueDate)
    }
    
    private var currencySymbol: String {
        switch currency {
        case "USD":
            return "$"
        case "EUR":
            return "€"
        case "GBP":
            return "£"
        case "ILS":
            return "₪"
        case "CAD":
            return "C$"
        case "AUD":
            return "A$"
        default:
            return "$"
        }
    }
}
