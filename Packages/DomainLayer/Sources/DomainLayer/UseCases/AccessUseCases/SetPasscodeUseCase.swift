public struct SetPasscodeUseCase {
    private let repository: any AccessRepository

    public init(repository: any AccessRepository) {
        self.repository = repository
    }

    public func execute(passcode: String) async -> Bool {
        return await repository.setPasscode(passcode: passcode)
    }
}
