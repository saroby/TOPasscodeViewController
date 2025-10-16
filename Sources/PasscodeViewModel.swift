import SwiftUI
import LocalAuthentication
import Combine

/// ViewModel for managing passcode state and logic
@MainActor
public class PasscodeViewModel: ObservableObject {
    @Published var enteredPasscode: String = ""
    @Published var confirmationPasscode: String?
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var canUseBiometrics: Bool = false

    let mode: PasscodeMode
    let passcodeLength: Int

    private var isInConfirmationMode: Bool = false
    private let context = LAContext()

    public init(mode: PasscodeMode, passcodeLength: Int = 4) {
        self.mode = mode
        self.passcodeLength = passcodeLength
        self.checkBiometricAvailability()
    }

    var isComplete: Bool {
        enteredPasscode.count == passcodeLength
    }

    var titleText: String {
        switch mode {
        case .create:
            return isInConfirmationMode ? "패스코드 확인" : "패스코드 생성"
        case .verify:
            return "패스코드 입력"
        case .change:
            return isInConfirmationMode ? "새 패스코드 확인" : "새 패스코드 생성"
        }
    }

    var subtitleText: String? {
        switch mode {
        case .create:
            return isInConfirmationMode ? "패스코드를 다시 입력해주세요" : "\(passcodeLength)자리 패스코드를 입력해주세요"
        case .verify:
            return nil
        case .change:
            return isInConfirmationMode ? "새 패스코드를 다시 입력해주세요" : "새 패스코드를 입력해주세요"
        }
    }

    var biometricIcon: String {
        switch context.biometryType {
        case .faceID:
            return "faceid"
        case .touchID:
            return "touchid"
        default:
            return "lock.shield"
        }
    }

    var biometricText: String {
        switch context.biometryType {
        case .faceID:
            return "Face ID로 잠금 해제"
        case .touchID:
            return "Touch ID로 잠금 해제"
        default:
            return "생체 인증"
        }
    }

    func addDigit(_ digit: Int) {
        guard enteredPasscode.count < passcodeLength else { return }

        withAnimation(.easeInOut(duration: 0.1)) {
            enteredPasscode.append("\(digit)")
        }

        if showError {
            showError = false
        }
    }

    func deleteDigit() {
        guard !enteredPasscode.isEmpty else { return }

        enteredPasscode.removeLast()
    }

    func moveToConfirmation() {
        confirmationPasscode = enteredPasscode
        enteredPasscode = ""
        isInConfirmationMode = true
    }

    func validateConfirmation() -> Bool {
        return enteredPasscode == confirmationPasscode
    }

    func reset() {
        enteredPasscode = ""
        confirmationPasscode = nil
        isInConfirmationMode = false
        showError = false
        errorMessage = ""
    }

    func showError(message: String) {
        withAnimation {
            showError = true
            errorMessage = message
        }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    private func checkBiometricAvailability() {
        var error: NSError?
        canUseBiometrics = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let reason = "앱 잠금을 해제하려면 인증이 필요합니다"

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(true)
                } else {
                    if let error = error as? LAError {
                        switch error.code {
                        case .userCancel, .systemCancel, .appCancel:
                            // User cancelled, do nothing
                            break
                        default:
                            self.showError(message: "생체 인증에 실패했습니다")
                        }
                    }
                    completion(false)
                }
            }
        }
    }
}
