public protocol AccessRepository: Sendable {
    func loadAccessSetting() async -> AccessSetting
    func saveAccessSetting(setting: AccessSetting) async -> Bool
    func markWelcomeScreen() async -> Bool
    func checkPasscode(passcode: String) async -> PasscodeCheck
    func setPasscode(passcode: String) async -> Bool
    func unlockWithBiometrics() async -> Bool
}
