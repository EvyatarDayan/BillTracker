//
//  AddIncomeView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var incomeManager: IncomeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var incomeAmount: String = ""
    @State private var originalIncomeAmount: Double = 0.0
    @FocusState private var isIncomeFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(languageManager.localized("monthly_income"))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    Text(languageManager.localized("add_monthly_income_to_view_bill_share"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                Spacer()
                
                // Income Input
                HStack(alignment: .center, spacing: 8) {
                    Spacer()
                        .frame(width: 72)
                    
                    TextField("0", text: $incomeAmount)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                        .keyboardType(.numberPad)
                        .textFieldStyle(PlainTextFieldStyle())
                        .multilineTextAlignment(.center)
                        .focused($isIncomeFieldFocused)
                        .frame(maxWidth: .infinity)
                        .onTapGesture(count: 1) {
                            if !incomeAmount.isEmpty {
                                incomeAmount = ""
                            }
                            isIncomeFieldFocused = true
                        }
                        .highPriorityGesture(
                            TapGesture(count: 1)
                                .onEnded { _ in
                                    if !incomeAmount.isEmpty {
                                        incomeAmount = ""
                                    }
                                    isIncomeFieldFocused = true
                                }
                        )
                    
                    HStack(spacing: 6) {
                        Text(currencyManager.flagForCurrency(currencyManager.defaultCurrency))
                            .font(.body)
                        Text(currencyManager.defaultCurrency)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.secondary)
                    .frame(width: 72, alignment: .trailing)
                }
                .padding()
                .background(incomeInputBackground)
                .cornerRadius(12)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: saveIncome) {
                        Text(incomeManager.hasIncomeSet() ? languageManager.localized("update_income") : languageManager.localized("add_income"))
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.appRed)
                            .cornerRadius(12)
                    }
                    
                    if incomeManager.hasIncomeSet() {
                        Button(action: {
                            incomeManager.setMonthlyIncome(0.0)
                            dismiss()
                        }) {
                            Text(languageManager.localized("remove_income"))
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
            .background(themeManager.isDarkMode ? Color(.systemGroupedBackground) : Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.localized("cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)

        .onAppear {
            if incomeManager.hasIncomeSet() {
                originalIncomeAmount = incomeManager.monthlyIncome
                incomeAmount = formatIncomeDisplay(incomeManager.monthlyIncome)
            }
        }
    }
    
    private func formatIncomeDisplay(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.groupingSeparator = ","
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: amount)) ?? "\(Int(amount))"
    }
    
    private func parseIncomeAmount(_ text: String) -> Double? {
        let cleaned = text
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\u{00A0}", with: "")
        guard !cleaned.isEmpty, let value = Double(cleaned) else { return nil }
        return value
    }
    
    private func saveIncome() {
        let parsedAmount = parseIncomeAmount(incomeAmount)
        
        // If the field is empty or contains 0, remove the income
        if incomeAmount.isEmpty || parsedAmount == 0 {
            incomeManager.setMonthlyIncome(0.0)
            dismiss()
            return
        }
        
        // Check if the amount was actually changed
        if incomeManager.hasIncomeSet() {
            let newAmount = parsedAmount ?? 0
            
            // If no change was made, just close the modal
            if abs(originalIncomeAmount - newAmount) < 0.01 {
                dismiss()
                return
            }
        }
        
        // Otherwise, update with the new amount
        guard let amount = parsedAmount, amount > 0 else {
            return
        }
        
        incomeManager.setMonthlyIncome(amount)
        dismiss()
    }
    
    private var incomeInputBackground: Color {
        themeManager.isDarkMode ? Color(.systemGray5) : Color(.systemGray6)
    }
}

#Preview {
    AddIncomeView()
        .environmentObject(IncomeManager())
        .environmentObject(CurrencyManager())
        .environmentObject(ThemeManager())
}
