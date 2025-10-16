import SwiftUI

/// SwiftUI implementation of passcode input view
public struct PasscodeView: View {
    @StateObject private var viewModel: PasscodeViewModel

    let mode: PasscodeMode
    let onComplete: (String) -> Void
    let onCancel: (() -> Void)?

    public init(
        mode: PasscodeMode,
        passcodeLength: Int = 4,
        onComplete: @escaping (String) -> Void,
        onCancel: (() -> Void)? = nil
    ) {
        self.mode = mode
        self.onComplete = onComplete
        self.onCancel = onCancel
        self._viewModel = StateObject(wrappedValue: PasscodeViewModel(
            mode: mode,
            passcodeLength: passcodeLength
        ))
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Title
                Text(viewModel.titleText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                // Subtitle if needed
                if let subtitle = viewModel.subtitleText {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Spacer()
                    .frame(height: 20)

                // Passcode dots
                PasscodeDotsView(
                    enteredCount: viewModel.enteredPasscode.count,
                    totalCount: viewModel.passcodeLength,
                    isError: viewModel.showError
                )

                // Error message
                if viewModel.showError {
                    Text(viewModel.errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }

                Spacer()
                    .frame(height: 40)

                // Number keypad
                NumberKeypadView { number in
                    viewModel.addDigit(number)
                    if viewModel.isComplete {
                        handleCompletion()
                    }
                } onDelete: {
                    viewModel.deleteDigit()
                }

                // Biometric button
                if viewModel.canUseBiometrics {
                    Button(action: {
                        viewModel.authenticateWithBiometrics { success in
                            if success {
                                onComplete("")
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: viewModel.biometricIcon)
                            Text(viewModel.biometricText)
                        }
                        .foregroundColor(.accentColor)
                    }
                    .padding(.top, 20)
                }

                // Cancel button
                if let cancel = onCancel {
                    Button("취소", action: cancel)
                        .foregroundColor(.white)
                        .padding(.top, 10)
                }
            }
            .padding()
        }
    }

    private func handleCompletion() {
        switch viewModel.mode {
        case .create:
            if viewModel.confirmationPasscode == nil {
                viewModel.moveToConfirmation()
            } else if viewModel.validateConfirmation() {
                onComplete(viewModel.enteredPasscode)
            } else {
                viewModel.showError(message: "패스코드가 일치하지 않습니다")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    viewModel.reset()
                }
            }

        case .verify:
            onComplete(viewModel.enteredPasscode)

        case .change:
            if viewModel.confirmationPasscode == nil {
                viewModel.moveToConfirmation()
            } else if viewModel.validateConfirmation() {
                onComplete(viewModel.enteredPasscode)
            } else {
                viewModel.showError(message: "패스코드가 일치하지 않습니다")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    viewModel.reset()
                }
            }
        }
    }
}

public enum PasscodeMode {
    case create
    case verify
    case change
}

#Preview("Create Mode") {
    PasscodeView(
        mode: .create,
        passcodeLength: 4,
        onComplete: { passcode in
            print("Created passcode: \(passcode)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}

#Preview("Verify Mode") {
    PasscodeView(
        mode: .verify,
        passcodeLength: 4,
        onComplete: { passcode in
            print("Entered passcode: \(passcode)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}

#Preview("Change Mode") {
    PasscodeView(
        mode: .change,
        passcodeLength: 6,
        onComplete: { passcode in
            print("Changed passcode: \(passcode)")
        },
        onCancel: {
            print("Cancelled")
        }
    )
}

#Preview("No Cancel Button") {
    PasscodeView(
        mode: .verify,
        passcodeLength: 4,
        onComplete: { passcode in
            print("Entered passcode: \(passcode)")
        },
        onCancel: nil
    )
}
