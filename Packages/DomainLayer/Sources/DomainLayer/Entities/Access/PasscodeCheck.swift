public enum PasscodeCheck: Sendable {
    case correct
    case wrong(triesLeft: Int)
    case lockedOut(wait: Duration)
}
