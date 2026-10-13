public struct UnlockWithBiometricsUseCase {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute() async -> Bool {
        return await repository.unlockWithBiometrics()
    }
}
