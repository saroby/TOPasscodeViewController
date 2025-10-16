# TOPasscodeViewController - 아키텍처 문서

## 프로젝트 구조

```
TOPasscodeViewController/
├── Package.swift                    # Swift Package 설정
├── README.md                        # 사용자 문서
├── ARCHITECTURE.md                  # 아키텍처 문서 (현재 파일)
├── Sources/                         # 메인 소스 코드
│   ├── PasscodeView.swift          # 메인 패스코드 화면
│   ├── PasscodeViewModel.swift     # 상태 관리 및 비즈니스 로직
│   ├── PasscodeDotsView.swift      # 입력 진행 상태 UI
│   ├── NumberKeypadView.swift      # 숫자 키패드 UI
│   └── PasscodeViewModifier.swift  # View extension
├── Examples/                        # 사용 예제
│   └── PasscodeExampleView.swift   # 완전한 사용 예제
└── Tests/                           # 테스트 코드
    └── PasscodeViewModelTests.swift # ViewModel 단위 테스트
```

## 아키텍처 패턴

### MVVM (Model-View-ViewModel)

이 프로젝트는 SwiftUI의 MVVM 패턴을 따릅니다:

- **View**: `PasscodeView`, `PasscodeDotsView`, `NumberKeypadView`
- **ViewModel**: `PasscodeViewModel`
- **Model**: `PasscodeMode` enum

### 데이터 흐름

```
User Input (NumberKeypad)
    ↓
ViewModel (@Published properties)
    ↓
View Updates (Automatic)
    ↓
Completion Callback
```

## 주요 컴포넌트

### 1. PasscodeView

메인 패스코드 입력 화면. 모든 하위 컴포넌트를 조합합니다.

**책임:**
- UI 레이아웃 구성
- 사용자 입력 처리
- 완료/취소 이벤트 관리
- 모드별 로직 분기

**주요 속성:**
```swift
@StateObject private var viewModel: PasscodeViewModel
let mode: PasscodeMode
let onComplete: (String) -> Void
let onCancel: (() -> Void)?
```

### 2. PasscodeViewModel

상태 관리와 비즈니스 로직을 담당하는 ViewModel.

**책임:**
- 패스코드 입력 상태 관리
- 확인 모드 로직 처리
- 생체 인증 통합
- 에러 상태 관리
- 햅틱 피드백 제공

**주요 속성:**
```swift
@Published var enteredPasscode: String
@Published var confirmationPasscode: String?
@Published var showError: Bool
@Published var canUseBiometrics: Bool
```

**주요 메서드:**
```swift
func addDigit(_ digit: Int)
func deleteDigit()
func moveToConfirmation()
func validateConfirmation() -> Bool
func authenticateWithBiometrics(completion: @escaping (Bool) -> Void)
```

### 3. PasscodeDotsView

입력 진행 상태를 시각적으로 표시하는 컴포넌트.

**책임:**
- 입력된 자릿수 시각화
- 에러 상태 애니메이션 (shake effect)
- 상태 변화 애니메이션

**특징:**
- 커스텀 `ShakeEffect` geometry effect
- 자연스러운 scale/opacity 애니메이션

### 4. NumberKeypadView

숫자 입력을 위한 키패드 UI.

**책임:**
- 0-9 숫자 버튼 제공
- 삭제 버튼 제공
- 햅틱 피드백 생성
- 터치 애니메이션

**특징:**
- 3x4 그리드 레이아웃
- 커스텀 `ScaleButtonStyle`
- UIImpactFeedbackGenerator 통합

### 5. PasscodeViewModifier

SwiftUI View extension을 위한 modifier.

**책임:**
- 간편한 API 제공 (`.passcode()` modifier)
- fullScreenCover 프레젠테이션 관리
- 자동 dismiss 처리

## 상태 관리

### Published Properties

ViewModel은 `@Published` 속성을 사용하여 View에 자동으로 업데이트를 전파합니다:

