import SwiftUI

struct TaskDeleteButton: View {
    let isDeleting: Bool
    let action: () -> Void

    @State private var isHovering = false

    var body: some View {
        Button(role: .destructive) {
            action()
        } label: {
            ZStack {
                if isHovering {
                    Circle()
                        .fill(Color.red.opacity(0.12))
                }

                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 13, weight: .medium))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(isHovering ? Color.red : Color.secondary.opacity(0.72))
            }
            .frame(width: 28, height: 28)
            .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(isDeleting)
        .help("Delete task")
        .accessibilityLabel(L.t("task.delete"))
        .opacity(isDeleting ? 0 : 1)
        .offset(x: isDeleting ? 8 : 0)
        .animation(.easeOut(duration: 0.12), value: isDeleting)
        .onHover { hovering in
            withAnimation(.easeOut(duration: 0.12)) {
                isHovering = hovering
            }
        }
    }
}
