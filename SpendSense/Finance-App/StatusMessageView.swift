import SwiftUI

struct StatusMessageView: View {
    let message: String
    let type: StatusType
    @Binding var isVisible: Bool
    
    enum StatusType {
        case success
        case error
        case loading
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .loading: return .blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "exclamationmark.circle.fill"
            case .loading: return "arrow.2.circlepath"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if type == .loading {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: type.icon)
                    .foregroundStyle(type.color)
            }
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.primary)
            Spacer()
        }
        .padding()
        .background(type.color.opacity(0.1))
        .overlay(
            Rectangle()
                .frame(height: 3)
                .foregroundStyle(type.color),
            alignment: .top
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .transition(.move(edge: .top).combined(with: .opacity))
        .onAppear {
            if type != .loading {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isVisible = false
                    }
                }
            }
        }
    }
}

struct StatusMessageModifier: ViewModifier {
    @Binding var statusMessage: String?
    @Binding var statusType: StatusMessageView.StatusType?
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            
            if let message = statusMessage, let type = statusType {
                VStack(spacing: 0) {
                    StatusMessageView(
                        message: message,
                        type: type,
                        isVisible: Binding(
                            get: { statusMessage != nil },
                            set: { if !$0 { statusMessage = nil; statusType = nil } }
                        )
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .background(
                        Color(.systemBackground)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                    )
                    
                    Spacer()
                }
                .zIndex(1000)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

extension View {
    func statusMessage(message: Binding<String?>, type: Binding<StatusMessageView.StatusType?>) -> some View {
        modifier(StatusMessageModifier(statusMessage: message, statusType: type))
    }
}

