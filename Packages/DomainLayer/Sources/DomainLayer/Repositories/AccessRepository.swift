public protocol AccessRepository: Sendable {
    func loadAccessSetting() async -> Result<AccessSetting, AccessError>
    func saveAccessSetting(newSetting: AccessSetting) async -> Result<Void, AccessError>
    func markWelcomeScreen() async -> Result<Void, AccessError>
    func checkPasscode(inputPasscode: String) async -> Result<PasscodeCheck, AccessError>
    func setPasscode(newPasscode: String) async -> Result<Void, AccessError>
    func unlockWithBiometrics() async -> Result<Bool, AccessError>
}
