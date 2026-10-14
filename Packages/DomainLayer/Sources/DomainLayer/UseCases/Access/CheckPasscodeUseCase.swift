public struct CheckPasscodeUseCase {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute(passcode: String) async -> Result<PasscodeCheck, AccessError> {
        return await repository.checkPasscode(inputPasscode: passcode)
    }
}
