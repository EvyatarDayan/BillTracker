//
//  NotificationManager.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    // Request notification permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    // Schedule notification for a bill
    func scheduleNotification(for bill: Bill) {
        guard bill.hasNotification else { return }
        
        // Calculate notification date
        let calendar = Calendar.current
        let now = Date()
        
        // Get the next occurrence of the bill's payment date
        let currentMonth = calendar.component(.month, from: now)
        let currentYear = calendar.component(.year, from: now)
        
        var notificationDate: Date
        
        if bill.isYearlyPayment {
            // For yearly bills, use the yearlyPaymentDate
            if let yearlyPaymentDate = bill.yearlyPaymentDate {
                // Get the month and day from the yearly payment date
                let paymentMonth = calendar.component(.month, from: yearlyPaymentDate)
                let paymentDay = calendar.component(.day, from: yearlyPaymentDate)
                
                var components = DateComponents()
                components.year = currentYear
                components.month = paymentMonth
                components.day = paymentDay
                
                if let yearlyDate = calendar.date(from: components) {
                    if yearlyDate > now {
                        // This year's date hasn't passed yet
                        notificationDate = yearlyDate
                    } else {
                        // This year's date has passed, use next year
                        components.year = currentYear + 1
                        notificationDate = calendar.date(from: components) ?? yearlyDate
                    }
                } else {
                    // Fallback to current date
                    notificationDate = now
                }
            } else {
                // Fallback to current date if no yearly payment date is set
                notificationDate = now
            }
        } else {
            // For monthly bills, get the next occurrence this month or next month
            var components = DateComponents()
            components.year = currentYear
            components.month = currentMonth
            components.day = bill.paymentDate
            
            if let monthlyDate = calendar.date(from: components) {
                if monthlyDate > now {
                    // This month's date hasn't passed yet
                    notificationDate = monthlyDate
                } else {
                    // This month's date has passed, use next month
                    if currentMonth == 12 {
                        components.year = currentYear + 1
                        components.month = 1
                    } else {
                        components.month = currentMonth + 1
                    }
                    notificationDate = calendar.date(from: components) ?? monthlyDate
                }
            } else {
                // Fallback to current date
                notificationDate = now
            }
        }
        
        // Subtract the notification days
        notificationDate = calendar.date(byAdding: .day, value: -bill.notificationDaysBefore, to: notificationDate) ?? notificationDate
        
        // Set the notification time from the bill's notification time
        let notificationTimeComponents = calendar.dateComponents([.hour, .minute], from: bill.notificationTime)
        notificationDate = calendar.date(bySettingHour: notificationTimeComponents.hour ?? 19, 
                                       minute: notificationTimeComponents.minute ?? 0, 
                                       second: 0, 
                                       of: notificationDate) ?? notificationDate
        
        // Only schedule if the notification date is in the future
        guard notificationDate > now else {
            print("Notification date is in the past, skipping: \(notificationDate)")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Bill Reminder"
        content.body = "\(bill.name) is due in \(bill.notificationDaysBefore) day\(bill.notificationDaysBefore == 1 ? "" : "s")"
        content.sound = .default
        content.badge = 1
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate),
            repeats: false
        )
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "bill_\(bill.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled for \(bill.name) at \(notificationDate)")
            }
        }
    }
    
    // Cancel notification for a bill
    func cancelNotification(for bill: Bill) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["bill_\(bill.id.uuidString)"])
        print("Cancelled notification for \(bill.name)")
    }
    
    // Cancel all notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Cancelled all notifications")
    }
    
    // Reschedule all notifications for bills
    func rescheduleAllNotifications(for bills: [Bill]) {
        // Cancel all existing notifications
        cancelAllNotifications()
        
        // Schedule new notifications for all bills
        for bill in bills {
            scheduleNotification(for: bill)
        }
    }
    
    // Get pending notifications (for debugging)
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
}
