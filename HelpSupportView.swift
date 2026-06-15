import SwiftUI

struct HelpSupportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userManager: UserManager
    @EnvironmentObject var languageManager: LanguageManager
    @State private var fullName = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var description = ""
    @State private var showForm = false
    @State private var showError = false
    @State private var showCallAlert = false
    @State private var alertType: AlertType = .none
    
    enum AlertType {
        case none
        case messageSent
        case callSupport
    }
    
    let supportPhone = "+46 123 456 789"
    private let supportEmailAddress = "abashelariprod@gmail.com"
    
    private var supportEmailURL: URL? {
        URL(string: "mailto:\(supportEmailAddress)")
    }
    
    private var supportWebsiteURL: URL? {
        let contact = languageManager.localized("website_contact")
        guard let httpRange = contact.range(of: "http") else { return nil }
        let urlString = String(contact[httpRange.lowerBound...]).trimmingCharacters(in: .whitespaces)
        return URL(string: urlString)
    }
    
    private func populateUserInfo() {
        if userManager.isLoggedIn, let user = userManager.currentUser {
            fullName = user.fullName
            email = user.email
        }
    }
    
    var allFieldsFilled: Bool {
        !fullName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !subject.trimmingCharacters(in: .whitespaces).isEmpty &&
        !description.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationView {
            Group {
                if showForm {
                    Form {
                        Section(header: Text(languageManager.localized("your_full_name"))) {
                            TextField(languageManager.localized("full_name"), text: $fullName)
                        }
                        Section(header: Text(languageManager.localized("your_email"))) {
                            TextField(languageManager.localized("email"), text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        Section(header: Text(languageManager.localized("subject"))) {
                            TextField("", text: $subject)
                                .onChange(of: subject) { newValue in
                                    if newValue.count > 100 {
                                        subject = String(newValue.prefix(100))
                                    }
                                }
                            HStack {
                                Spacer()
                                Text("\(subject.count)/100")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Section(header: Text(languageManager.localized("description"))) {
                            TextEditor(text: $description)
                                .frame(height: 120)
                                .onChange(of: description) { newValue in
                                    if newValue.count > 400 {
                                        description = String(newValue.prefix(400))
                                    }
                                }
                            HStack {
                                Spacer()
                                Text("\(description.count)/400")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        if showError && !allFieldsFilled {
                            Section {
                                Text(languageManager.localized("all_fields_required"))
                                    .foregroundColor(.red)
                                    .font(.subheadline)
                            }
                        }
                        Section {
                            Button(action: {
                                if allFieldsFilled {
                                    alertType = .messageSent
                                    showError = false
                                } else {
                                    showError = true
                                }
                            }) {
                                Text(languageManager.localized("send"))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(allFieldsFilled ? Color.green : Color.gray)
                                    .cornerRadius(12)
                            }
                            .disabled(!allFieldsFilled)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .navigationTitle(languageManager.localized("contact_us"))
                    .onAppear {
                        populateUserInfo()
                    }
                } else {
                    VStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .center, spacing: 32) {
                            VStack(alignment: .center, spacing: 16) {
                                Text(languageManager.localized("wed_love_to_hear_from_you"))
                                    .font(.title3)
                                    .fontWeight(.bold)
                                Text(languageManager.localized("whether_you_have_questions"))
                                    .font(.body)
                                Text(languageManager.localized("feedback_or_just_want_to_say_hi"))
                                    .font(.body)
                                Text(languageManager.localized("feel_free_to_reach_out"))
                                    .font(.body)
                                Divider().padding(.vertical, 8)
                                    .padding(.top, 32)
                                    .padding(.bottom, 32)
                                
                                if let supportEmailURL {
                                    Link(destination: supportEmailURL) {
                                        Text(languageManager.localized("email_contact"))
                                            .font(.subheadline)
                                    }
                                } else {
                                    Text(languageManager.localized("email_contact"))
                                        .font(.subheadline)
                                }
                                
                                if let supportWebsiteURL {
                                    Link(destination: supportWebsiteURL) {
                                        Text(languageManager.localized("website_contact"))
                                            .font(.subheadline)
                                    }
                                } else {
                                    Text(languageManager.localized("website_contact"))
                                        .font(.subheadline)
                                }
                                
                                Divider().padding(.vertical, 8)
                                    .padding(.top, 32)
                            }
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 32)
                            
                            Text(languageManager.localized("or"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                            
                            Button(action: { 
                                populateUserInfo()
                                showForm = true 
                            }) {
                                Text(languageManager.localized("contact_form"))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color.green)
                                    .cornerRadius(12)
                                    .padding(.horizontal, 32)
                            }
                            
                            Text(languageManager.localized("we_aim_to_respond_within_24_hours"))
                                .font(.body)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.vertical, 32)
                    .navigationTitle(languageManager.localized("help_support"))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if showForm {
                        Button(languageManager.localized("cancel")) {
                            showForm = false
                        }
                    } else {
                        Button(languageManager.localized("close")) {
                            dismiss()
                        }
                    }
                }
            }
            .alert(isPresented: Binding(
                get: { alertType != .none },
                set: { if !$0 { alertType = .none } }
            )) {
                switch alertType {
                case .messageSent:
                    return Alert(
                        title: Text(languageManager.localized("message_sent")),
                        message: Text(languageManager.localized("thanks_for_reaching_out")),
                        dismissButton: .default(Text(languageManager.localized("ok"))) {
                            dismiss()
                        }
                    )
                case .callSupport:
                    return Alert(
                        title: Text(languageManager.localized("call_support")),
                        message: Text(languageManager.localized("do_you_want_to_call").replacingOccurrences(of: "{phone}", with: supportPhone)),
                        primaryButton: .default(Text(languageManager.localized("yes"))) {
                            if let url = URL(string: "tel://" + supportPhone.filter { $0.isNumber }) {
                                UIApplication.shared.open(url)
                            }
                        },
                        secondaryButton: .cancel(Text(languageManager.localized("no")))
                    )
                case .none:
                    return Alert(title: Text(""), message: Text(""), dismissButton: .default(Text("")))
                }
            }
        }
    }
}

#Preview {
    HelpSupportView()
}
