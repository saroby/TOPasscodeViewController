import SwiftUI

/// Number keypad for passcode input
struct NumberKeypadView: View {
    let onNumberTap: (Int) -> Void
    let onDelete: () -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 3)
    private let buttonSize: CGFloat = 75

    var body: some View {
        VStack(spacing: 20) {
            // Numbers 1-9
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(1...9, id: \.self) { number in
                    NumberButton(number: number, size: buttonSize) {
                        onNumberTap(number)
                    }
                }
            }

            // Bottom row: empty, 0, delete
            HStack(spacing: 20) {
                // Empty space
                Color.clear
                    .frame(width: buttonSize, height: buttonSize)

                // Zero button
                NumberButton(number: 0, size: buttonSize) {
                    onNumberTap(0)
                }

                // Delete button
                DeleteButton(size: buttonSize, action: onDelete)
            }
        }
        .padding(.horizontal, 40)
    }
}

/// Individual number button
struct NumberButton: View {
    let number: Int
    let size: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(isPressed ? Color.white.opacity(0.2) : Color.white.opacity(0.1))
                    .frame(width: size, height: size)

                Text("\(number)")
                    .font(.system(size: 32, weight: .regular, design: .rounded))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

/// Delete button with icon
struct DeleteButton: View {
    let size: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            ZStack {
                Circle()
                    .fill(isPressed ? Color.white.opacity(0.2) : Color.clear)
                    .frame(width: size, height: size)

                Image(systemName: "delete.left")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

/// Button style with scale animation
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.9)
            .ignoresSafeArea()

        NumberKeypadView(
            onNumberTap: { number in
                print("Number tapped: \(number)")
            },
            onDelete: {
                print("Delete tapped")
            }
        )
    }
}
