//
//  IncomeManager.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import Foundation
import SwiftUI

class IncomeManager: ObservableObject {
    @Published var monthlyIncome: Double = 0.0
    
    private let incomeKey = "UserMonthlyIncome"
    
    init() {
        loadIncome()
    }
    
    func setMonthlyIncome(_ income: Double) {
        monthlyIncome = income
        saveIncome()
    }
    
    func calculateBillsPercentage(totalBills: Double) -> Double {
        guard monthlyIncome > 0 else { return 0.0 }
        return (totalBills / monthlyIncome) * 100.0
    }
    
    func getBillsPercentageText(totalBills: Double) -> String {
        let percentage = calculateBillsPercentage(totalBills: totalBills)
        return String(format: "%.1f", percentage)
    }
    
    private func saveIncome() {
        UserDefaults.standard.set(monthlyIncome, forKey: incomeKey)
    }
    
    private func loadIncome() {
        monthlyIncome = UserDefaults.standard.double(forKey: incomeKey)
    }
    
    func hasIncomeSet() -> Bool {
        return monthlyIncome > 0
    }
}

