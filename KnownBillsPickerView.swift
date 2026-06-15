//
//  KnownBillsPickerView.swift
//  BillTracker
//
//  Created for selecting from predefined bills.
//

import SwiftUI

struct KnownBill: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let category: String
    let suggestedAmount: Double?
    let suggestedCurrency: String
}

struct KnownBillsPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedBill: KnownBill?
    @State private var searchText = ""
    @EnvironmentObject var languageManager: LanguageManager
    
    private func localizedCategory(_ category: String) -> String {
        switch category {
        case "Entertainment":
            return languageManager.localized("entertainment")
        case "Software":
            return languageManager.localized("software")
        case "Fitness":
            return languageManager.localized("fitness")
        case "Healthcare":
            return languageManager.localized("healthcare")
        case "Utilities":
            return languageManager.localized("utilities")
        case "Transportation":
            return languageManager.localized("transportation")
        case "Finance":
            return languageManager.localized("finance")
        case "Food":
            return languageManager.localized("food")
        case "Personal Care":
            return languageManager.localized("personal_care")
        case "Family":
            return languageManager.localized("family")
        default:
            return category
        }
    }
    
    private func getIconColor(for bill: KnownBill) -> Color {
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
    
    private let knownBills: [KnownBill] = [
        // Entertainment & Streaming
        KnownBill(name: "Netflix", icon: "tv", category: "Entertainment", suggestedAmount: 15.99, suggestedCurrency: "USD"),
        KnownBill(name: "Spotify", icon: "music.note", category: "Entertainment", suggestedAmount: 9.99, suggestedCurrency: "USD"),
        KnownBill(name: "Apple One", icon: "applelogo", category: "Entertainment", suggestedAmount: 16.95, suggestedCurrency: "USD"),
        KnownBill(name: "Amazon Prime", icon: "cart", category: "Entertainment", suggestedAmount: 119.00, suggestedCurrency: "USD"),
        KnownBill(name: "Disney+", icon: "play.rectangle", category: "Entertainment", suggestedAmount: 7.99, suggestedCurrency: "USD"),
        KnownBill(name: "Hulu", icon: "play.circle", category: "Entertainment", suggestedAmount: 6.99, suggestedCurrency: "USD"),
        KnownBill(name: "YouTube Premium", icon: "play.rectangle.fill", category: "Entertainment", suggestedAmount: 11.99, suggestedCurrency: "USD"),
        
        // Software & Productivity
        KnownBill(name: "Adobe Creative Cloud", icon: "paintbrush", category: "Software", suggestedAmount: 52.99, suggestedCurrency: "USD"),
        KnownBill(name: "Microsoft 365", icon: "doc.text", category: "Software", suggestedAmount: 6.99, suggestedCurrency: "USD"),
        KnownBill(name: "Google Workspace", icon: "globe", category: "Software", suggestedAmount: 6.00, suggestedCurrency: "USD"),
        KnownBill(name: "Dropbox", icon: "icloud", category: "Software", suggestedAmount: 9.99, suggestedCurrency: "USD"),
        KnownBill(name: "Notion", icon: "note.text", category: "Software", suggestedAmount: 8.00, suggestedCurrency: "USD"),
        KnownBill(name: "JetBrains", icon: "hammer", category: "Software", suggestedAmount: 8.90, suggestedCurrency: "USD"),
        KnownBill(name: "Canva Pro", icon: "paintpalette", category: "Software", suggestedAmount: 12.99, suggestedCurrency: "USD"),
        KnownBill(name: "Apple Developer", icon: "applelogo", category: "Software", suggestedAmount: 99.00, suggestedCurrency: "USD"),
        KnownBill(name: "ChatGPT Plus", icon: "brain.head.profile", category: "Software", suggestedAmount: 20.00, suggestedCurrency: "USD"),
        KnownBill(name: "Claude Pro", icon: "person.crop.circle", category: "Software", suggestedAmount: 20.00, suggestedCurrency: "USD"),
        KnownBill(name: "Figma", icon: "rectangle.3.group", category: "Software", suggestedAmount: 12.00, suggestedCurrency: "USD"),
        KnownBill(name: "Sketch", icon: "pencil.and.outline", category: "Software", suggestedAmount: 9.00, suggestedCurrency: "USD"),
        KnownBill(name: "Slack", icon: "message", category: "Software", suggestedAmount: 6.67, suggestedCurrency: "USD"),
        KnownBill(name: "Zoom Pro", icon: "video", category: "Software", suggestedAmount: 14.99, suggestedCurrency: "USD"),
        KnownBill(name: "GitHub", icon: "chevron.left.forwardslash.chevron.right", category: "Software", suggestedAmount: 4.00, suggestedCurrency: "USD"),
        KnownBill(name: "Bitbucket", icon: "bitcoinsign.circle", category: "Software", suggestedAmount: 3.00, suggestedCurrency: "USD"),
        KnownBill(name: "Jira", icon: "list.bullet.clipboard", category: "Software", suggestedAmount: 7.50, suggestedCurrency: "USD"),
        KnownBill(name: "Confluence", icon: "doc.plaintext", category: "Software", suggestedAmount: 5.50, suggestedCurrency: "USD"),
        KnownBill(name: "Trello", icon: "rectangle.grid.2x2", category: "Software", suggestedAmount: 5.00, suggestedCurrency: "USD"),
        KnownBill(name: "Asana", icon: "checkmark.circle", category: "Software", suggestedAmount: 10.99, suggestedCurrency: "USD"),
        KnownBill(name: "Monday.com", icon: "calendar", category: "Software", suggestedAmount: 8.00, suggestedCurrency: "USD"),
        KnownBill(name: "Airtable", icon: "tablecells", category: "Software", suggestedAmount: 10.00, suggestedCurrency: "USD"),
        KnownBill(name: "LastPass", icon: "key", category: "Software", suggestedAmount: 3.00, suggestedCurrency: "USD"),
        KnownBill(name: "1Password", icon: "lock.shield", category: "Software", suggestedAmount: 2.99, suggestedCurrency: "USD"),
        KnownBill(name: "Dashlane", icon: "shield.lefthalf.filled", category: "Software", suggestedAmount: 3.33, suggestedCurrency: "USD"),
        KnownBill(name: "Grammarly", icon: "textformat", category: "Software", suggestedAmount: 12.00, suggestedCurrency: "USD"),
        KnownBill(name: "Hemingway Editor", icon: "pencil", category: "Software", suggestedAmount: 19.99, suggestedCurrency: "USD"),
        KnownBill(name: "Evernote", icon: "note", category: "Software", suggestedAmount: 7.99, suggestedCurrency: "USD"),
        KnownBill(name: "Bear", icon: "bear", category: "Software", suggestedAmount: 1.49, suggestedCurrency: "USD"),
        KnownBill(name: "Todoist", icon: "checklist", category: "Software", suggestedAmount: 4.00, suggestedCurrency: "USD"),
        KnownBill(name: "Things 3", icon: "checkmark.square", category: "Software", suggestedAmount: 9.99, suggestedCurrency: "USD"),
        KnownBill(name: "OmniFocus", icon: "target", category: "Software", suggestedAmount: 9.99, suggestedCurrency: "USD"),
        KnownBill(name: "Fantastical", icon: "calendar.badge.clock", category: "Software", suggestedAmount: 4.99, suggestedCurrency: "USD"),
        KnownBill(name: "Calendly", icon: "calendar.badge.plus", category: "Software", suggestedAmount: 8.00, suggestedCurrency: "USD"),
        KnownBill(name: "Acuity Scheduling", icon: "clock", category: "Software", suggestedAmount: 14.00, suggestedCurrency: "USD"),
        KnownBill(name: "Buffer", icon: "square.and.arrow.up", category: "Software", suggestedAmount: 6.00, suggestedCurrency: "USD"),
        KnownBill(name: "Hootsuite", icon: "bird", category: "Software", suggestedAmount: 49.00, suggestedCurrency: "USD"),
        KnownBill(name: "Mailchimp", icon: "envelope", category: "Software", suggestedAmount: 10.00, suggestedCurrency: "USD"),
        KnownBill(name: "ConvertKit", icon: "arrow.triangle.branch", category: "Software", suggestedAmount: 29.00, suggestedCurrency: "USD"),
        KnownBill(name: "HubSpot", icon: "hub", category: "Software", suggestedAmount: 45.00, suggestedCurrency: "USD"),
        KnownBill(name: "Salesforce", icon: "person.2", category: "Software", suggestedAmount: 25.00, suggestedCurrency: "USD"),
        KnownBill(name: "Zendesk", icon: "questionmark.circle", category: "Software", suggestedAmount: 19.00, suggestedCurrency: "USD"),
        KnownBill(name: "Intercom", icon: "bubble.left.and.bubble.right", category: "Software", suggestedAmount: 39.00, suggestedCurrency: "USD"),
        KnownBill(name: "Freshworks", icon: "sparkles", category: "Software", suggestedAmount: 15.00, suggestedCurrency: "USD"),
        KnownBill(name: "Typeform", icon: "doc.text.magnifyingglass", category: "Software", suggestedAmount: 25.00, suggestedCurrency: "USD"),
        KnownBill(name: "SurveyMonkey", icon: "chart.bar.doc.horizontal", category: "Software", suggestedAmount: 25.00, suggestedCurrency: "USD"),
        KnownBill(name: "Google Analytics", icon: "chart.line.uptrend.xyaxis", category: "Software", suggestedAmount: 0.00, suggestedCurrency: "USD"),
        KnownBill(name: "Mixpanel", icon: "chart.bar.xaxis", category: "Software", suggestedAmount: 25.00, suggestedCurrency: "USD"),
        KnownBill(name: "Amplitude", icon: "waveform", category: "Software", suggestedAmount: 61.00, suggestedCurrency: "USD"),
        KnownBill(name: "Hotjar", icon: "eye.circle", category: "Software", suggestedAmount: 32.00, suggestedCurrency: "USD"),
        KnownBill(name: "FullStory", icon: "play.rectangle", category: "Software", suggestedAmount: 0.00, suggestedCurrency: "USD"),
        KnownBill(name: "LogRocket", icon: "rocket", category: "Software", suggestedAmount: 99.00, suggestedCurrency: "USD"),
        KnownBill(name: "Sentry", icon: "exclamationmark.triangle", category: "Software", suggestedAmount: 26.00, suggestedCurrency: "USD"),
        KnownBill(name: "Bugsnag", icon: "ant", category: "Software", suggestedAmount: 29.00, suggestedCurrency: "USD"),
        KnownBill(name: "Rollbar", icon: "exclamationmark.octagon", category: "Software", suggestedAmount: 12.00, suggestedCurrency: "USD"),
        KnownBill(name: "New Relic", icon: "chart.line.uptrend.xyaxis.circle", category: "Software", suggestedAmount: 99.00, suggestedCurrency: "USD"),
        KnownBill(name: "DataDog", icon: "chart.bar.fill", category: "Software", suggestedAmount: 15.00, suggestedCurrency: "USD"),
        KnownBill(name: "Splunk", icon: "magnifyingglass", category: "Software", suggestedAmount: 150.00, suggestedCurrency: "USD"),
        KnownBill(name: "Elastic", icon: "waveform.path.ecg", category: "Software", suggestedAmount: 95.00, suggestedCurrency: "USD"),
        KnownBill(name: "Cloudflare", icon: "cloud", category: "Software", suggestedAmount: 20.00, suggestedCurrency: "USD"),
        KnownBill(name: "AWS", icon: "server.rack", category: "Software", suggestedAmount: 0.00, suggestedCurrency: "USD"),
        KnownBill(name: "Google Cloud", icon: "cloud.fill", category: "Software", suggestedAmount: 0.00, suggestedCurrency: "USD"),
        KnownBill(name: "Azure", icon: "cloud.rain", category: "Software", suggestedAmount: 0.00, suggestedCurrency: "USD"),
        KnownBill(name: "Vercel", icon: "bolt", category: "Software", suggestedAmount: 20.00, suggestedCurrency: "USD"),
        KnownBill(name: "Netlify", icon: "network", category: "Software", suggestedAmount: 19.00, suggestedCurrency: "USD"),
        KnownBill(name: "Heroku", icon: "server.rack", category: "Software", suggestedAmount: 7.00, suggestedCurrency: "USD"),
        KnownBill(name: "DigitalOcean", icon: "drop", category: "Software", suggestedAmount: 5.00, suggestedCurrency: "USD"),
        KnownBill(name: "Linode", icon: "server.rack", category: "Software", suggestedAmount: 5.00, suggestedCurrency: "USD"),
        KnownBill(name: "Vultr", icon: "server.rack", category: "Software", suggestedAmount: 2.50, suggestedCurrency: "USD"),
        
        // Health & Fitness
        KnownBill(name: "Gym Membership", icon: "figure.run", category: "Fitness", suggestedAmount: 45.00, suggestedCurrency: "USD"),
        KnownBill(name: "Peloton", icon: "bicycle", category: "Fitness", suggestedAmount: 39.00, suggestedCurrency: "USD"),
        KnownBill(name: "Health Insurance", icon: "cross.case", category: "Healthcare", suggestedAmount: 300.00, suggestedCurrency: "USD"),
        KnownBill(name: "Dental Insurance", icon: "mouth", category: "Healthcare", suggestedAmount: 50.00, suggestedCurrency: "USD"),
        KnownBill(name: "Vision Insurance", icon: "eye", category: "Healthcare", suggestedAmount: 25.00, suggestedCurrency: "USD"),
        
        // Utilities & Services
        KnownBill(name: "Internet", icon: "wifi", category: "Utilities", suggestedAmount: 79.99, suggestedCurrency: "USD"),
        KnownBill(name: "Electricity", icon: "bolt", category: "Utilities", suggestedAmount: 120.50, suggestedCurrency: "USD"),
        KnownBill(name: "Phone Bill", icon: "phone", category: "Utilities", suggestedAmount: 85.00, suggestedCurrency: "USD"),
        KnownBill(name: "Water", icon: "drop", category: "Utilities", suggestedAmount: 60.00, suggestedCurrency: "USD"),
        KnownBill(name: "Gas", icon: "flame", category: "Utilities", suggestedAmount: 80.00, suggestedCurrency: "USD"),
        KnownBill(name: "Trash Collection", icon: "trash", category: "Utilities", suggestedAmount: 25.00, suggestedCurrency: "USD"),
        
        // Transportation
        KnownBill(name: "Car Insurance", icon: "car", category: "Transportation", suggestedAmount: 120.00, suggestedCurrency: "USD"),
        KnownBill(name: "Car Payment", icon: "car.fill", category: "Transportation", suggestedAmount: 350.00, suggestedCurrency: "USD"),
        KnownBill(name: "Gas", icon: "fuelpump", category: "Transportation", suggestedAmount: 200.00, suggestedCurrency: "USD"),
        KnownBill(name: "Public Transport", icon: "bus", category: "Transportation", suggestedAmount: 80.00, suggestedCurrency: "USD"),
        KnownBill(name: "Uber/Lyft", icon: "car.2", category: "Transportation", suggestedAmount: 100.00, suggestedCurrency: "USD"),
        
        // Finance & Banking
        KnownBill(name: "Credit Card", icon: "creditcard", category: "Finance", suggestedAmount: 150.00, suggestedCurrency: "USD"),
        KnownBill(name: "Student Loan", icon: "graduationcap", category: "Finance", suggestedAmount: 300.00, suggestedCurrency: "USD"),
        KnownBill(name: "Mortgage", icon: "house", category: "Finance", suggestedAmount: 1500.00, suggestedCurrency: "USD"),
        KnownBill(name: "Rent", icon: "house.fill", category: "Finance", suggestedAmount: 1200.00, suggestedCurrency: "USD"),
        KnownBill(name: "Bank Fee", icon: "banknote", category: "Finance", suggestedAmount: 12.00, suggestedCurrency: "USD"),
        
        // Food & Dining
        KnownBill(name: "Groceries", icon: "cart.fill", category: "Food", suggestedAmount: 400.00, suggestedCurrency: "USD"),
        KnownBill(name: "Restaurants", icon: "fork.knife", category: "Food", suggestedAmount: 200.00, suggestedCurrency: "USD"),
        KnownBill(name: "Coffee", icon: "cup.and.saucer", category: "Food", suggestedAmount: 50.00, suggestedCurrency: "USD"),
        KnownBill(name: "Food Delivery", icon: "takeoutbag.and.cup.and.straw", category: "Food", suggestedAmount: 100.00, suggestedCurrency: "USD"),
        
        // Other Services
        KnownBill(name: "Haircut", icon: "scissors", category: "Personal Care", suggestedAmount: 30.00, suggestedCurrency: "USD"),
        KnownBill(name: "Laundry", icon: "washer", category: "Personal Care", suggestedAmount: 20.00, suggestedCurrency: "USD"),
        KnownBill(name: "Cleaning Service", icon: "sparkles", category: "Personal Care", suggestedAmount: 150.00, suggestedCurrency: "USD"),
        KnownBill(name: "Pet Care", icon: "pawprint", category: "Personal Care", suggestedAmount: 80.00, suggestedCurrency: "USD"),
        KnownBill(name: "Childcare", icon: "figure.and.child.holdinghands", category: "Family", suggestedAmount: 800.00, suggestedCurrency: "USD")
    ]
    
    private var filteredBills: [KnownBill] {
        if searchText.isEmpty {
            return knownBills
        } else {
            return knownBills.filter { bill in
                bill.name.localizedCaseInsensitiveContains(searchText) ||
                bill.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredBills) { bill in
                    Button(action: {
                        selectedBill = bill
                        dismiss()
                    }) {
                        HStack(spacing: 12) {
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(getIconColor(for: bill).opacity(0.15))
                                    .frame(width: 40, height: 40)
                                
                                Image(systemName: bill.icon)
                                    .font(.title3)
                                    .foregroundColor(getIconColor(for: bill))
                            }
                            
                            // Bill Info
                            VStack(alignment: .leading, spacing: 2) {
                                Text(bill.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                
                                Text(localizedCategory(bill.category))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Suggested Amount
                            if let amount = bill.suggestedAmount {
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("~$\(String(format: "%.2f", amount))")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                    
                                    Text(languageManager.localized("suggested"))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle(languageManager.localized("select_bill"))
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: languageManager.localized("search_bills_or_categories"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.localized("cancel")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    KnownBillsPickerView(selectedBill: .constant(nil))
}
