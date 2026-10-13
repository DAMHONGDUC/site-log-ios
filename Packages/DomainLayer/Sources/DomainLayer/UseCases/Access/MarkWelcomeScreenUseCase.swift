public struct MarkWelcomeScreenUseCase {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute() async -> Result<Void, AccessError> {
        return await repository.markWelcomeScreen()
    }
}
