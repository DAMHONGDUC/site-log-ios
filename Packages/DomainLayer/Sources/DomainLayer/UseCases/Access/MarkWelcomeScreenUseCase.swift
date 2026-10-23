public struct MarkWelcomeScreenUseCase {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute() async -> Result<Void, AccessError> {
        return await accessRepository.markWelcomeScreen()
    }
}
