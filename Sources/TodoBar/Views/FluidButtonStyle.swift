import SwiftUI
import AppKit

struct FluidButtonStyle: ButtonStyle {
    @State private var isHovering = false
    let isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.webTheme) private var theme
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isHovering && isEnabled ? theme.ink.opacity(configuration.isPressed ? 0.12 : 0.05) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(theme.ink.opacity(isFocused ? 0.2 : 0), lineWidth: 1.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : (isHovering && isEnabled ? 1.02 : 1.0))
            .opacity(isEnabled ? (configuration.isPressed ? 0.9 : 1.0) : 0.4)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: isHovering)
            .animation(.easeOut(duration: 0.15), value: isFocused)
            .onHover { hovering in
                isHovering = hovering
                if hovering && isEnabled {
                    NSCursor.pointingHand.set()
                } else {
                    NSCursor.arrow.set()
                }
            }
    }
}

struct ProMaxDeleteButtonStyle: ButtonStyle {
    @State private var isHovering = false
    let isFocused: Bool
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.webTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(configuration.isPressed ? Color.red : (isHovering ? Color.red.opacity(0.8) : theme.muted))
            .scaleEffect(configuration.isPressed ? 0.96 : (isHovering ? 1.02 : 1.0))
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(configuration.isPressed ? Color.red.opacity(0.2) : (isHovering ? Color.red.opacity(0.08) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.red.opacity(isFocused ? 0.3 : 0), lineWidth: 1.5)
            )
            .opacity(isEnabled ? 1.0 : 0.4)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: isHovering)
            .animation(.easeOut(duration: 0.15), value: isFocused)
            .onHover { hovering in
                isHovering = hovering
                if hovering && isEnabled { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
            }
    }
}

struct FluidButtonModifier: ViewModifier {
    @FocusState private var isFocused: Bool
    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .buttonStyle(FluidButtonStyle(isFocused: isFocused))
    }
}

struct ProMaxDeleteButtonModifier: ViewModifier {
    @FocusState private var isFocused: Bool
    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .buttonStyle(ProMaxDeleteButtonStyle(isFocused: isFocused))
    }
}

struct BlackToggleStyle: ToggleStyle {
    @Environment(\.webTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(configuration.isOn ? theme.ink : theme.muted.opacity(0.2))
                .frame(width: 44, height: 22)
                .overlay(
                    Circle()
                        .fill(configuration.isOn ? (theme.isDark ? Color.black : Color.white) : (theme.isDark ? Color(white: 0.75) : Color.white))
                        .padding(2)
                        .offset(x: configuration.isOn ? 11 : -11)
                        .shadow(radius: 1, y: 1)
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                        configuration.isOn.toggle()
                    }
                }
                .onHover { hovering in
                    if hovering { NSCursor.pointingHand.set() } else { NSCursor.arrow.set() }
                }
        }
    }
}

extension View {
    func fluidButton() -> some View {
        self.modifier(FluidButtonModifier())
    }
    
    func deleteButton() -> some View {
        self.modifier(ProMaxDeleteButtonModifier())
    }
    
    func blackToggle() -> some View {
        self.toggleStyle(BlackToggleStyle())
    }
}
