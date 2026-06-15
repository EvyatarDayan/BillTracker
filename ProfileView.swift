//
//  ProfileView.swift
//  BillTracker
//
//  Created by EVYATAR DAYAN on 26/08/2025.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var billManager: BillManager
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var currencyManager: CurrencyManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingLoginSheet = false
    @State private var showingEditProfileSheet = false
    @State private var showingDeleteProfileAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Add padding below the navigation title
                Section {
                    EmptyView()
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
                // Profile Section
                Section {
                    if userManager.isLoggedIn {
                        Button(action: {
                            showingEditProfileSheet = true
                        }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.appRed.opacity(0.1))
                                        .frame(width: 60, height: 60)
                                    
                                    if let profileImage = userManager.getProfileImage() {
                                        Image(uiImage: profileImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                    } else if let avatarName = userManager.getAvatarName() {
                                        Image(avatarName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipShape(Circle())
                                    } else {
                                        Image(systemName: "person.fill")
                                            .font(.title2)
                                            .foregroundColor(.appRed)
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(userManager.currentUser?.fullName ?? "")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(userManager.currentUser?.email ?? "")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        HStack (spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(Color.appRed.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundColor(.appRed)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(languageManager.localized("sign_in_to_your_account"))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("access_your_data_across_devices"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Button(languageManager.localized("sign_in")) {
                                showingLoginSheet = true
                            }
                            .buttonStyle(.bordered)
                            .foregroundColor(.appRed)
                        }
                    }
                }
                
                // Account Information Section
                if userManager.isLoggedIn {
                    Section(languageManager.localized("account_information")) {
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "envelope.fill")
                                .font(.title2)
                                .foregroundColor(.appRed)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("email"))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("email_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            Text(userManager.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        
                        HStack(spacing: 12) {
                            // Icon
                            Image(systemName: "person.fill")
                                .font(.title2)
                                .foregroundColor(.appRed)
                                .frame(width: 30)
                            
                            // Title and Subtitle
                            VStack(alignment: .leading, spacing: 2) {
                                Text(languageManager.localized("full_name"))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Text(languageManager.localized("full_name_subtitle"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                            }
                            
                            Spacer()
                            
                            Text(userManager.currentUser?.fullName ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Statistics Section
                Section(languageManager.localized("statistics")) {
                    HStack(spacing: 12) {
                        // Icon
                        Image(systemName: "list.bullet")
                            .font(.title2)
                            .foregroundColor(.appRed)
                            .frame(width: 30)
                        
                        // Title and Subtitle
                        VStack(alignment: .leading, spacing: 2) {
                            Text(languageManager.localized("total_bills"))
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text(languageManager.localized("total_bills_subtitle"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        
                        Spacer()
                        
                        Text("\(billManager.bills.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        // Icon
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .frame(width: 30)
                        
                        // Title and Subtitle
                        VStack(alignment: .leading, spacing: 2) {
                            Text(languageManager.localized("active_bills"))
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text(languageManager.localized("active_bills_subtitle"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        
                        Spacer()
                        
                        Text("\(billManager.bills.filter { $0.isActive }.count)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 12) {
                        // Icon
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.title2)
                            .foregroundColor(.green)
                            .frame(width: 30)
                        
                        // Title and Subtitle
                        VStack(alignment: .leading, spacing: 2) {
                            Text(languageManager.localized("monthly_total"))
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Text(languageManager.localized("monthly_total_subtitle"))
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                                .truncationMode(.tail)
                        }
                        
                        Spacer()
                        
                        Text(currencyManager.formatAmount(billManager.totalMonthlyAmount))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Delete Profile Section
                if userManager.isLoggedIn {
                    Section {
                        Button(action: {
                            showingDeleteProfileAlert = true
                        }) {
                            Text(languageManager.localized("delete_profile"))
                                .foregroundColor(.red)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                
                // Transparent spacer section to prevent content from being hidden by tab bar
                Section {
                    Text("")
                        .frame(height: 20)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                
            } // Close Form
            .navigationTitle(languageManager.localized("profile"))
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
            .sheet(isPresented: $showingLoginSheet) {
                LoginView(userManager: userManager)
                    .environmentObject(languageManager)
            }
            .sheet(isPresented: $showingEditProfileSheet) {
                EditProfileView(userManager: userManager)
                    .environmentObject(languageManager)
            }
            .alert(languageManager.localized("delete_profile"), isPresented: $showingDeleteProfileAlert) {
                Button(languageManager.localized("cancel"), role: .cancel) { }
                Button(languageManager.localized("delete"), role: .destructive) {
                    userManager.deleteProfile()
                }
            } message: {
                Text(languageManager.localized("delete_profile_confirmation"))
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(BillManager())
        .environmentObject(UserManager())
        .environmentObject(ThemeManager())
        .environmentObject(CurrencyManager())
}
