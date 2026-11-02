// In-memory values until step 4 moves them to Keychain and UserDefaults; same type, same methods
public actor AccessLocalDataSourceImpl: AccessLocalDataSource {
    private static let demoPasscode = "123456"

    private var setting = AccessSettingModel.firstLaunch
    private var passcode = AccessLocalDataSourceImpl.demoPasscode
    private var wrongTries = 0

    public init() {}

    public func loadSetting() -> AccessSettingModel {
        return setting
    }

    public func saveSetting(model: AccessSettingModel) {
        setting = model
    }

    public func verifyPasscode(inputPasscode: String) -> Bool {
        return inputPasscode == passcode
    }

    public func savePasscode(newPasscode: String) {
        passcode = newPasscode
    }

    public func loadWrongTries() -> Int {
        return wrongTries
    }

    public func saveWrongTries(count: Int) {
        wrongTries = count
    }

    public func deleteAll() {
        setting = AccessSettingModel.firstLaunch
        passcode = AccessLocalDataSourceImpl.demoPasscode
        wrongTries = 0
    }
}
