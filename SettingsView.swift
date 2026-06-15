//
//  SettingsView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI
import PDFKit

struct BottomRoundedRectangle: Shape {
    let cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cornerRadius))
        path.addQuadCurve(to: CGPoint(x: rect.maxX - cornerRadius, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + cornerRadius, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY - cornerRadius), control: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

struct SettingsView: View {
    @EnvironmentObject var billManager: BillManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingCurrencyPicker = false
    @State private var showingLanguagePicker = false
    @State private var showingExportAlert = false
    @State private var exportAlertMessage = ""
    @State private var showingClearDataAlert = false
    @State private var showingHelpSupport = false
    @State private var showingTermsPrivacy = false
    @State private var showingAbout = false
    @State private var showingEditProfileSheet = false
    @State private var showingLoginSheet = false
    
    
    var body: some View {
                NavigationStack {
            Form {
                // Add padding below the navigation title
                Section {
                    EmptyView()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // Authentication Section
                Section(languageManager.localized("authentication")) {
                    if userManager.isLoggedIn {
                        Button(action: {
                            showingEditProfileSheet = true
                        }) {
                            HStack(spacing: 12) {
                                // Icon
                                ZStack {
                                    Circle()
                                        .fill(Color.appRed.opacity(0.1))
                                        .frame(width: 30, height: 30)
                                    
                                    if let profileImage = userManager.getProfileImage() {
                                        Image(uiImage: profileImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                    } else if let avatarName = userManager.getAvatarName() {
                                        Image(avatarName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 30, height: 30)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.caption)
                                            .foregroundColor(.appRed)
                                    }
                                }
                                
                                // Title and Subtitle
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(userManager.currentUser?.fullName ?? "")
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(userManager.currentUser?.email ?? "")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        Button(action: {
                            showingLoginSheet = true
                        }) {
                            HStack(spacing: 12) {
                                // Icon
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundColor(.appRed)
                                    .frame(width: 30)
                                
                                // Title and Subtitle
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(languageManager.localized("sign_in_to_your_account"))
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Text(languageManager.localized("access_your_data_across_devices"))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                        .truncationMode(.tail)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                // Preferences Section
                Section(languageManager.localized("preferences")) {
                    Button(action: {
                        showingCurrencyPicker = true
                    }) {
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("currency"))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("currency_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text(currencyManager.flagForCurrency(currencyManager.defaultCurrency))
                                    .font(.title2)
                                
                                Text(currencyManager.defaultCurrency)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showingLanguagePicker = true
                    }) {
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "globe")
                                .font(.title2)
                                .foregroundColor(.appRed)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("language"))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("language_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Text(languageManager.currentLanguage.flag)
                                    .font(.title2)
                                
                                Text(languageManager.currentLanguage.displayName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    HStack(spacing: 12) {
                        // Icon
                        Image(systemName: "moon.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                            .frame(width: 30)
                        
                        // Title and Subtitle
                        VStack(alignment: .leading, spacing: 2) {
                            Text(languageManager.localized("dark_mode"))
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text(languageManager.localized("dark_mode_subtitle"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $themeManager.isDarkMode)
                    }
                }
                
                // Support Section
                Section(languageManager.localized("support")) {
                    Button(action: {
                        showingHelpSupport = true
                    }) {
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "questionmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.appRed)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("help_support"))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("help_support_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showingTermsPrivacy = true
                    }) {
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "lock.shield.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("terms_privacy"))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("terms_privacy_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundColor(.appRed)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("about"))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("about_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Data Management Section
                Section("Data Management") {
                    Button(action: {
                        exportDataToPDF()
                    }) {
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "square.and.arrow.up.fill")
                                .font(.title2)
                                .foregroundColor(.appRed)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("export_data"))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("export_data_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: {
                        showingClearDataAlert = true
                    }) {
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "trash.fill")
                                .font(.title2)
                                .foregroundColor(.red)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("clear_all_data"))
                                    .font(.body)
                                    .foregroundColor(.red)
                                
                                Text(languageManager.localized("clear_data_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Bottom padding section
                Section {
                    Text("")
                        .frame(height: 30)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                
            } // Close Form
            .navigationTitle(languageManager.localized("settings"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if userManager.isLoggedIn {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            userManager.logoutUser()
                        }) {
                            Text(languageManager.localized("logout"))
                                .foregroundColor(.red)
                                .padding(.horizontal, 10)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingCurrencyPicker) {
                CurrencyPickerView(selectedCurrency: $currencyManager.defaultCurrency)
                    .environmentObject(themeManager)
            }
            .sheet(isPresented: $showingLanguagePicker) {
                LanguagePickerView(languageManager: languageManager)
                    .environmentObject(themeManager)
            }
            .sheet(isPresented: $showingHelpSupport) {
                HelpSupportView()
                    .environmentObject(userManager)
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingTermsPrivacy) {
                TermsPrivacyView()
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingEditProfileSheet) {
                EditProfileView(userManager: userManager)
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingLoginSheet) {
                LoginView(userManager: userManager)
                    .environmentObject(languageManager)
            }
            .alert("Export Data", isPresented: $showingExportAlert) {
                Button("OK") { }
            } message: {
                Text(exportAlertMessage)
            }
            .alert("Clear All Data", isPresented: $showingClearDataAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("This will permanently delete all your bills. This action cannot be undone.")
            }
        }
    }
    
    private func exportDataToPDF() {
        // Get bills from the current BillManager to ensure we export the correct user's data
        let bills = billManager.bills
        guard !bills.isEmpty else {
            exportAlertMessage = languageManager.localized("no_bills_to_export")
            showingExportAlert = true
            return
        }
        
        // Debug: Print all bills to console
        print("Total bills: \(bills.count)")
        for bill in bills {
            print("Bill: \(bill.name), Category: \(bill.category), Amount: \(bill.amount), IsActive: \(bill.isActive), IsYearly: \(bill.isYearlyPayment)")
        }
        
        // Create PDF context
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // Standard US Letter size
        let pdfData = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        let context = UIGraphicsGetCurrentContext()
        
        // Calculate category spending for pie chart
        let activeBills = bills.filter { $0.isActive }.sorted { $0.paymentDate < $1.paymentDate }
        print("Active bills count: \(activeBills.count)")
        
        let totalMonthlyAmount = activeBills.reduce(0) { total, bill in
            let monthlyAmount = bill.isYearlyPayment ? bill.amount / 12 : bill.amount
            return total + monthlyAmount
        }
        
        var categoryTotals: [String: Double] = [:]
        for bill in activeBills {
            let monthlyAmount = bill.isYearlyPayment ? bill.amount / 12 : bill.amount
            let currentTotal = categoryTotals[bill.category, default: 0]
            categoryTotals[bill.category] = currentTotal + monthlyAmount
            print("Adding \(bill.category): \(monthlyAmount) (running total: \(categoryTotals[bill.category]!))")
        }
        
        let categoryItems = categoryTotals.map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
        
        // Debug: Print category data to console
        print("Final category breakdown:")
        for item in categoryItems {
            let percentage = totalMonthlyAmount > 0 ? (item.amount / totalMonthlyAmount) * 100 : 0
            print("\(item.category): \(item.amount) (\(percentage)%)")
        }
        
        // Start with first page
        var currentPage = 0
        var currentY: CGFloat = 50
        let maxY: CGFloat = pageRect.height - 50
        
        func startNewPage() {
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            currentPage += 1
            currentY = 50
            context?.setFillColor(UIColor.white.cgColor)
            context?.fill(pageRect)
        }
        
        // First page - Title and Summary
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
        context?.setFillColor(UIColor.white.cgColor)
        context?.fill(pageRect)
        
        // Title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]
        let titleString = languageManager.localized("billtracker_report")
        let titleSize = titleString.size(withAttributes: titleAttributes)
        let titleRect = CGRect(x: 50, y: currentY, width: titleSize.width, height: titleSize.height)
        titleString.draw(in: titleRect, withAttributes: titleAttributes)
        currentY += titleSize.height + 20
        
        // Summary section
        let summaryAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        
        let activeBillsCount = activeBills.count
        let summary1 = "\(languageManager.localized("total_monthly_bills_label")) \(currencyManager.formatAmount(totalMonthlyAmount))"
        let summary2 = "\(languageManager.localized("number_of_bills_label")) \(activeBillsCount)"
        
        let summary1Size = summary1.size(withAttributes: summaryAttributes)
        let summary2Size = summary2.size(withAttributes: summaryAttributes)
        
        let summary1Rect = CGRect(x: 50, y: currentY, width: summary1Size.width, height: summary1Size.height)
        let summary2Rect = CGRect(x: 50, y: currentY + 20, width: summary2Size.width, height: summary2Size.height)
        
        summary1.draw(in: summary1Rect, withAttributes: summaryAttributes)
        summary2.draw(in: summary2Rect, withAttributes: summaryAttributes)
        currentY += 50
        
        // Table headers
        let headerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor.white
        ]
        
        let cellAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        // Check if we need a new page for the bills table
        let tableHeight = CGFloat(activeBills.count + 1) * 30 + 40
        if currentY + tableHeight > maxY {
            startNewPage()
        }
        
        // Bills Table
        var tableStartY = currentY
        let rowHeight: CGFloat = 30
        let columnWidths: [CGFloat] = [250, 100, 100]
        let columnX: [CGFloat] = [50, 300, 400]
        
        // Draw table headers with blue background
        let headers = [languageManager.localized("bill_name"), languageManager.localized("due_date"), languageManager.localized("amount")]
        for (index, header) in headers.enumerated() {
            let headerRect = CGRect(x: columnX[index], y: tableStartY, width: columnWidths[index], height: rowHeight)
            context?.setFillColor(UIColor.appRed.cgColor)
            context?.fill(headerRect)
            
            let headerString = header
            let headerSize = headerString.size(withAttributes: headerAttributes)
            let headerTextRect = CGRect(x: columnX[index] + 5, y: tableStartY + (rowHeight - headerSize.height) / 2, width: columnWidths[index] - 10, height: headerSize.height)
            headerString.draw(in: headerTextRect, withAttributes: headerAttributes)
        }
        
        // Draw vertical dividers for headers
        for i in 1..<columnX.count {
            let dividerX = columnX[i]
            let dividerRect = CGRect(x: dividerX, y: tableStartY, width: 1, height: rowHeight)
            context?.setFillColor(UIColor.white.cgColor)
            context?.fill(dividerRect)
        }
        
        // Draw table data with alternating colors and vertical dividers
        for (index, bill) in activeBills.enumerated() {
            let rowY = tableStartY + rowHeight + CGFloat(index) * rowHeight
            
            // Check if we need a new page
            if rowY + rowHeight > maxY {
                startNewPage()
                // Redraw headers on new page
                for (headerIndex, header) in headers.enumerated() {
                    let headerRect = CGRect(x: columnX[headerIndex], y: currentY, width: columnWidths[headerIndex], height: rowHeight)
                    context?.setFillColor(UIColor.appRed.cgColor)
                    context?.fill(headerRect)
                    
                    let headerString = header
                    let headerSize = headerString.size(withAttributes: headerAttributes)
                    let headerTextRect = CGRect(x: columnX[headerIndex] + 5, y: currentY + (rowHeight - headerSize.height) / 2, width: columnWidths[headerIndex] - 10, height: headerSize.height)
                    headerString.draw(in: headerTextRect, withAttributes: headerAttributes)
                }
                
                // Draw vertical dividers for headers on new page
                for i in 1..<columnX.count {
                    let dividerX = columnX[i]
                    let dividerRect = CGRect(x: dividerX, y: currentY, width: 1, height: rowHeight)
                    context?.setFillColor(UIColor.white.cgColor)
                    context?.fill(dividerRect)
                }
                
                currentY += rowHeight
                tableStartY = currentY - rowHeight
            }
            
            let actualRowY = tableStartY + rowHeight + CGFloat(index) * rowHeight
            
            // Draw row background with alternating colors
            let rowRect = CGRect(x: 50, y: actualRowY, width: 450, height: rowHeight)
            let rowColor = index % 2 == 0 ? UIColor.white : UIColor.systemGray6
            context?.setFillColor(rowColor.cgColor)
            context?.fill(rowRect)
            
            // Draw borders
            context?.setStrokeColor(UIColor.systemGray4.cgColor)
            context?.setLineWidth(0.5)
            context?.stroke(rowRect)
            
            // Draw vertical dividers for data rows
            for i in 1..<columnX.count {
                let dividerX = columnX[i]
                let dividerRect = CGRect(x: dividerX, y: actualRowY, width: 1, height: rowHeight)
                context?.setFillColor(UIColor.systemGray4.cgColor)
                context?.fill(dividerRect)
            }
            
            // Bill Name
            let nameRect = CGRect(x: columnX[0] + 5, y: actualRowY + (rowHeight - 20) / 2, width: columnWidths[0] - 10, height: 20)
            bill.name.draw(in: nameRect, withAttributes: cellAttributes)
            
            // Due Date
            let dateString = "\(bill.paymentDate)\(ordinalSuffix(for: bill.paymentDate))"
            let dateRect = CGRect(x: columnX[1] + 5, y: actualRowY + (rowHeight - 20) / 2, width: columnWidths[1] - 10, height: 20)
            dateString.draw(in: dateRect, withAttributes: cellAttributes)
            
            // Amount
            let amountString = currencyManager.formatAmount(bill.isYearlyPayment ? bill.amount / 12 : bill.amount)
            let amountRect = CGRect(x: columnX[2] + 5, y: actualRowY + (rowHeight - 20) / 2, width: columnWidths[2] - 10, height: 20)
            amountString.draw(in: amountRect, withAttributes: cellAttributes)
        }
        
        currentY = tableStartY + rowHeight + CGFloat(activeBills.count) * rowHeight + 40
        
        // Check if we need a new page for category breakdown
        let categorySectionHeight = CGFloat(categoryItems.count + 1) * 25 + 100 + 250 // Table + pie chart (increased size)
        if currentY + categorySectionHeight > maxY {
            startNewPage()
        }
        
        // Category Breakdown Section
        let categoryTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        let categoryTitleString = languageManager.localized("category_breakdown")
        let categoryTitleSize = categoryTitleString.size(withAttributes: categoryTitleAttributes)
        let categoryTitleRect = CGRect(x: 50, y: currentY, width: categoryTitleSize.width, height: categoryTitleSize.height)
        categoryTitleString.draw(in: categoryTitleRect, withAttributes: categoryTitleAttributes)
        currentY += categoryTitleSize.height + 20
        
        // Draw pie chart
        let pieChartSize: CGFloat = 250
        let pieChartX: CGFloat = 50
        let pieChartY = currentY
        
        drawPieChart(context: context, categoryItems: categoryItems, totalAmount: totalMonthlyAmount, 
                    rect: CGRect(x: pieChartX, y: pieChartY, width: pieChartSize, height: pieChartSize))
        
        currentY += pieChartSize + 20
        
        // Category table headers
        let categoryHeaderAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.white
        ]
        
        // Category table headers
        var categoryTableStartY = currentY
        let categoryRowHeight: CGFloat = 25
        let categoryColumnWidths: [CGFloat] = [200, 100, 100]
        let categoryColumnX: [CGFloat] = [50, 250, 350]
        
        // Draw category table headers with blue background
        let categoryHeaders = [languageManager.localized("category"), languageManager.localized("amount"), languageManager.localized("percentage")]
        for (index, header) in categoryHeaders.enumerated() {
            let headerRect = CGRect(x: categoryColumnX[index], y: categoryTableStartY, width: categoryColumnWidths[index], height: categoryRowHeight)
            context?.setFillColor(UIColor.appRed.cgColor)
            context?.fill(headerRect)
            
            let headerString = header
            let headerSize = headerString.size(withAttributes: categoryHeaderAttributes)
            let headerTextRect = CGRect(x: categoryColumnX[index] + 5, y: categoryTableStartY + (categoryRowHeight - headerSize.height) / 2, width: categoryColumnWidths[index] - 10, height: headerSize.height)
            headerString.draw(in: headerTextRect, withAttributes: categoryHeaderAttributes)
        }
        
        // Draw vertical dividers for category headers
        for i in 1..<categoryColumnX.count {
            let dividerX = categoryColumnX[i]
            let dividerRect = CGRect(x: dividerX, y: categoryTableStartY, width: 1, height: categoryRowHeight)
            context?.setFillColor(UIColor.white.cgColor)
            context?.fill(dividerRect)
        }
        
        // Draw category table data
        for (index, item) in categoryItems.enumerated() {
            let rowY = categoryTableStartY + categoryRowHeight + CGFloat(index) * categoryRowHeight
            
            // Check if we need a new page
            if rowY + categoryRowHeight > maxY {
                startNewPage()
                // Redraw category headers on new page
                for (headerIndex, header) in categoryHeaders.enumerated() {
                    let headerRect = CGRect(x: categoryColumnX[headerIndex], y: currentY, width: categoryColumnWidths[headerIndex], height: categoryRowHeight)
                    context?.setFillColor(UIColor.appRed.cgColor)
                    context?.fill(headerRect)
                    
                    let headerString = header
                    let headerSize = headerString.size(withAttributes: categoryHeaderAttributes)
                    let headerTextRect = CGRect(x: categoryColumnX[headerIndex] + 5, y: currentY + (categoryRowHeight - headerSize.height) / 2, width: categoryColumnWidths[headerIndex] - 10, height: headerSize.height)
                    headerString.draw(in: headerTextRect, withAttributes: categoryHeaderAttributes)
                }
                
                // Draw vertical dividers for category headers on new page
                for i in 1..<categoryColumnX.count {
                    let dividerX = categoryColumnX[i]
                    let dividerRect = CGRect(x: dividerX, y: currentY, width: 1, height: categoryRowHeight)
                    context?.setFillColor(UIColor.white.cgColor)
                    context?.fill(dividerRect)
                }
                
                currentY += categoryRowHeight
                categoryTableStartY = currentY - categoryRowHeight
            }
            
            let actualRowY = categoryTableStartY + categoryRowHeight + CGFloat(index) * categoryRowHeight
            
            // Draw row background with alternating colors
            let rowRect = CGRect(x: 50, y: actualRowY, width: 400, height: categoryRowHeight)
            let rowColor = index % 2 == 0 ? UIColor.white : UIColor.systemGray6
            context?.setFillColor(rowColor.cgColor)
            context?.fill(rowRect)
            
            // Draw borders
            context?.setStrokeColor(UIColor.systemGray4.cgColor)
            context?.setLineWidth(0.5)
            context?.stroke(rowRect)
            
            // Draw vertical dividers for data rows
            for i in 1..<categoryColumnX.count {
                let dividerX = categoryColumnX[i]
                let dividerRect = CGRect(x: dividerX, y: actualRowY, width: 1, height: categoryRowHeight)
                context?.setFillColor(UIColor.systemGray4.cgColor)
                context?.fill(dividerRect)
            }
            
            // Category Name with color matching the pie chart
            let categoryRect = CGRect(x: categoryColumnX[0] + 5, y: actualRowY + (categoryRowHeight - 18) / 2, width: categoryColumnWidths[0] - 10, height: 18)
            let colors: [UIColor] = [
                .systemBlue, .systemGreen, .systemOrange, .systemRed, .systemPurple,
                .systemTeal, .systemIndigo, .systemPink, .systemYellow, .systemBrown
            ]
            let categoryColor = colors[index % colors.count]
            let coloredCategoryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: categoryColor
            ]
            localizedCategory(item.category).draw(in: categoryRect, withAttributes: coloredCategoryAttributes)
            
            // Amount
            let amountString = currencyManager.formatAmount(item.amount)
            let amountRect = CGRect(x: categoryColumnX[1] + 5, y: actualRowY + (categoryRowHeight - 18) / 2, width: categoryColumnWidths[1] - 10, height: 18)
            amountString.draw(in: amountRect, withAttributes: cellAttributes)
            
            // Percentage
            let percentage = totalMonthlyAmount > 0 ? (item.amount / totalMonthlyAmount) * 100 : 0
            let percentageString = String(format: "%.1f%%", percentage)
            let percentageRect = CGRect(x: categoryColumnX[2] + 5, y: actualRowY + (categoryRowHeight - 18) / 2, width: categoryColumnWidths[2] - 10, height: 18)
            percentageString.draw(in: percentageRect, withAttributes: cellAttributes)
        }
        
        // End PDF context
        UIGraphicsEndPDFContext()
        
        // Save PDF to a temporary location first
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // Create timestamp for the file
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "ddMMyyyy"
        let timestamp = dateFormatter.string(from: Date())
        let finalPDFName = "BillTracker_\(timestamp).pdf"
        
        let tempPDFURL = documentsPath.appendingPathComponent(finalPDFName)
        
        do {
            try pdfData.write(to: tempPDFURL)
            
            // Share PDF with Files app as primary option
            let activityVC = UIActivityViewController(activityItems: [tempPDFURL], applicationActivities: nil)
            
            // Ensure Files app is available
            activityVC.excludedActivityTypes = [
                .assignToContact,
                .addToReadingList,
                .openInIBooks,
                .markupAsPDF,
                .postToFacebook,
                .postToTwitter,
                .postToWeibo,
                .postToVimeo,
                .postToTencentWeibo,
                .postToFlickr
            ]
            
            // Set completion handler to clean up temp file
            activityVC.completionWithItemsHandler = { _, completed, _, _ in
                if completed {
                    // Clean up temporary file
                    try? FileManager.default.removeItem(at: tempPDFURL)
                }
            }
            
            // Debug: Print available activities
            print("PDF export completed, share sheet should appear")
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                
                // Configure for iPad popover presentation
                if UIDevice.current.userInterfaceIdiom == .pad {
                    activityVC.modalPresentationStyle = .popover
                    if let popover = activityVC.popoverPresentationController {
                        popover.sourceView = rootViewController.view
                        popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX, y: rootViewController.view.bounds.midY, width: 0, height: 0)
                        popover.permittedArrowDirections = []
                    }
                }
                
                rootViewController.present(activityVC, animated: true)
            }
            
            // Don't show alert - let the share sheet handle everything
            // exportAlertMessage = "PDF ready to save. Look for 'Files' or 'Save to Files' in the share sheet."
            // showingExportAlert = true
            
        } catch {
            exportAlertMessage = "Failed to generate PDF: \(error.localizedDescription)"
            showingExportAlert = true
        }
    }
    
    // MARK: - Pie Chart Drawing Function
    
    private func drawPieChart(context: CGContext?, categoryItems: [(category: String, amount: Double)], totalAmount: Double, rect: CGRect) {
        guard let context = context, !categoryItems.isEmpty else { return }
        
        let centerX = rect.midX
        let centerY = rect.midY
        let radius = min(rect.width, rect.height) / 2 - 10
        
        // Define colors for pie slices
        let colors: [UIColor] = [
            .systemBlue, .systemGreen, .systemOrange, .systemRed, .systemPurple,
            .systemTeal, .systemIndigo, .systemPink, .systemYellow, .systemBrown
        ]
        
        var currentAngle: CGFloat = -CGFloat.pi / 2 // Start from top
        
        for (index, item) in categoryItems.enumerated() {
            let sliceAngle = CGFloat((item.amount / totalAmount) * 2 * CGFloat.pi)
            let color = colors[index % colors.count]
            
            // Draw pie slice
            context.setFillColor(color.cgColor)
            context.move(to: CGPoint(x: centerX, y: centerY))
            context.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: currentAngle, endAngle: currentAngle + sliceAngle, clockwise: false)
            context.closePath()
            context.fillPath()
            
            // Draw slice border
            context.setStrokeColor(UIColor.white.cgColor)
            context.setLineWidth(1.0)
            context.move(to: CGPoint(x: centerX, y: centerY))
            context.addArc(center: CGPoint(x: centerX, y: centerY), radius: radius, startAngle: currentAngle, endAngle: currentAngle + sliceAngle, clockwise: false)
            context.closePath()
            context.strokePath()
            
            currentAngle += sliceAngle
        }
        
        // Draw center circle for donut effect
        let centerRadius: CGFloat = radius * 0.3
        context.setFillColor(UIColor.white.cgColor)
        context.addEllipse(in: CGRect(x: centerX - centerRadius, y: centerY - centerRadius, width: centerRadius * 2, height: centerRadius * 2))
        context.fillPath()
        
        // Remove legend since we have colored category names in the table below
        // This prevents overlap with the category breakdown table
    }
    
    private func clearAllData() {
        // Clear bills from UserDefaults
        UserDefaults.standard.removeObject(forKey: "SavedBills")
        UserDefaults.standard.removeObject(forKey: "GuestBills")
        
        // Clear all notifications
        NotificationManager.shared.cancelAllNotifications()
        
        // Clear bills from the shared BillManager
        billManager.bills = []
        
        // Show confirmation
        exportAlertMessage = "All bills have been cleared"
        showingExportAlert = true
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

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userManager: UserManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var firstName: String
    @State private var lastName: String
    @State private var email: String
    @State private var profileImage: UIImage?
    @State private var selectedAvatar: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showingPasswordUpdate = false
    @State private var showingDeleteAccountAlert = false
    
    init(userManager: UserManager) {
        self.userManager = userManager
        self._firstName = State(initialValue: userManager.currentUser?.firstName ?? "")
        self._lastName = State(initialValue: userManager.currentUser?.lastName ?? "")
        self._email = State(initialValue: userManager.currentUser?.email ?? "")
        
        self._profileImage = State(initialValue: userManager.getProfileImage())
        self._selectedAvatar = State(initialValue: userManager.getAvatarName())
    }
    
    var body: some View {
        NavigationView {
            List {
                // Header Section
                Section {
                    VStack(spacing: 16) {
                        // Avatar Section
                        ProfileImageSelector(selectedImage: $profileImage, selectedAvatar: $selectedAvatar)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                }
                
                // Form Section
                Section {
                    // First Name and Last Name - Side by Side
                    HStack(spacing: 0) {
                        TextField(languageManager.localized("first_name"), text: $firstName)
                        
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(width: 1, height: 20)
                        
                        TextField(languageManager.localized("last_name"), text: $lastName)
                            .padding(.leading, 8)
                    }
                    
                    // Email Field
                    HStack {
                        Text(email)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } header: {
                    Text(languageManager.localized("personal_information"))
                } footer: {
                    Text(languageManager.localized("email_cannot_be_updated"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Password Section
                Section(languageManager.localized("security")) {
                    Button(action: {
                        showingPasswordUpdate = true
                    }) {
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "lock.fill")
                                .font(.title2)
                                .foregroundColor(.appRed)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("update_password"))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("update_password_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Update Button Section
                Section {
                    Button(action: {
                        saveProfile()
                    }) {
                        Text(languageManager.localized("update"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.appRed : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                }
                .listRowBackground(Color.clear)
                
                // Delete Account Section
                Section {
                    Button(action: {
                        showingDeleteAccountAlert = true
                    }) {
                        Text(languageManager.localized("delete_account"))
                            .foregroundColor(.red)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle(languageManager.localized("edit_profile"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.localized("cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        userManager.logoutUser()
                        dismiss()
                    }) {
                        Text(languageManager.localized("logout"))
                            .foregroundColor(.red)
                    }
                }
            }
            .alert(languageManager.localized("profile_update"), isPresented: $showingAlert) {
                Button(languageManager.localized("ok")) { }
            } message: {
                Text(alertMessage)
            }
            .alert(languageManager.localized("delete_account"), isPresented: $showingDeleteAccountAlert) {
                Button(languageManager.localized("cancel"), role: .cancel) { }
                Button(languageManager.localized("delete"), role: .destructive) {
                    deleteAccount()
                }
            } message: {
                Text(languageManager.localized("delete_account_confirmation"))
            }
            .sheet(isPresented: $showingPasswordUpdate) {
                UpdatePasswordView(userManager: userManager)
                    .environmentObject(languageManager)
            }
        }
    }
    
    private var isFormValid: Bool {
        return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty
    }
    
    private func saveProfile() {
        // Validate email format
        if !userManager.isEmailValid(email) {
            alertMessage = languageManager.localized("please_enter_valid_email")
            showingAlert = true
            return
        }
        
        // Debug information
        print("Saving profile with:")
        print("- First Name: \(firstName)")
        print("- Last Name: \(lastName)")
        print("- Profile Image: \(profileImage != nil ? "Set" : "Not set")")
        print("- Avatar Name: \(selectedAvatar ?? "Not set")")
        
        // Update user profile
        let success = userManager.updateUserProfile(
            firstName: firstName, 
            lastName: lastName, 
            profileImage: profileImage, 
            avatarName: selectedAvatar,
            phoneNumber: nil,
            countryCode: nil
        )
        
        if success {
            print("Profile saved successfully")
            dismiss()
        } else {
            print("Failed to save profile")
            alertMessage = languageManager.localized("failed_to_update_profile")
            showingAlert = true
        }
    }
    
    private func deleteAccount() {
        userManager.deleteProfile()
        dismiss()
    }
}

struct UpdatePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userManager: UserManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isCurrentPasswordVisible = false
    @State private var isNewPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(languageManager.localized("update_password"))
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(languageManager.localized("enter_your_current_password_and_choose_new_one"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowBackground(Color.clear)
                
                Section(languageManager.localized("password_information")) {
                    // Current Password
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.appRed)
                            .frame(width: 20)
                        
                        if isCurrentPasswordVisible {
                            TextField(languageManager.localized("current_password"), text: $currentPassword)
                        } else {
                            SecureField(languageManager.localized("current_password"), text: $currentPassword)
                        }
                        
                        Button(action: {
                            isCurrentPasswordVisible.toggle()
                        }) {
                            Image(systemName: isCurrentPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // New Password
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.green)
                            .frame(width: 20)
                        
                        if isNewPasswordVisible {
                            TextField(languageManager.localized("new_password"), text: $newPassword)
                        } else {
                            SecureField(languageManager.localized("new_password"), text: $newPassword)
                        }
                        
                        Button(action: {
                            isNewPasswordVisible.toggle()
                        }) {
                            Image(systemName: isNewPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Confirm Password
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.orange)
                            .frame(width: 20)
                        
                        if isConfirmPasswordVisible {
                            TextField(languageManager.localized("reenter_new_password"), text: $confirmPassword)
                        } else {
                            SecureField(languageManager.localized("reenter_new_password"), text: $confirmPassword)
                        }
                        
                        Button(action: {
                            isConfirmPasswordVisible.toggle()
                        }) {
                            Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Password Requirements
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(languageManager.localized("password_requirements"))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Text(languageManager.localized("at_least_6_characters_long"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(languageManager.localized("new_password_must_be_different_from_current"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listRowBackground(Color.clear)
                
                // Update Button
                Section {
                    Button(action: {
                        updatePassword()
                    }) {
                        Text(languageManager.localized("update_password"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? Color.appRed : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isFormValid)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.localized("cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localized("update")) {
                        updatePassword()
                    }
                    .disabled(!isFormValid)
                }
            }
            .alert(languageManager.localized("password_update"), isPresented: $showingAlert) {
                Button(languageManager.localized("ok")) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        return !currentPassword.isEmpty && 
               !newPassword.isEmpty && 
               !confirmPassword.isEmpty &&
               newPassword == confirmPassword &&
               newPassword != currentPassword &&
               userManager.isPasswordValid(newPassword)
    }
    
    private func updatePassword() {
        // Validate passwords match
        guard newPassword == confirmPassword else {
            alertMessage = languageManager.localized("new_passwords_do_not_match")
            showingAlert = true
            return
        }
        
        // Validate new password is different from current
        guard newPassword != currentPassword else {
            alertMessage = languageManager.localized("new_password_must_be_different_from_current_password")
            showingAlert = true
            return
        }
        
        // Validate new password strength
        guard userManager.isPasswordValid(newPassword) else {
            alertMessage = languageManager.localized("new_password_must_be_at_least_6_characters_long")
            showingAlert = true
            return
        }
        
        // Update password
        let success = userManager.updatePassword(currentPassword: currentPassword, newPassword: newPassword)
        
        if success {
            alertMessage = languageManager.localized("password_updated_successfully")
            showingAlert = true
            
            // Clear form
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
            
            // Dismiss after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                dismiss()
            }
        } else {
            alertMessage = languageManager.localized("incorrect_current_password")
            showingAlert = true
        }
    }
}

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var userManager: UserManager
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var reenterPassword = ""
    @State private var isSignUp = false
    @State private var profileImage: UIImage?
    @State private var selectedAvatar: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showPassword = false
    @State private var showReenterPassword = false
    
    var body: some View {
        NavigationStack {
            List {
                // Tab Selection at Top
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        // Sign In Tab
                        Button(action: {
                            withAnimation {
                                // Clear form when switching
                                firstName = ""
                                lastName = ""
                                email = ""
                                password = ""
                                reenterPassword = ""
                                profileImage = nil
                                selectedAvatar = nil
                                showPassword = false
                                showReenterPassword = false
                                // Update state
                                isSignUp = false
                            }
                        }) {
                            Text(languageManager.localized("sign_in"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(isSignUp ? .secondary : .primary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isSignUp ? Color.clear : Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Sign Up Tab
                        Button(action: {
                            withAnimation {
                                // Clear form when switching
                                firstName = ""
                                lastName = ""
                                email = ""
                                password = ""
                                reenterPassword = ""
                                profileImage = nil
                                selectedAvatar = nil
                                showPassword = false
                                showReenterPassword = false
                                // Update state
                                isSignUp = true
                            }
                        }) {
                            Text(languageManager.localized("sign_up"))
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(isSignUp ? .primary : .secondary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(isSignUp ? Color(.systemGray6) : Color.clear)
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                }
                .padding(.vertical, 16)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // Header Section
                Group {
                    if isSignUp {
                        // Sign up header - no section wrapper
                        VStack(spacing: 16) {
                            Text(languageManager.localized("create_account"))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                            
                            Text(languageManager.localized("sign_up_to_sync_your_bills"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .id("signup-header")
                        
                        // Profile image section
                        Section {
                            ProfileImageSelector(selectedImage: $profileImage, selectedAvatar: $selectedAvatar)
                        }
                        .id("signup-profile")
                    } else {
                        // Login header - no section wrapper, no profile image
                        VStack(spacing: 16) {
                            Text(languageManager.localized("welcome_back"))
                                .font(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                            
                            Text(languageManager.localized("login_to_access_your_account"))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.bottom, 8)
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                        .id("signin-header")
                    }
                }
                
                // Form Section
                Section(isSignUp ? languageManager.localized("account_information") : languageManager.localized("login_information")) {
                    if isSignUp {
                        HStack(spacing: 12) {
                            TextField(languageManager.localized("first_name"), text: $firstName)
                            
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(width: 1, height: 20)
                            
                            TextField(languageManager.localized("last_name"), text: $lastName)
                        }
                        .id("name-fields")
                    }
                    
                    TextField(languageManager.localized("email"), text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    HStack {
                        if showPassword {
                            TextField(languageManager.localized("password"), text: $password)
                        } else {
                            SecureField(languageManager.localized("password"), text: $password)
                        }
                        
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye.slash" : "eye")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if isSignUp {
                        HStack {
                            if showReenterPassword {
                                TextField(languageManager.localized("reenter_password"), text: $reenterPassword)
                            } else {
                                SecureField(languageManager.localized("reenter_password"), text: $reenterPassword)
                            }
                            
                            Button(action: {
                                showReenterPassword.toggle()
                            }) {
                                Image(systemName: showReenterPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .id("reenter-password-field")
                    }
                }
                .id(isSignUp ? "signup-form" : "signin-form")
                
                // Action Buttons Section
                Button(action: {
                    handleAuthentication()
                }) {
                    Text(isSignUp ? languageManager.localized("sign_up") : languageManager.localized("sign_in"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isFormValid ? Color.appRed : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!isFormValid)
                .listRowBackground(Color.clear)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(languageManager.localized("cancel")) {
                        dismiss()
                    }
                }
            }
            .alert(languageManager.localized("authentication"), isPresented: $showingAlert) {
                Button(languageManager.localized("ok")) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !firstName.isEmpty && !lastName.isEmpty && !email.isEmpty && !password.isEmpty && !reenterPassword.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func handleAuthentication() {
        if isSignUp {
            // Validate email format
            if !userManager.isEmailValid(email) {
                alertMessage = languageManager.localized("please_enter_valid_email")
                showingAlert = true
                return
            }
            
            // Validate password match
            if password != reenterPassword {
                alertMessage = languageManager.localized("passwords_do_not_match")
                showingAlert = true
                return
            }
            
            // Validate password length
            if !userManager.isPasswordValid(password) {
                alertMessage = languageManager.localized("password_must_be_at_least_6_characters")
                showingAlert = true
                return
            }
            
            // Check if user already exists
            if userManager.isUserExists(email) {
                alertMessage = languageManager.localized("account_with_email_already_exists")
                showingAlert = true
                return
            }
            
            // Register user
            let success = userManager.registerUser(firstName: firstName, lastName: lastName, email: email, password: password, profileImage: profileImage, avatarName: selectedAvatar)
            
            if success {
                dismiss()
            } else {
                alertMessage = languageManager.localized("failed_to_create_account")
                showingAlert = true
            }
        } else {
            // Login user
            let success = userManager.loginUser(email: email, password: password)
            
            if success {
                dismiss()
            } else {
                alertMessage = languageManager.localized("invalid_email_or_password")
                showingAlert = true
            }
        }
    }
}

struct AvatarPicker: View {
    @Binding var selectedAvatar: String?
    @Environment(\.dismiss) private var dismiss
    
    // Avatar names matching the actual asset names in Avatar.xcassets
    private let avatarNames = ["avatar1", "avatar2", "avatar3", "avatar4", "avatar5", "avatar6", "avatar7", "avatar8", "avatar9", "avatar10"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 3), spacing: 16) {
                    ForEach(avatarNames, id: \.self) { avatarName in
                        Button(action: {
                            print("Selected avatar: \(avatarName)") // Debug print
                            selectedAvatar = avatarName
                            dismiss()
                        }) {
                            VStack {
                                Image(avatarName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(selectedAvatar == avatarName ? Color.appRed : Color.clear, lineWidth: 3)
                                    )
                                
                                Text(avatarName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileImageSelector: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedAvatar: String?
    @State private var showingImagePicker = false
    @State private var showingAvatarPicker = false
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        HStack(spacing: 16) {
            // Current selection display
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else if let selectedAvatar = selectedAvatar {
                Image(selectedAvatar)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.appRed.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.appRed)
                    )
            }
            
            Spacer()
            
            // Selection buttons
            HStack(spacing: 12) {
                Button(languageManager.localized("library")) {
                    showingImagePicker = true
                }
                .buttonStyle(.bordered)
                .foregroundColor(.appRed)
                
                Button(languageManager.localized("avatar")) {
                    showingAvatarPicker = true
                }
                .buttonStyle(.bordered)
                .foregroundColor(.appRed)
            }
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .sheet(isPresented: $showingAvatarPicker) {
            AvatarPicker(selectedAvatar: $selectedAvatar)
        }
        .onChange(of: selectedImage) { newImage in
            if newImage != nil {
                selectedAvatar = nil // Clear avatar when photo is selected
            }
        }
        .onChange(of: selectedAvatar) { newAvatar in
            if newAvatar != nil {
                selectedImage = nil // Clear photo when avatar is selected
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(UserManager())
        .environmentObject(ThemeManager())
}
