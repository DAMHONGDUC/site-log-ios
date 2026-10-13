import DomainLayer

public actor AccessRepositoryImpl: AccessRepository {
    private static let initSetting = AccessSetting(
        isShowWelcomeScreen: false,
        isLockOn: true,
        isFaceIdOn: true,
        lockAfterTime: .seconds(10)
    )

    private var setting = initSetting

    public init() {}

    public func loadAccessSetting() async -> Result<AccessSetting, AccessError> {
        return .success(setting)
    }

    public func saveAccessSetting(setting: AccessSetting) async -> Result<Void, AccessError> {
        return .success(())
    }

    public func markWelcomeScreen() async -> Result<Void, AccessError> {
        return .success(())
    }

    public func checkPasscode(passcode: String) async -> Result<PasscodeCheck, AccessError> {
        return .success(.success)
    }

    public func setPasscode(passcode: String) async -> Result<Void, AccessError> {
        return .success(())
    }

    public func unlockWithBiometrics() async -> Result<Bool, AccessError> {
        return .success(false)
    }

}
