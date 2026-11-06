public struct SetPasscodeUseCase {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute(passcode: String) async -> Result<Void, AccessError> {
        return await accessRepository.setPasscode(newPasscode: passcode)
    }
}
