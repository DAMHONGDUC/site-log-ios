public struct SaveAccessSettingUseCase {

    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute(setting: AccessSetting) async -> Result<Void, AccessError> {
        return await accessRepository.saveAccessSetting(newSetting: setting)
    }
}
