public struct SaveAccessSettingUseCase {

    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute(setting: AccessSetting) async -> Result<Void, AccessError> {
        return await repository.saveAccessSetting(setting: setting)
    }
}
