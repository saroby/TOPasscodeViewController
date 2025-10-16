import SwiftUI

/// Example usage of PasscodeView module
struct PasscodeExampleView: View {
    @State private var showCreatePasscode = false
    @State private var showVerifyPasscode = false
    @State private var showChangePasscode = false
    @State private var savedPasscode: String?
    @State private var message: String = "패스코드가 설정되지 않았습니다"

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Status message
                Text(message)
                    .font(.headline)
                    .foregroundColor(savedPasscode != nil ? .green : .gray)
                    .multilineTextAlignment(.center)
                    .padding()

                // Create passcode button
                Button("패스코드 생성") {
                    showCreatePasscode = true
                }
                .buttonStyle(ExampleButtonStyle())
                .disabled(savedPasscode != nil)

                // Verify passcode button
                Button("패스코드 확인") {
                    showVerifyPasscode = true
                }
                .buttonStyle(ExampleButtonStyle())
                .disabled(savedPasscode == nil)

                // Change passcode button
                Button("패스코드 변경") {
                    showChangePasscode = true
                }
                .buttonStyle(ExampleButtonStyle())
                .disabled(savedPasscode == nil)

                // Reset button
                if savedPasscode != nil {
                    Button("초기화") {
                        savedPasscode = nil
                        message = "패스코드가 삭제되었습니다"
                    }
                    .foregroundColor(.red)
                    .padding(.top, 20)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("패스코드 예제")
        }
        // Create passcode
        .passcode(
            isPresented: $showCreatePasscode,
            mode: .create,
            passcodeLength: 4,
            onComplete: { passcode in
                savedPasscode = passcode
                message = "패스코드가 생성되었습니다: \(passcode)"
            },
            onCancel: {
                message = "패스코드 생성이 취소되었습니다"
            }
        )
        // Verify passcode
        .passcode(
            isPresented: $showVerifyPasscode,
            mode: .verify,
            passcodeLength: 4,
            onComplete: { passcode in
                if passcode == savedPasscode {
                    message = "✅ 패스코드가 일치합니다!"
                } else {
                    message = "❌ 패스코드가 일치하지 않습니다"
                }
            },
            onCancel: {
                message = "패스코드 확인이 취소되었습니다"
            }
        )
        // Change passcode
        .passcode(
            isPresented: $showChangePasscode,
            mode: .change,
            passcodeLength: 4,
            onComplete: { passcode in
                savedPasscode = passcode
                message = "패스코드가 변경되었습니다: \(passcode)"
            },
            onCancel: {
                message = "패스코드 변경이 취소되었습니다"
            }
        )
    }
}

struct ExampleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    PasscodeExampleView()
}
