public struct UnlockWithBiometricsUseCase {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute() async -> Result<Bool, AccessError> {
        return await accessRepository.unlockWithBiometrics()
    }
}
