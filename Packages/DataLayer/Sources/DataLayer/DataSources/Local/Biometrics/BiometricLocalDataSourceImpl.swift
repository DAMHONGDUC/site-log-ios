// Until step 4: Face ID waits a moment, then always matches
public struct BiometricLocalDataSourceImpl: BiometricLocalDataSource {
    public init() {}

    public func authenticate() async throws -> Bool {
        try await Task.sleep(for: .milliseconds(5))
        return true
    }
}
