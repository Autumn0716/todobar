import SwiftUI

struct UndoBar: View {
    let title: String
    let onUndo: () -> Void

    @Environment(\.webTheme) private var theme

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12))
                .lineLimit(1)
                .foregroundStyle(theme.muted)
            Spacer()
            Button("Undo") {
                onUndo()
            }
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(theme.ink)
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.regularMaterial)
        }
        .padding(.horizontal, 10)
        .padding(.bottom, 10)
    }
}
