import SwiftUI

struct TermsPrivacyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                Picker("Section", selection: $selectedTab) {
                    Text(languageManager.localized("terms_of_use_title")).tag(0)
                    Text(languageManager.localized("privacy_policy_title")).tag(1)
                    Text(languageManager.localized("disclaimer_title")).tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                TabView(selection: $selectedTab) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageManager.localized("terms_of_use_content"))
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding()
                    }
                    .tag(0)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageManager.localized("privacy_policy_content"))
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding()
                    }
                    .tag(1)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(languageManager.localized("disclaimer_content"))
                                .font(.body)
                                .lineSpacing(4)
                        }
                        .padding()
                    }
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .navigationTitle(languageManager.localized("terms_privacy"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(languageManager.localized("close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    TermsPrivacyView()
}
