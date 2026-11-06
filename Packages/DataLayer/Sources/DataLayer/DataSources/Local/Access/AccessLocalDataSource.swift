// Storage for the access flow; returns stored models, never entities
public protocol AccessLocalDataSource: Sendable {
    func loadSetting() async throws -> AccessSettingModel
    func saveSetting(model: AccessSettingModel) async throws
    func verifyPasscode(inputPasscode: String) async throws -> Bool
    func savePasscode(newPasscode: String) async throws
    func loadWrongTries() async throws -> Int
    func saveWrongTries(count: Int) async throws
    func deleteAll() async throws
}
