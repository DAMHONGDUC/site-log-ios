public struct AccessSetting: Sendable {
    public var isShowWelcomeScreen: Bool
    public var isLockOn: Bool
    public var isFaceIdOn: Bool
    public var lockAfterTime: Duration

    public init(
        isShowWelcomeScreen: Bool,
        isLockOn: Bool,
        isFaceIdOn: Bool,
        lockAfterTime: Duration
    ) {
        self.isShowWelcomeScreen = isShowWelcomeScreen
        self.isLockOn = isLockOn
        self.isFaceIdOn = isFaceIdOn
        self.lockAfterTime = lockAfterTime
    }
}
