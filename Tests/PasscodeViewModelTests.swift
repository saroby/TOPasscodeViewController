import XCTest
@testable import TOPasscodeViewController

@MainActor
final class PasscodeViewModelTests: XCTestCase {

    func testInitialization() {
        let viewModel = PasscodeViewModel(mode: .create, passcodeLength: 4)

        XCTAssertEqual(viewModel.enteredPasscode, "")
        XCTAssertNil(viewModel.confirmationPasscode)
        XCTAssertFalse(viewModel.showError)
        XCTAssertEqual(viewModel.passcodeLength, 4)
    }

    func testAddDigit() {
        let viewModel = PasscodeViewModel(mode: .create, passcodeLength: 4)

        viewModel.addDigit(1)
        XCTAssertEqual(viewModel.enteredPasscode, "1")

        viewModel.addDigit(2)
        XCTAssertEqual(viewModel.enteredPasscode, "12")

        viewModel.addDigit(3)
        viewModel.addDigit(4)
        XCTAssertEqual(viewModel.enteredPasscode, "1234")
        XCTAssertTrue(viewModel.isComplete)
    }

    func testDeleteDigit() {
        let viewModel = PasscodeViewModel(mode: .create, passcodeLength: 4)

        viewModel.addDigit(1)
        viewModel.addDigit(2)
        XCTAssertEqual(viewModel.enteredPasscode, "12")

        viewModel.deleteDigit()
        XCTAssertEqual(viewModel.enteredPasscode, "1")

        viewModel.deleteDigit()
        XCTAssertEqual(viewModel.enteredPasscode, "")

        // Delete on empty should not crash
        viewModel.deleteDigit()
        XCTAssertEqual(viewModel.enteredPasscode, "")
    }

    func testMaxLength() {
        let viewModel = PasscodeViewModel(mode: .create, passcodeLength: 4)

        viewModel.addDigit(1)
        viewModel.addDigit(2)
        viewModel.addDigit(3)
        viewModel.addDigit(4)

        // Should not exceed max length
        viewModel.addDigit(5)
        XCTAssertEqual(viewModel.enteredPasscode, "1234")
        XCTAssertEqual(viewModel.enteredPasscode.count, 4)
    }

    func testMoveToConfirmation() {
        let viewModel = PasscodeViewModel(mode: .create, passcodeLength: 4)

        viewModel.addDigit(1)
        viewModel.addDigit(2)
        viewModel.addDigit(3)
        viewModel.addDigit(4)

        viewModel.moveToConfirmation()

        XCTAssertEqual(viewModel.confirmationPasscode, "1234")
        XCTAssertEqual(viewModel.enteredPasscode, "")
        XCTAssertEqual(viewModel.titleText, "패스코드 확인")
    }

    func testValidateConfirmation_Success() {
        let viewModel = PasscodeViewModel(mode: .create, passcodeLength: 4)

        viewModel.addDigit(1)
        viewModel.addDigit(2)
        viewModel.addDigit(3)
        viewModel.addDigit(4)
        viewModel.moveToConfirmation()

        viewModel.addDigit(1)
        viewModel.addDigit(2)
        viewModel.addDigit(3)
        viewModel.addDigit(4)

        XCTAssertTrue(viewModel.validateConfirmation())
    }

    func testValidateConfirmation_Failure() {
        let viewModel = PasscodeViewModel(mode: .create, passcodeLength: 4)

        viewModel.addDigit(1)
        viewModel.addDigit(2)
        viewModel.addDigit(3)
        viewModel.addDigit(4)
        viewModel.moveToConfirmation()

        viewModel.addDigit(5)
        viewModel.addDigit(6)
        viewModel.addDigit(7)
        viewModel.addDigit(8)

        XCTAssertFalse(viewModel.validateConfirmation())
    }

    func testReset() {
        let viewModel = PasscodeViewModel(mode: .create, passcodeLength: 4)

        viewModel.addDigit(1)
        viewModel.addDigit(2)
        viewModel.moveToConfirmation()
        viewModel.showError(message: "Test error")

        viewModel.reset()

        XCTAssertEqual(viewModel.enteredPasscode, "")
        XCTAssertNil(viewModel.confirmationPasscode)
        XCTAssertFalse(viewModel.showError)
        XCTAssertEqual(viewModel.errorMessage, "")
    }

    func testTitleText() {
        let createVM = PasscodeViewModel(mode: .create, passcodeLength: 4)
        XCTAssertEqual(createVM.titleText, "패스코드 생성")

        let verifyVM = PasscodeViewModel(mode: .verify, passcodeLength: 4)
        XCTAssertEqual(verifyVM.titleText, "패스코드 입력")

        let changeVM = PasscodeViewModel(mode: .change, passcodeLength: 4)
        XCTAssertEqual(changeVM.titleText, "새 패스코드 생성")
    }

    func testCustomPasscodeLength() {
        let viewModel = PasscodeViewModel(mode: .create, passcodeLength: 6)

        XCTAssertEqual(viewModel.passcodeLength, 6)

        for i in 1...6 {
            viewModel.addDigit(i)
        }

        XCTAssertTrue(viewModel.isComplete)
        XCTAssertEqual(viewModel.enteredPasscode.count, 6)
    }
}
