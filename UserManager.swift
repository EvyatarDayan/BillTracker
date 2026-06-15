
//
//  UserManager.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import Foundation
import SwiftUI

struct User: Codable {
    let id: UUID
    let firstName: String
    let lastName: String
    let email: String
    let password: String // In a real app, this should be hashed
    let profileImageData: Data?
    let avatarName: String?
    let phoneNumber: String?
    let countryCode: String?
    let createdAt: Date
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    var fullPhoneNumber: String {
        if let countryCode = countryCode, let phoneNumber = phoneNumber, !phoneNumber.isEmpty {
            // If countryCode starts with "+", use it directly
            if countryCode.hasPrefix("+") {
                return "\(countryCode) \(phoneNumber)"
            } else {
                // If it's a country abbreviation like "IL", we need to map it to phone code
                let phoneCode = mapCountryCodeToPhoneCode(countryCode)
                return "\(phoneCode) \(phoneNumber)"
            }
        } else if let phoneNumber = phoneNumber, !phoneNumber.isEmpty {
            return phoneNumber
        } else {
            return "Not provided"
        }
    }
    
    private func mapCountryCodeToPhoneCode(_ countryCode: String) -> String {
        let countryToPhoneCode: [String: String] = [
            "US": "+1", "GB": "+44", "CA": "+1", "AU": "+61", "DE": "+49", "FR": "+33",
            "IT": "+39", "ES": "+34", "NL": "+31", "SE": "+46", "NO": "+47", "DK": "+45",
            "FI": "+358", "CH": "+41", "AT": "+43", "BE": "+32", "PL": "+48", "CZ": "+420",
            "HU": "+36", "PT": "+351", "GR": "+30", "IE": "+353", "LU": "+352", "IS": "+354",
            "MT": "+356", "CY": "+357", "EE": "+372", "LV": "+371", "LT": "+370", "SI": "+386",
            "SK": "+421", "HR": "+385", "BG": "+359", "RO": "+40", "IL": "+972", "TR": "+90",
            "RU": "+7", "UA": "+380", "BY": "+375", "MD": "+373", "GE": "+995", "AM": "+374",
            "AZ": "+994", "KZ": "+7", "UZ": "+998", "KG": "+996", "TJ": "+992", "TM": "+993",
            "AF": "+93", "PK": "+92", "IN": "+91", "BD": "+880", "LK": "+94", "MV": "+960",
            "BT": "+975", "NP": "+977", "CN": "+86", "JP": "+81", "KR": "+82", "KP": "+850",
            "MN": "+976", "TW": "+886", "HK": "+852", "MO": "+853", "SG": "+65", "MY": "+60",
            "TH": "+66", "VN": "+84", "LA": "+856", "KH": "+855", "MM": "+95", "BN": "+673",
            "ID": "+62", "PH": "+63", "TL": "+670", "PG": "+675", "FJ": "+679", "NC": "+687",
            "VU": "+678", "SB": "+677", "TO": "+676", "WS": "+685", "KI": "+686", "TV": "+688",
            "NR": "+674", "FM": "+691", "MH": "+692", "PW": "+680", "AS": "+1684", "GU": "+1671",
            "MP": "+1670", "VI": "+1340", "PR": "+1787", "DO": "+1809", "HT": "+509", "JM": "+1876",
            "CU": "+53", "BS": "+1242", "BB": "+1246", "AG": "+1268", "DM": "+1767", "GD": "+1473",
            "KN": "+1869", "LC": "+1758", "VC": "+1784", "TT": "+1868", "GY": "+592", "SR": "+597",
            "BR": "+55", "AR": "+54", "CL": "+56", "UY": "+598", "PY": "+595", "BO": "+591",
            "PE": "+51", "EC": "+593", "CO": "+57", "VE": "+58", "GF": "+594", "FK": "+500",
            "ZA": "+27", "EG": "+20", "LY": "+218", "TN": "+216", "DZ": "+213", "MA": "+212",
            "SD": "+249", "SS": "+211", "ET": "+251", "ER": "+291", "DJ": "+253", "SO": "+252",
            "KE": "+254", "UG": "+256", "TZ": "+255", "RW": "+250", "BI": "+257", "MW": "+265",
            "ZM": "+260", "ZW": "+263", "BW": "+267", "NA": "+264", "SZ": "+268", "LS": "+266",
            "MG": "+261", "MU": "+230", "SC": "+248", "KM": "+269", "YT": "+262", "RE": "+262",
            "MZ": "+258", "AO": "+244", "CD": "+243", "CG": "+242", "GA": "+241", "GQ": "+240",
            "ST": "+239", "CV": "+238", "GM": "+220", "SN": "+221", "ML": "+223", "BF": "+226",
            "NE": "+227", "TD": "+235", "CM": "+237", "CF": "+236", "GH": "+233", "TG": "+228",
            "BJ": "+229", "NG": "+234", "CI": "+225", "LR": "+231", "SL": "+232", "GN": "+224",
            "GW": "+245", "MR": "+222", "EH": "+212"
        ]
        return countryToPhoneCode[countryCode] ?? "+1" // Default to US if not found
    }
    
