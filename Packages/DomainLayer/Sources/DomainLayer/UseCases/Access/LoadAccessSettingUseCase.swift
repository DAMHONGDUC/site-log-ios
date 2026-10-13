public struct LoadAccessSettingUseCase {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute() async -> Result<AccessSetting, AccessError> {
        return await repository.loadAccessSetting()
    }
}
