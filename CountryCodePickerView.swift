//
//  CountryCodePickerView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

struct CountryCode: Identifiable, Codable {
    let id = UUID()
    let name: String
    let code: String
    let flag: String
    let phoneCode: String
    
    var displayText: String {
        "\(flag) \(name) (\(phoneCode))"
    }
}

struct CountryCodePickerView: View {
    @Binding var selectedCountry: CountryCode?
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss
    
    private let countries: [CountryCode] = [
        CountryCode(name: "United States", code: "US", flag: "🇺🇸", phoneCode: "+1"),
        CountryCode(name: "United Kingdom", code: "GB", flag: "🇬🇧", phoneCode: "+44"),
        CountryCode(name: "Canada", code: "CA", flag: "🇨🇦", phoneCode: "+1"),
        CountryCode(name: "Australia", code: "AU", flag: "🇦🇺", phoneCode: "+61"),
        CountryCode(name: "Germany", code: "DE", flag: "🇩🇪", phoneCode: "+49"),
        CountryCode(name: "France", code: "FR", flag: "🇫🇷", phoneCode: "+33"),
        CountryCode(name: "Italy", code: "IT", flag: "🇮🇹", phoneCode: "+39"),
        CountryCode(name: "Spain", code: "ES", flag: "🇪🇸", phoneCode: "+34"),
        CountryCode(name: "Netherlands", code: "NL", flag: "🇳🇱", phoneCode: "+31"),
        CountryCode(name: "Sweden", code: "SE", flag: "🇸🇪", phoneCode: "+46"),
        CountryCode(name: "Norway", code: "NO", flag: "🇳🇴", phoneCode: "+47"),
        CountryCode(name: "Denmark", code: "DK", flag: "🇩🇰", phoneCode: "+45"),
        CountryCode(name: "Finland", code: "FI", flag: "🇫🇮", phoneCode: "+358"),
        CountryCode(name: "Switzerland", code: "CH", flag: "🇨🇭", phoneCode: "+41"),
        CountryCode(name: "Austria", code: "AT", flag: "🇦🇹", phoneCode: "+43"),
        CountryCode(name: "Belgium", code: "BE", flag: "🇧🇪", phoneCode: "+32"),
        CountryCode(name: "Poland", code: "PL", flag: "🇵🇱", phoneCode: "+48"),
        CountryCode(name: "Czech Republic", code: "CZ", flag: "🇨🇿", phoneCode: "+420"),
        CountryCode(name: "Hungary", code: "HU", flag: "🇭🇺", phoneCode: "+36"),
        CountryCode(name: "Portugal", code: "PT", flag: "🇵🇹", phoneCode: "+351"),
        CountryCode(name: "Greece", code: "GR", flag: "🇬🇷", phoneCode: "+30"),
        CountryCode(name: "Ireland", code: "IE", flag: "🇮🇪", phoneCode: "+353"),
        CountryCode(name: "Luxembourg", code: "LU", flag: "🇱🇺", phoneCode: "+352"),
        CountryCode(name: "Iceland", code: "IS", flag: "🇮🇸", phoneCode: "+354"),
        CountryCode(name: "Japan", code: "JP", flag: "🇯🇵", phoneCode: "+81"),
        CountryCode(name: "South Korea", code: "KR", flag: "🇰🇷", phoneCode: "+82"),
        CountryCode(name: "China", code: "CN", flag: "🇨🇳", phoneCode: "+86"),
        CountryCode(name: "India", code: "IN", flag: "🇮🇳", phoneCode: "+91"),
        CountryCode(name: "Brazil", code: "BR", flag: "🇧🇷", phoneCode: "+55"),
        CountryCode(name: "Mexico", code: "MX", flag: "🇲🇽", phoneCode: "+52"),
        CountryCode(name: "Argentina", code: "AR", flag: "🇦🇷", phoneCode: "+54"),
        CountryCode(name: "Chile", code: "CL", flag: "🇨🇱", phoneCode: "+56"),
        CountryCode(name: "Colombia", code: "CO", flag: "🇨🇴", phoneCode: "+57"),
        CountryCode(name: "Peru", code: "PE", flag: "🇵🇪", phoneCode: "+51"),
        CountryCode(name: "Venezuela", code: "VE", flag: "🇻🇪", phoneCode: "+58"),
        CountryCode(name: "South Africa", code: "ZA", flag: "🇿🇦", phoneCode: "+27"),
        CountryCode(name: "Egypt", code: "EG", flag: "🇪🇬", phoneCode: "+20"),
        CountryCode(name: "Nigeria", code: "NG", flag: "🇳🇬", phoneCode: "+234"),
        CountryCode(name: "Kenya", code: "KE", flag: "🇰🇪", phoneCode: "+254"),
        CountryCode(name: "Morocco", code: "MA", flag: "🇲🇦", phoneCode: "+212"),
        CountryCode(name: "Israel", code: "IL", flag: "🇮🇱", phoneCode: "+972"),
        CountryCode(name: "Turkey", code: "TR", flag: "🇹🇷", phoneCode: "+90"),
        CountryCode(name: "Russia", code: "RU", flag: "🇷🇺", phoneCode: "+7"),
        CountryCode(name: "Ukraine", code: "UA", flag: "🇺🇦", phoneCode: "+380"),
        CountryCode(name: "Thailand", code: "TH", flag: "🇹🇭", phoneCode: "+66"),
        CountryCode(name: "Vietnam", code: "VN", flag: "🇻🇳", phoneCode: "+84"),
        CountryCode(name: "Indonesia", code: "ID", flag: "🇮🇩", phoneCode: "+62"),
        CountryCode(name: "Malaysia", code: "MY", flag: "🇲🇾", phoneCode: "+60"),
        CountryCode(name: "Singapore", code: "SG", flag: "🇸🇬", phoneCode: "+65"),
        CountryCode(name: "Philippines", code: "PH", flag: "🇵🇭", phoneCode: "+63"),
        CountryCode(name: "New Zealand", code: "NZ", flag: "🇳🇿", phoneCode: "+64"),
        CountryCode(name: "Saudi Arabia", code: "SA", flag: "🇸🇦", phoneCode: "+966"),
        CountryCode(name: "United Arab Emirates", code: "AE", flag: "🇦🇪", phoneCode: "+971"),
        CountryCode(name: "Qatar", code: "QA", flag: "🇶🇦", phoneCode: "+974"),
        CountryCode(name: "Kuwait", code: "KW", flag: "🇰🇼", phoneCode: "+965"),
        CountryCode(name: "Bahrain", code: "BH", flag: "🇧🇭", phoneCode: "+973"),
        CountryCode(name: "Oman", code: "OM", flag: "🇴🇲", phoneCode: "+968"),
        CountryCode(name: "Jordan", code: "JO", flag: "🇯🇴", phoneCode: "+962"),
        CountryCode(name: "Lebanon", code: "LB", flag: "🇱🇧", phoneCode: "+961"),
        CountryCode(name: "Cyprus", code: "CY", flag: "🇨🇾", phoneCode: "+357"),
        CountryCode(name: "Malta", code: "MT", flag: "🇲🇹", phoneCode: "+356"),
        CountryCode(name: "Estonia", code: "EE", flag: "🇪🇪", phoneCode: "+372"),
        CountryCode(name: "Latvia", code: "LV", flag: "🇱🇻", phoneCode: "+371"),
        CountryCode(name: "Lithuania", code: "LT", flag: "🇱🇹", phoneCode: "+370"),
        CountryCode(name: "Slovenia", code: "SI", flag: "🇸🇮", phoneCode: "+386"),
        CountryCode(name: "Slovakia", code: "SK", flag: "🇸🇰", phoneCode: "+421"),
        CountryCode(name: "Croatia", code: "HR", flag: "🇭🇷", phoneCode: "+385"),
        CountryCode(name: "Romania", code: "RO", flag: "🇷🇴", phoneCode: "+40"),
        CountryCode(name: "Bulgaria", code: "BG", flag: "🇧🇬", phoneCode: "+359"),
        CountryCode(name: "Serbia", code: "RS", flag: "🇷🇸", phoneCode: "+381"),
        CountryCode(name: "Montenegro", code: "ME", flag: "🇲🇪", phoneCode: "+382"),
        CountryCode(name: "Albania", code: "AL", flag: "🇦🇱", phoneCode: "+355"),
        CountryCode(name: "North Macedonia", code: "MK", flag: "🇲🇰", phoneCode: "+389"),
        CountryCode(name: "Bosnia and Herzegovina", code: "BA", flag: "🇧🇦", phoneCode: "+387"),
        CountryCode(name: "Moldova", code: "MD", flag: "🇲🇩", phoneCode: "+373"),
        CountryCode(name: "Belarus", code: "BY", flag: "🇧🇾", phoneCode: "+375"),
        CountryCode(name: "Georgia", code: "GE", flag: "🇬🇪", phoneCode: "+995"),
        CountryCode(name: "Armenia", code: "AM", flag: "🇦🇲", phoneCode: "+374"),
        CountryCode(name: "Azerbaijan", code: "AZ", flag: "🇦🇿", phoneCode: "+994"),
        CountryCode(name: "Kazakhstan", code: "KZ", flag: "🇰🇿", phoneCode: "+7"),
        CountryCode(name: "Uzbekistan", code: "UZ", flag: "🇺🇿", phoneCode: "+998"),
        CountryCode(name: "Kyrgyzstan", code: "KG", flag: "🇰🇬", phoneCode: "+996"),
        CountryCode(name: "Tajikistan", code: "TJ", flag: "🇹🇯", phoneCode: "+992"),
        CountryCode(name: "Turkmenistan", code: "TM", flag: "🇹🇲", phoneCode: "+993"),
        CountryCode(name: "Afghanistan", code: "AF", flag: "🇦🇫", phoneCode: "+93"),
        CountryCode(name: "Pakistan", code: "PK", flag: "🇵🇰", phoneCode: "+92"),
        CountryCode(name: "Bangladesh", code: "BD", flag: "🇧🇩", phoneCode: "+880"),
        CountryCode(name: "Sri Lanka", code: "LK", flag: "🇱🇰", phoneCode: "+94"),
        CountryCode(name: "Nepal", code: "NP", flag: "🇳🇵", phoneCode: "+977"),
        CountryCode(name: "Bhutan", code: "BT", flag: "🇧🇹", phoneCode: "+975"),
        CountryCode(name: "Maldives", code: "MV", flag: "🇲🇻", phoneCode: "+960"),
        CountryCode(name: "Myanmar", code: "MM", flag: "🇲🇲", phoneCode: "+95"),
        CountryCode(name: "Cambodia", code: "KH", flag: "🇰🇭", phoneCode: "+855"),
        CountryCode(name: "Laos", code: "LA", flag: "🇱🇦", phoneCode: "+856"),
        CountryCode(name: "Brunei", code: "BN", flag: "🇧🇳", phoneCode: "+673"),
        CountryCode(name: "East Timor", code: "TL", flag: "🇹🇱", phoneCode: "+670"),
        CountryCode(name: "Papua New Guinea", code: "PG", flag: "🇵🇬", phoneCode: "+675"),
        CountryCode(name: "Fiji", code: "FJ", flag: "🇫🇯", phoneCode: "+679"),
        CountryCode(name: "Samoa", code: "WS", flag: "🇼🇸", phoneCode: "+685"),
        CountryCode(name: "Tonga", code: "TO", flag: "🇹🇴", phoneCode: "+676"),
        CountryCode(name: "Vanuatu", code: "VU", flag: "🇻🇺", phoneCode: "+678"),
        CountryCode(name: "Solomon Islands", code: "SB", flag: "🇸🇧", phoneCode: "+677"),
        CountryCode(name: "Palau", code: "PW", flag: "🇵🇼", phoneCode: "+680"),
        CountryCode(name: "Marshall Islands", code: "MH", flag: "🇲🇭", phoneCode: "+692"),
        CountryCode(name: "Micronesia", code: "FM", flag: "🇫🇲", phoneCode: "+691"),
        CountryCode(name: "Kiribati", code: "KI", flag: "🇰🇮", phoneCode: "+686"),
        CountryCode(name: "Nauru", code: "NR", flag: "🇳🇷", phoneCode: "+674"),
        CountryCode(name: "Tuvalu", code: "TV", flag: "🇹🇻", phoneCode: "+688")
    ]
    
    private var filteredCountries: [CountryCode] {
        if searchText.isEmpty {
            return countries
        } else {
            return countries.filter { country in
                country.name.localizedCaseInsensitiveContains(searchText) ||
                country.phoneCode.contains(searchText) ||
                country.code.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredCountries) { country in
                Button(action: {
                    selectedCountry = country
                    dismiss()
                }) {
                    HStack {
                        Text(country.flag)
                            .font(.title2)
                        Text(country.phoneCode)
                            .font(.headline)
                        Text(country.name)
                            .foregroundColor(.gray)
                        Spacer()
                        if selectedCountry?.code == country.code {
                            Image(systemName: "checkmark")
                                .foregroundColor(.appRed)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Country")
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CountryCodePickerView(selectedCountry: .constant(nil))
}
