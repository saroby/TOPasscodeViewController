import SwiftUI

/// View modifier for easily presenting passcode view
public struct PasscodeViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    let mode: PasscodeMode
    let passcodeLength: Int
    let onComplete: (String) -> Void
    let onCancel: (() -> Void)?

    public func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
                PasscodeView(
                    mode: mode,
                    passcodeLength: passcodeLength,
                    onComplete: { passcode in
                        onComplete(passcode)
                        isPresented = false
                    },
                    onCancel: onCancel != nil ? {
                        onCancel?()
                        isPresented = false
                    } : nil
                )
            }
    }
}

public extension View {
    /// Present a passcode view
    /// - Parameters:
    ///   - isPresented: Binding to control presentation
    ///   - mode: Passcode mode (create, verify, or change)
    ///   - passcodeLength: Length of the passcode (default: 4)
    ///   - onComplete: Callback when passcode is entered
    ///   - onCancel: Optional cancel callback
    func passcode(
        isPresented: Binding<Bool>,
        mode: PasscodeMode,
        passcodeLength: Int = 4,
        onComplete: @escaping (String) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        modifier(PasscodeViewModifier(
            isPresented: isPresented,
            mode: mode,
            passcodeLength: passcodeLength,
            onComplete: onComplete,
            onCancel: onCancel
        ))
    }
}
