//
//  BillManager.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import Foundation
import SwiftUI

class BillManager: ObservableObject {
    private var isRefreshing = false // Flag to prevent saving during refresh
    
    @Published var bills: [Bill] = [] {
        didSet {
            // Only save if we're not in the middle of a refresh
            if !isRefreshing {
                saveBills()
            }
            // Reschedule notifications when bills change
            Task {
                await NotificationManager.shared.requestPermission()
                NotificationManager.shared.rescheduleAllNotifications(for: bills)
            }
        }
    }
    
    private let billsKeyPrefix = "SavedBills_"
    private let guestBillsKey = "GuestBills"
    
    // Get the current user ID
    private var currentUserId: UUID? {
        if let currentUserData = UserDefaults.standard.data(forKey: "CurrentUser"),
           let user = try? JSONDecoder().decode(User.self, from: currentUserData) {
            return user.id
        }
        return nil
    }
    
    // Get the storage key for the current user
    private var currentUserBillsKey: String {
        if let userId = currentUserId {
            return "\(billsKeyPrefix)\(userId.uuidString)"
        }
        return guestBillsKey
    }
    
    init() {
        loadBills()
    }
    
    private func loadBills() {
        let key = currentUserBillsKey
        if let data = UserDefaults.standard.data(forKey: key),
           let decodedBills = try? JSONDecoder().decode([Bill].self, from: data) {
            // Filter bills to only include those belonging to the current user (or guest)
            if let userId = currentUserId {
                // For logged-in users: only show bills with their userId
                // Also include bills with nil userId for backward compatibility (migrate them)
                var userBills = decodedBills.filter { $0.userId == userId || $0.userId == nil }
                // Migrate bills with nil userId to the current user
                var migratedBills: [Bill] = []
                for bill in userBills {
                    if bill.userId == nil {
                        // Migrate this bill to the current user
                        let migratedBill = Bill(
                            id: bill.id,
                            name: bill.name,
                            amount: bill.amount,
                            currency: bill.currency,
                            paymentDate: bill.paymentDate,
                            dueDate: bill.dueDate,
                            icon: bill.icon,
                            customImageData: bill.customImageData,
                            isActive: bill.isActive,
                            isYearlyPayment: bill.isYearlyPayment,
                            yearlyPaymentDate: bill.yearlyPaymentDate,
                            category: bill.category,
                            hasNotification: bill.hasNotification,
                            notificationDaysBefore: bill.notificationDaysBefore,
                            notificationTime: bill.notificationTime,
                            userId: userId
                        )
                        migratedBills.append(migratedBill)
                    } else {
                        migratedBills.append(bill)
                    }
                }
                bills = migratedBills
                // Save migrated bills
                if migratedBills.count != decodedBills.count {
                    saveBills()
                }
            } else {
                // For guests: only show bills with nil userId
                bills = decodedBills.filter { $0.userId == nil }
            }
        } else {
            bills = []
        }
    }
    
