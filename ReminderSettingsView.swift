import SwiftUI
import UserNotifications

struct ReminderSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var reminderType: ReminderType = .single
    @State private var singleReminderDate = Calendar.current.date(byAdding: .day, value: 10, to: Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()) ?? Date()
    @State private var multipleReminderInterval = 90
    @State private var multipleReminderTime = Calendar.current.date(from: DateComponents(hour: 20, minute: 0)) ?? Date()
    @State private var isReminderEnabled = false
    
    // UserDefaults keys
    private let reminderEnabledKey = "ReminderEnabled"
    private let reminderTypeKey = "ReminderType"
    private let singleReminderDateKey = "SingleReminderDate"
    private let multipleReminderIntervalKey = "MultipleReminderInterval"
    private let multipleReminderTimeKey = "MultipleReminderTime"
    
    enum ReminderType {
        case single
        case multiple
    }
    
    private let intervalOptions = [1, 7, 30, 90, 180, 365]
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Enable Reminders", isOn: $isReminderEnabled)
                }
                
                if isReminderEnabled {
                    Section {
                        HStack {
                            Button(action: {
                                reminderType = .single
                            }) {
                                HStack {
                                    Image(systemName: reminderType == .single ? "checkmark.square.fill" : "square")
                                        .foregroundColor(reminderType == .single ? .appRed : .gray)
                                    Text("Single Reminder")
                                        .foregroundColor(reminderType == .single ? .primary : .secondary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                        
                        HStack {
                            Button(action: {
                                reminderType = .multiple
                            }) {
                                HStack {
                                    Image(systemName: reminderType == .multiple ? "checkmark.square.fill" : "square")
                                        .foregroundColor(reminderType == .multiple ? .appRed : .gray)
                                    Text("Multiple Reminders")
                                        .foregroundColor(reminderType == .multiple ? .primary : .secondary)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                        }
                    }
                    
                    if reminderType == .single {
                        Section("Single Reminder") {
                            DatePicker("Date & Time", selection: $singleReminderDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                    } else {
                        Section("Multiple Reminders") {
                            Picker("Interval", selection: $multipleReminderInterval) {
                                ForEach(intervalOptions, id: \.self) { days in
                                    Text(intervalLabel(for: days))
                                        .tag(days)
                                }
                            }
                            
                            DatePicker("Time of reminder", selection: $multipleReminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(CompactDatePickerStyle())
                        }
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reminder Summary")
                                .font(.headline)
                            
                            if reminderType == .single {
                                Text("You will receive a reminder on \(singleReminderDate, formatter: dateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("You will receive reminders every \(intervalLabel(for: multipleReminderInterval)) at \(multipleReminderTime, formatter: timeFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Reminder Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadReminderSettings()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveReminderSettings()
                        scheduleNotifications()
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy HH:mm"
        return formatter
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
    
    private func intervalLabel(for days: Int) -> String {
        switch days {
        case 1:
            return "1 day"
        case 7:
            return "7 days"
        case 30:
            return "30 days"
        case 90:
            return "3 months"
        case 180:
            return "6 months"
        case 365:
            return "12 months"
        default:
            return "\(days) days"
        }
    }
    
    private func saveReminderSettings() {
        UserDefaults.standard.set(isReminderEnabled, forKey: reminderEnabledKey)
        UserDefaults.standard.set(reminderType == .single ? "single" : "multiple", forKey: reminderTypeKey)
        UserDefaults.standard.set(singleReminderDate, forKey: singleReminderDateKey)
        UserDefaults.standard.set(multipleReminderInterval, forKey: multipleReminderIntervalKey)
        UserDefaults.standard.set(multipleReminderTime, forKey: multipleReminderTimeKey)
        
        // If reminders are disabled, cancel all notifications
        if !isReminderEnabled {
            cancelAllNotifications()
        }
    }
    
    private func loadReminderSettings() {
        isReminderEnabled = UserDefaults.standard.bool(forKey: reminderEnabledKey)
        
        let savedType = UserDefaults.standard.string(forKey: reminderTypeKey) ?? "single"
        reminderType = savedType == "single" ? .single : .multiple
        
        if let savedSingleDate = UserDefaults.standard.object(forKey: singleReminderDateKey) as? Date {
            singleReminderDate = savedSingleDate
        }
        
        let savedInterval = UserDefaults.standard.integer(forKey: multipleReminderIntervalKey)
        if savedInterval > 0 {
            multipleReminderInterval = savedInterval
        }
        
        if let savedMultipleTime = UserDefaults.standard.object(forKey: multipleReminderTimeKey) as? Date {
            multipleReminderTime = savedMultipleTime
        }
    }
    
    private func scheduleNotifications() {
        // Cancel existing notifications first
        cancelAllNotifications()
        
        guard isReminderEnabled else { return }
        
        if reminderType == .single {
            scheduleSingleReminder()
        } else {
            scheduleMultipleReminders()
        }
    }
    
    private func scheduleSingleReminder() {
        let content = UNMutableNotificationContent()
        content.title = "BillTracker Reminder"
        content.body = "Don't forget to check your bills!"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: singleReminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "BillTrackerSingleReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling single reminder: \(error)")
            } else {
                print("Single reminder scheduled for \(self.singleReminderDate)")
            }
        }
    }
    
    private func scheduleMultipleReminders() {
        let content = UNMutableNotificationContent()
        content.title = "BillTracker Reminder"
        content.body = "Time to check your bills!"
        content.sound = .default
        
        // Get the time components from the selected time
        let timeComponents = Calendar.current.dateComponents([.hour, .minute], from: multipleReminderTime)
        
        // Calculate the next occurrence based on the interval
        let calendar = Calendar.current
        let now = Date()
        
        // Create the next reminder date
        var nextReminderDate = calendar.date(bySettingHour: timeComponents.hour ?? 20, minute: timeComponents.minute ?? 0, second: 0, of: now) ?? now
        
        // If the time has already passed today, schedule for tomorrow
        if nextReminderDate <= now {
            nextReminderDate = calendar.date(byAdding: .day, value: 1, to: nextReminderDate) ?? now
        }
        
        // For multiple reminders, we need to schedule multiple individual notifications
        // Schedule the next 10 reminders to ensure coverage
        for i in 0..<10 {
            let reminderDate = calendar.date(byAdding: .day, value: i * multipleReminderInterval, to: nextReminderDate) ?? now
            
            let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            let request = UNNotificationRequest(identifier: "BillTrackerMultipleReminder_\(i)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling multiple reminder \(i): \(error)")
                } else {
                    print("Multiple reminder \(i) scheduled for \(reminderDate)")
                }
            }
        }
    }
    
    private func cancelAllNotifications() {
        // Cancel single reminder
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["BillTrackerSingleReminder"])
        
        // Cancel all multiple reminders (0-9)
        let multipleReminderIds = (0..<10).map { "BillTrackerMultipleReminder_\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: multipleReminderIds)
    }
}

#Preview {
    ReminderSettingsView()
}
