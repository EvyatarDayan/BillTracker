import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // About BillTracker Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(languageManager.localized("about_billtracker_title"))
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(languageManager.localized("about_billtracker_content"))
                            .font(.body)
                            .lineSpacing(4)
                    }
                    
                    // Divider
                    Divider()
                        .padding(.vertical, 8)
                    
                    // About ABASHELARI Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text(languageManager.localized("about_abashelari_title"))
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(languageManager.localized("about_abashelari_content"))
                            .font(.body)
                            .lineSpacing(4)
                    }
                }
                .padding()
            }
            .navigationTitle(languageManager.localized("about"))
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
    AboutView()
}