    private func saveBills() {
        let key = currentUserBillsKey
        if let encoded = try? JSONEncoder().encode(bills) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // Save bills for a specific user ID (used during logout)
    func saveBillsForUser(_ userId: UUID) {
        let key = "\(billsKeyPrefix)\(userId.uuidString)"
        // Filter bills to only save those belonging to this user
        let userBills = bills.filter { $0.userId == userId }
        if let encoded = try? JSONEncoder().encode(userBills) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    // Method to switch between user and guest data when login status changes
    func refreshBillsForCurrentUser() {
        isRefreshing = true
        // Clear current bills first
        bills = []
        // Then load bills for the new user
        loadBills()
        isRefreshing = false
        // Manually save after refresh to ensure bills are saved to the correct key
        saveBills()
    }
    
    private func loadSampleData() {
        bills = [
            Bill(name: "Netflix", amount: 15.99, currency: "USD", paymentDate: 15, dueDate: nil, icon: "tv", isActive: true, isYearlyPayment: false),
            Bill(name: "Spotify", amount: 9.99, currency: "USD", paymentDate: 8, dueDate: nil, icon: "music.note", isActive: true, isYearlyPayment: false),
            Bill(name: "Apple One", amount: 16.95, currency: "USD", paymentDate: 22, dueDate: nil, icon: "applelogo", isActive: true, isYearlyPayment: false),
            Bill(name: "Adobe Creative Cloud", amount: 52.99, currency: "USD", paymentDate: 1, dueDate: nil, icon: "paintbrush", isActive: true, isYearlyPayment: false),
            Bill(name: "Gym Membership", amount: 45.00, currency: "USD", paymentDate: 5, dueDate: nil, icon: "figure.run", isActive: true, isYearlyPayment: false),
            Bill(name: "Internet", amount: 79.99, currency: "USD", paymentDate: 12, dueDate: nil, icon: "wifi", isActive: true, isYearlyPayment: false),
            Bill(name: "Electricity", amount: 120.50, currency: "USD", paymentDate: 18, dueDate: nil, icon: "bolt", isActive: true, isYearlyPayment: false),
            Bill(name: "Phone Bill", amount: 85.00, currency: "USD", paymentDate: 25, dueDate: nil, icon: "phone", isActive: true, isYearlyPayment: false),
            Bill(name: "Amazon Prime", amount: 119.00, currency: "USD", paymentDate: 1, dueDate: nil, icon: "cart", isActive: true, isYearlyPayment: true),
            Bill(name: "Car Insurance", amount: 1200.00, currency: "USD", paymentDate: 1, dueDate: nil, icon: "car", isActive: true, isYearlyPayment: true)
        ]
    }
    
    var totalMonthlyAmount: Double {
        bills.filter { $0.isActive }.reduce(0) { total, bill in
            // For yearly payments, divide by 12 to get monthly equivalent
            let monthlyAmount = bill.isYearlyPayment ? bill.amount / 12 : bill.amount
            return total + monthlyAmount
        }
    }
    
    var upcomingBills: [Bill] {
        let currentDay = Calendar.current.component(.day, from: Date())
        return bills
            .filter { $0.isActive && $0.paymentDate >= currentDay }
            .sorted { $0.paymentDate < $1.paymentDate }
    }
    
    var overdueBills: [Bill] {
        let currentDay = Calendar.current.component(.day, from: Date())
        return bills
            .filter { $0.isActive && $0.paymentDate < currentDay }
            .sorted { $0.paymentDate < $1.paymentDate }
    }
    
    // MARK: - Bill Management Methods
    
    func addBill(_ bill: Bill) {
        // Always associate the bill with the current user
        let billToAdd = Bill(
            id: bill.id,
            name: bill.name,
            amount: bill.amount,
            currency: bill.currency,
            paymentDate: bill.paymentDate,
            dueDate: bill.dueDate,
            icon: bill.icon,
            customImageData: bill.customImageData,
            isActive: bill.isActive,
            isYearlyPayment: bill.isYearlyPayment,
            yearlyPaymentDate: bill.yearlyPaymentDate,
            category: bill.category,
            hasNotification: bill.hasNotification,
            notificationDaysBefore: bill.notificationDaysBefore,
            notificationTime: bill.notificationTime,
            userId: currentUserId
        )
        bills.append(billToAdd)
        // Notification will be scheduled automatically in didSet
    }
    
    func updateBill(_ bill: Bill) {
        if let index = bills.firstIndex(where: { $0.id == bill.id }) {
            // Cancel old notification
            NotificationManager.shared.cancelNotification(for: bills[index])
            // Always associate the bill with the current user
            let billToUpdate = Bill(
                id: bill.id,
                name: bill.name,
                amount: bill.amount,
                currency: bill.currency,
                paymentDate: bill.paymentDate,
                dueDate: bill.dueDate,
                icon: bill.icon,
                customImageData: bill.customImageData,
                isActive: bill.isActive,
                isYearlyPayment: bill.isYearlyPayment,
                yearlyPaymentDate: bill.yearlyPaymentDate,
                category: bill.category,
                hasNotification: bill.hasNotification,
                notificationDaysBefore: bill.notificationDaysBefore,
                notificationTime: bill.notificationTime,
                userId: currentUserId
            )
            // Update the bill
            bills[index] = billToUpdate
            // New notification will be scheduled automatically in didSet
        }
    }
    
    func deleteBill(_ bill: Bill) {
        // Cancel notification before deleting
        NotificationManager.shared.cancelNotification(for: bill)
        // Remove from array
        bills.removeAll { $0.id == bill.id }
        // Notifications will be rescheduled automatically in didSet
    }
    
    func deleteBill(at index: Int) {
        guard index < bills.count else { return }
        let bill = bills[index]
        deleteBill(bill)
    }
}
