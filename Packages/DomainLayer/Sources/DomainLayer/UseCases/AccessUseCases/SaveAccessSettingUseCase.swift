public struct SaveAccessSettingUseCase {

    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute(setting: AccessSetting) async -> Bool {
        return await repository.saveAccessSetting(setting: setting)
    }
}