```swift
@Published var enteredPasscode: String = ""
// View에서 자동 구독 및 업데이트
```

### State Flow

```
Initial State
    ↓
[User enters digits] → addDigit()
    ↓
[Passcode complete] → moveToConfirmation() (for create/change modes)
    ↓
[User confirms] → validateConfirmation()
    ↓
[Success] → onComplete callback
    ↓
[Failure] → showError() → reset()
```

## 보안 고려사항

### 1. 메모리 관리

- 패스코드는 String으로 메모리에 유지 (최소 시간)
- 완료 후 즉시 클리어 권장
- Keychain 저장 시 암호화 권장

### 2. 생체 인증

- LocalAuthentication 프레임워크 사용
- 자동 fallback 지원
- 에러 처리 철저

### 3. UI 보안

- 화면 캡처 방지 권장 (추가 구현 필요)
- 백그라운드 진입 시 가림 권장

## 애니메이션 시스템

### 1. 입력 애니메이션

```swift
.animation(.easeInOut(duration: 0.2), value: enteredCount)
```

### 2. 에러 애니메이션

```swift
.modifier(ShakeEffect(animatableData: isError ? 1 : 0))
```

### 3. 버튼 애니메이션

```swift
.scaleEffect(configuration.isPressed ? 0.92 : 1.0)
.animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
```

## 확장성

### 커스터마이징 포인트

1. **색상 테마**: 모든 Color 값을 테마 시스템으로 교체 가능
2. **패스코드 길이**: `passcodeLength` 파라미터로 조절
3. **키패드 레이아웃**: `NumberKeypadView` 수정으로 변경 가능
4. **애니메이션**: 각 View의 animation modifier 조정

### 추가 기능 제안

1. **다크모드 지원**: 자동 (SwiftUI 기본 제공)
2. **로컬라이제이션**: Localizable.strings 추가
3. **접근성**: VoiceOver 레이블 추가
4. **커스텀 키패드**: 문자 입력 지원
5. **실패 제한**: N회 실패 시 잠금

## 테스트 전략

### 단위 테스트

- ViewModel 로직 테스트 (`PasscodeViewModelTests.swift`)
- 입력/삭제/검증 기능 커버리지

### UI 테스트 (추가 권장)

- 사용자 플로우 시나리오
- 생체 인증 통합
- 에러 케이스 처리

### 통합 테스트 (추가 권장)

- 전체 create → verify 플로우
- 모드 전환 시나리오
- Keychain 통합

## 성능 최적화

### 현재 최적화

1. **@StateObject**: ViewModel 생명주기 관리
2. **LazyVGrid**: 키패드 효율적 렌더링
3. **Haptic 최적화**: generator 재사용

### 추가 최적화 제안

1. **애니메이션 최적화**: drawingGroup() 사용
2. **메모리 프로파일링**: Instruments로 확인
3. **렌더링 최적화**: shouldRasterize 고려

## 의존성

### 시스템 프레임워크

- **SwiftUI**: UI 구현
- **LocalAuthentication**: 생체 인증
- **Combine**: 반응형 프로그래밍
- **UIKit**: 햅틱 피드백 (UINotificationFeedbackGenerator)

### 외부 의존성

- 없음 (완전히 독립적인 모듈)

## 버전 관리

### 시맨틱 버저닝

- **Major**: 호환성 깨지는 변경
- **Minor**: 기능 추가 (호환)
- **Patch**: 버그 수정

현재 버전: **2.0.0** (SwiftUI 리라이트)

## 기여 가이드

1. Feature 브랜치에서 작업
2. 코드 스타일: SwiftLint 규칙 따르기
3. 모든 public API에 문서화 주석
4. 단위 테스트 작성 필수
5. Pull Request 전 테스트 통과 확인

## 라이선스

MIT License - 자유롭게 사용 및 수정 가능
