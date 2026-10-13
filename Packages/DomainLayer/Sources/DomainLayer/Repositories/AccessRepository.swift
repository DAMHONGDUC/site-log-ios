public protocol AccessRepository: Sendable {
    func loadAccessSetting() async -> Result<AccessSetting, AccessError>
    func saveAccessSetting(setting: AccessSetting) async -> Result<Void, AccessError>
    func markWelcomeScreen() async -> Result<Void, AccessError>
    func checkPasscode(passcode: String) async -> Result<PasscodeCheck, AccessError>
    func setPasscode(passcode: String) async -> Result<Void, AccessError>
    func unlockWithBiometrics() async -> Result<Bool, AccessError>
}
