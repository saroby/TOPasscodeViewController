import SwiftUI

/// Visual representation of passcode input progress
struct PasscodeDotsView: View {
    let enteredCount: Int
    let totalCount: Int
    let isError: Bool

    private let dotSize: CGFloat = 16
    private let spacing: CGFloat = 24

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<totalCount, id: \.self) { index in
                Circle()
                    .fill(dotColor(for: index))
                    .frame(width: dotSize, height: dotSize)
                    .overlay(
                        Circle()
                            .stroke(dotBorderColor(for: index), lineWidth: 2)
                    )
                    .scaleEffect(isError ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isError)
                    .animation(.easeInOut(duration: 0.2), value: enteredCount)
            }
        }
        .modifier(ShakeEffect(animatableData: isError ? 1 : 0))
    }

    private func dotColor(for index: Int) -> Color {
        if isError {
            return index < enteredCount ? .red.opacity(0.8) : .clear
        }
        return index < enteredCount ? .white : .clear
    }

    private func dotBorderColor(for index: Int) -> Color {
        if isError {
            return .red
        }
        return index < enteredCount ? .white : .white.opacity(0.3)
    }
}

/// Shake animation effect for error state
struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: 10 * sin(animatableData * .pi * 2),
                y: 0
            )
        )
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.9)
            .ignoresSafeArea()

        VStack(spacing: 40) {
            Text("Normal State")
                .foregroundColor(.white)
            PasscodeDotsView(enteredCount: 2, totalCount: 4, isError: false)

            Text("Complete State")
                .foregroundColor(.white)
            PasscodeDotsView(enteredCount: 4, totalCount: 4, isError: false)

            Text("Error State")
                .foregroundColor(.white)
            PasscodeDotsView(enteredCount: 4, totalCount: 4, isError: true)
        }
    }
}