    init(firstName: String, lastName: String, email: String, password: String, profileImageData: Data? = nil, avatarName: String? = nil, phoneNumber: String? = nil, countryCode: String? = nil) {
        self.id = UUID()
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.profileImageData = profileImageData
        self.avatarName = avatarName
        self.phoneNumber = phoneNumber
        self.countryCode = countryCode
        self.createdAt = Date()
    }
}

class UserManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoggedIn: Bool = false
    
    private let usersKey = "SavedUsers"
    private let currentUserKey = "CurrentUser"
    private weak var billManager: BillManager?
    
    init() {
        loadCurrentUser()
    }
    
    func setBillManager(_ billManager: BillManager) {
        self.billManager = billManager
    }
    
    // MARK: - User Registration
    func registerUser(firstName: String, lastName: String, email: String, password: String, profileImage: UIImage?, avatarName: String? = nil, phoneNumber: String? = nil, countryCode: String? = nil) -> Bool {
        // Check if user already exists
        if getUserByEmail(email) != nil {
            return false // User already exists
        }
        
        // Convert UIImage to Data
        let profileImageData = profileImage?.jpegData(compressionQuality: 0.8)
        
        // Create new user
        let newUser = User(firstName: firstName, lastName: lastName, email: email, password: password, profileImageData: profileImageData, avatarName: avatarName, phoneNumber: phoneNumber, countryCode: countryCode)
        
        // Save user to storage
        saveUser(newUser)
        
        // Auto-login after registration
        _ = loginUser(email: email, password: password)
        
        return true
    }
    
    // MARK: - User Login
    func loginUser(email: String, password: String) -> Bool {
        guard let user = getUserByEmail(email) else {
            return false // User not found
        }
        
        guard user.password == password else {
            return false // Wrong password
        }
        
        // Set current user and login status
        currentUser = user
        isLoggedIn = true
        
        // Save current user
        saveCurrentUser()
        
        // Refresh bills for the logged-in user
        billManager?.refreshBillsForCurrentUser()
        
        return true
    }
    
    // MARK: - User Logout
    func logoutUser() {
        // Save bills for the current user before clearing
        if let userId = currentUser?.id {
            billManager?.saveBillsForUser(userId)
        }
        
        currentUser = nil
        isLoggedIn = false
        
        // Clear current user from storage
        UserDefaults.standard.removeObject(forKey: currentUserKey)
        
        // Refresh bills for guest user
        billManager?.refreshBillsForCurrentUser()
    }
    
    func deleteProfile() {
        guard let userToDelete = currentUser else {
            return
        }
        
        let userId = userToDelete.id
        
        // Remove user from the users list
        var users = getAllUsers()
        users.removeAll { $0.id == userId }
        
        // Save updated users list
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: usersKey)
        }
        
        // Delete user's bills
        UserDefaults.standard.removeObject(forKey: "SavedBills_\(userId.uuidString)")
        
        // Clear current user
        currentUser = nil
        isLoggedIn = false
        
        // Clear current user from storage
        UserDefaults.standard.removeObject(forKey: currentUserKey)
        
        // Refresh bills for guest user
        billManager?.refreshBillsForCurrentUser()
    }
    
    // MARK: - Update User Profile
    func updateUserProfile(firstName: String, lastName: String, profileImage: UIImage?, avatarName: String? = nil, phoneNumber: String? = nil, countryCode: String? = nil) -> Bool {
        guard let currentUser = currentUser else {
            print("No current user found")
            return false
        }
        
        print("Updating user profile:")
        print("- Email: \(currentUser.email)")
        print("- Profile Image: \(profileImage != nil ? "Set" : "Not set")")
        print("- Avatar Name: \(avatarName ?? "Not set")")
        
        // Convert UIImage to Data
        let profileImageData = profileImage?.jpegData(compressionQuality: 0.8)
        
        // Create updated user with same ID and password
        let updatedUser = User(
            firstName: firstName,
            lastName: lastName,
            email: currentUser.email,
            password: currentUser.password,
            profileImageData: profileImageData,
            avatarName: avatarName,
            phoneNumber: phoneNumber,
            countryCode: countryCode
        )
        
        print("Created updated user with avatar: \(updatedUser.avatarName ?? "Not set")")
        
        // Update the user in storage
        updateUserInStorage(updatedUser)
        
        // Update current user
        self.currentUser = updatedUser
        
        // Save current user
        saveCurrentUser()
        
        print("Profile update completed successfully")
        return true
    }
    
    // MARK: - Update Password
    func updatePassword(currentPassword: String, newPassword: String) -> Bool {
        guard let currentUser = currentUser else {
            print("No current user found")
            return false
        }
        
        // Verify current password
        guard currentUser.password == currentPassword else {
            print("Current password is incorrect")
            return false
        }
        
        // Validate new password
        guard isPasswordValid(newPassword) else {
            print("New password is not valid")
            return false
        }
        
        print("Updating password for user: \(currentUser.email)")
        
        // Create updated user with new password
        let updatedUser = User(
            firstName: currentUser.firstName,
            lastName: currentUser.lastName,
            email: currentUser.email,
            password: newPassword,
            profileImageData: currentUser.profileImageData,
            avatarName: currentUser.avatarName,
            phoneNumber: currentUser.phoneNumber,
            countryCode: currentUser.countryCode
        )
        
        // Update the user in storage
        updateUserInStorage(updatedUser)
        
        // Update current user
        self.currentUser = updatedUser
        
        // Save current user
        saveCurrentUser()
        
        print("Password update completed successfully")
        return true
    }
    
    // MARK: - User Management
    private func saveUser(_ user: User) {
        var users = getAllUsers()
        users.append(user)
        
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: usersKey)
        }
    }
    
    private func updateUserInStorage(_ updatedUser: User) {
        var users = getAllUsers()
        
        // Find and replace the user
        if let index = users.firstIndex(where: { $0.email == updatedUser.email }) {
            users[index] = updatedUser
            
            if let encoded = try? JSONEncoder().encode(users) {
                UserDefaults.standard.set(encoded, forKey: usersKey)
            }
        }
    }
    
    private func getAllUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    private func getUserByEmail(_ email: String) -> User? {
        let users = getAllUsers()
        return users.first { $0.email.lowercased() == email.lowercased() }
    }
    
    private func saveCurrentUser() {
        if let encoded = try? JSONEncoder().encode(currentUser) {
            UserDefaults.standard.set(encoded, forKey: currentUserKey)
            print("Current user saved to UserDefaults")
            print("- Avatar Name: \(currentUser?.avatarName ?? "Not set")")
        } else {
            print("Failed to encode current user for saving")
        }
    }
    
    private func loadCurrentUser() {
        guard let data = UserDefaults.standard.data(forKey: currentUserKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            print("No saved user data found")
            isLoggedIn = false
            return
        }
        
        print("Loading user data:")
        print("- Email: \(user.email)")
        print("- Name: \(user.fullName)")
        print("- Profile Image: \(user.profileImageData != nil ? "Set" : "Not set")")
        print("- Avatar Name: \(user.avatarName ?? "Not set")")
        
        currentUser = user
        isLoggedIn = true
        
        print("User loaded successfully")
    }
    
    // MARK: - Profile Image Management
    func getProfileImage() -> UIImage? {
        guard let imageData = currentUser?.profileImageData else {
            return nil
        }
        return UIImage(data: imageData)
    }
    
    // MARK: - Avatar Management
    func getAvatarName() -> String? {
        return currentUser?.avatarName
    }
    
    // MARK: - User Validation
    func isEmailValid(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    func doPasswordsMatch(_ password1: String, _ password2: String) -> Bool {
        return password1 == password2
    }
    
    func isUserExists(_ email: String) -> Bool {
        return getUserByEmail(email) != nil
    }
}
