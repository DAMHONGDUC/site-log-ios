// Stored form of the access settings; step 4 keeps it as JSON in UserDefaults
public struct AccessSettingModel: Codable, Sendable, Equatable {
    public var isShowWelcomeScreen: Bool
    public var isLockOn: Bool
    public var isFaceIdOn: Bool
    public var lockAfterSeconds: Int

    public init(
        isShowWelcomeScreen: Bool,
        isLockOn: Bool,
        isFaceIdOn: Bool,
        lockAfterSeconds: Int
    ) {
        self.isShowWelcomeScreen = isShowWelcomeScreen
        self.isLockOn = isLockOn
        self.isFaceIdOn = isFaceIdOn
        self.lockAfterSeconds = lockAfterSeconds
    }

    public static let firstLaunch = AccessSettingModel(
        isShowWelcomeScreen: false,
        isLockOn: true,
        isFaceIdOn: true,
        lockAfterSeconds: 10
    )
}
