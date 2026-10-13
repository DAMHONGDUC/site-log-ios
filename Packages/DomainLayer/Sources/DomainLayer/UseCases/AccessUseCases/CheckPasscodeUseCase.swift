public struct CheckPasscodeUseCase {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute(passcode: String) async -> PasscodeCheck {
        return await repository.checkPasscode(passcode: passcode)
    }
}
