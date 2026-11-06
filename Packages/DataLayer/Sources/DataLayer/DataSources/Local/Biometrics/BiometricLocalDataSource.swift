// Face ID for the access flow
public protocol BiometricLocalDataSource: Sendable {
    func authenticate() async throws -> Bool
}
