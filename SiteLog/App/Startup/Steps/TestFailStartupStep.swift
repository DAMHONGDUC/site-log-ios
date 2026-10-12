struct TestFailStartupStep: StartupStep {
    let name: String = "TestFailStartupStep"
    let blocksLaunch: Bool = true

    func run() async throws {
        throw StartupFailure.keychain("test error")
    }

}
