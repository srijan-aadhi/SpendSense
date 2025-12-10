import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let content: String
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(content)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

