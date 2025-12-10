import SwiftUI

struct PurchaseRowView: View {
    let purchase: Purchase
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon based on purchase type
            Image(systemName: iconForType(purchase.type))
                .foregroundStyle(colorForType(purchase.type))
                .font(.title3)
                .frame(width: 40, height: 40)
                .background(colorForType(purchase.type).opacity(0.1))
                .clipShape(Circle())
            
            // Purchase details
            VStack(alignment: .leading, spacing: 4) {
                Text(purchase.type.rawValue)
                    .font(.headline)
                if let platform = purchase.platform {
                    Text(platform)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(purchase.date, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Amount
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(purchase.amount, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            
            // Action buttons
            Menu {
                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
                Button(action: onEdit) {
                    Label("Edit", systemImage: "pencil")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .padding(.horizontal)
    }
    
    private func iconForType(_ type: PurchaseType) -> String {
        switch type {
        case .unnecessaryImpulse: return "exclamationmark.triangle.fill"
        case .newMonthlyCharge: return "calendar.badge.clock"
        case .necessary: return "checkmark.circle.fill"
        case .misc: return "tag.fill"
        }
    }
    
    private func colorForType(_ type: PurchaseType) -> Color {
        switch type {
        case .unnecessaryImpulse: return .red
        case .newMonthlyCharge: return .orange
        case .necessary: return .green
        case .misc: return .blue
        }
    }
}

