public struct UnlockWithBiometricsUseCase {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute() async -> Result<Bool, AccessError> {
        return await repository.unlockWithBiometrics()
    }
}
