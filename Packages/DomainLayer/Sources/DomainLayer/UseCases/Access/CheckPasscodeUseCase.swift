public struct CheckPasscodeUseCase {
    private let accessRepository: any AccessRepository

    public init(repository accessRepository: any AccessRepository) {
        self.accessRepository = accessRepository
    }

    public func execute(passcode: String) async -> Result<PasscodeCheck, AccessError> {
        return await accessRepository.checkPasscode(inputPasscode: passcode)
    }
}
