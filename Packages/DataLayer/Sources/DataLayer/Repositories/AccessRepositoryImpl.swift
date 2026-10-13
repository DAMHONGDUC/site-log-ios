import DomainLayer

public actor AccessRepositoryImpl: AccessRepository {
    private static let initSetting = AccessSetting(
        isShowWelcomeScreen: false,
        isLockOn: true,
        isFaceIdOn: true,
        lockAfterTime: .seconds(10)
    )

    private var setting = initSetting
    private var passcode = "123456"
    private var freeTries = 5
    private var wrongTries = 0

    public init() {}

    public func loadAccessSetting() async -> Result<AccessSetting, AccessError> {
        return .success(setting)
    }

    public func saveAccessSetting(newSetting: AccessSetting) async -> Result<Void, AccessError> {
        setting = newSetting
        return .success(())
    }

    public func markWelcomeScreen() async -> Result<Void, AccessError> {
        setting.isShowWelcomeScreen = true
        return .success(())
    }

    public func checkPasscode(inputPasscode: String) async -> Result<PasscodeCheck, AccessError> {
        // correct
        if inputPasscode == passcode {
            wrongTries = 0
            return .success(.correct)
        }

        // error
        wrongTries += 1
        let triesLeft = freeTries - wrongTries
        if triesLeft >= 1 {
            return .success(.wrong(triesLeft: triesLeft))
        }

        // lockout
        return .success(.lockedOut(wait: .seconds(60)))

    }

    public func setPasscode(newPasscode: String) async -> Result<Void, AccessError> {
        passcode = newPasscode
        wrongTries = 0
        return .success(())
    }

    public func unlockWithBiometrics() async -> Result<Bool, AccessError> {
        // TODO: impl this on step 4
        do {
            try await Task.sleep(for: .milliseconds(5))

        } catch {
            return .failure(.biometricsUnavailable)
        }

        return .success(true)
    }

    // Dev menu
    #if DEBUG
        public func reset() {
            setting = AccessRepositoryImpl.initSetting
            passcode = "123456"
            wrongTries = 0
        }

        public func seed() {
            setting.isShowWelcomeScreen = false
        }
    #endif
}
