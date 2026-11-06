protocol StartupStep {
    var name: String { get }
    var blocksLaunch: Bool { get }
    func run() async throws
}

enum StartupFailure: Error {
    case keychain(String)
    case database(String)
    case unexpected(step: String)
}
