public struct LoadAccessSettingUseCase {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute() async -> Result<AccessSetting, AccessError> {
        return await accessRepository.loadAccessSetting()
    }
}
