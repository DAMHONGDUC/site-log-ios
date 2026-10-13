public enum PasscodeCheck: Sendable {
    case success
    case wring(triesLeft: Int)
    case lockedOut(wait: Duration)
}