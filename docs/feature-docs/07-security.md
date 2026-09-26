# 07 — Security & audit log

Modules: `App/Features/Security`, `Core`

## 1. Goal

Media and reports are acceptance evidence: unreadable if the device is lost, unmodifiable without a
trace, never leaked into logs or analytics.

## 2. At-rest: Data Protection, not AES-GCM for media

- Background `URLSession` uploads only raw files on disk ([04](04-upload-engine.md)).
- AES-GCM media would have to be decrypted to a plaintext temp file before every upload.
- That leaves the content in the clear for the whole upload window, in the background.
- Hand-rolled encryption there makes security **worse** than doing nothing, and doubles disk use.

| Data | Protection |
|---|---|
| Media, plans | `FileProtectionType.completeUnlessOpen` — hardware AES-256, key tied to passcode |
| SwiftData store | `.complete` |
| Upload part temp files | `.completeUnlessOpen`, deleted after PUT |
| Export bundles leaving the app | **AES-GCM (CryptoKit)**, per-bundle key |
| Audit log chain | **HMAC-SHA256 (CryptoKit)**, key in Keychain |
| Firebase tokens | Keychain, `.whenUnlockedThisDeviceOnly` |

`.completeUnlessOpen` is the load-bearing choice:

- Files encrypt when the device locks, but already-open files stay readable — what background upload needs.
- `.complete` would kill uploads the moment the phone goes into a pocket, which is the entire use case.

CryptoKit is used where it is genuinely correct: export bundles and the audit chain, both of which
leave iOS's protection domain.

## 3. Face ID

- `LAContext.evaluatePolicy(.deviceOwnerAuthentication)` — passcode fallback, because Face ID fails
  under helmets and masks.
- Gates cold launch and foreground return after `lockTimeout`.
- App-switcher overlay on `sceneWillResignActive`.
- **A UI gate, not data encryption** — the table above is the encryption.
- Sensitive Keychain items use `SecAccessControl` with `.biometryCurrentSet`.
- The gate belongs on `RootView`; on a sheet it is bypassable by killing the app.

## 4. Audit log

Records every view, delete, export, report exclusion, metadata change, pin move, and annotation edit.

```swift
struct AuditEntry: Codable, Sendable {
    let id: UUID
    let action: AuditAction
    let subjectID: String
    let actorID: String            // Firebase uid
    let occurredAt: Date
    let previousEntryHMAC: String
    let hmac: String               // HMAC-SHA256(key, canonical(fields) + previousEntryHMAC)
}
```

- The chain makes deletion or modification detectable; without it the log is a notes table anyone
  with DB access can edit.
- Key generated once, Keychain `.whenUnlockedThisDeviceOnly`, never leaves the device.
- Verified asynchronously at launch; a break raises a Diagnostics flag ([09](09-diagnostics.md)) and
  a Crashlytics non-fatal.
- Entries are never deleted by user action, including project deletion.

## 5. Leak prevention

| Rule | Detail |
|---|---|
| Never log presigned URLs, tokens, Keychain values | They carry credentials |
| Never log user-entered text | Descriptions may contain names, unit numbers, phone numbers — log `issueID`, not `issue.detail` |
| Analytics/Crashlytics take IDs and enums only | No free text, no GPS |
| `deviceModel` allowed; `identifierForVendor` only in crash reports | |
| No `print` | `Logger` (os.log), `privacy: .private` by default |

```swift
logger.info("Report exported", metadata: [
    "sessionID": "\(session.id)", "pageCount": "\(pages)", "bytes": "\(size)"
])
// NOT: "\(session.note)", "\(presignedURL)", "\(user.email)"
```

## 6. Secrets & privacy

- `GoogleService-Info.plist` and endpoints are not committed; CI writes them from secrets.
- **R2 credentials live only on the backend** — the app never sees an access key. That is the point
  of presigned URLs.
- Per-environment `.xcconfig`; real files gitignored, `.example` committed.
- Photos carry GPS: disclosed in onboarding, disableable in settings.
- `PrivacyInfo.xcprivacy` declares location, device ID, crash data.
- Account deletion removes server data within 30 days and local data immediately.

```swift
enum SecurityConstants {
    static let lockTimeout: TimeInterval = 300
    static let keychainService: String = "com.sitelog.keys"
    static let auditHMACKeyTag: String = "com.sitelog.audit.hmac"
    static let exportKeyLengthBytes: Int = 32
}
```

## 7. Known risks

| Risk | Position |
|---|---|
| HMAC key lost on device migration | Accepted — the log is per-device; state it in Diagnostics rather than raise a false alarm |
| `.completeUnlessOpen` allows reads while unlocked | Deliberate trade-off for background upload, documented in the threat model |

## 8. Definition of done

- Locked device: media unreadable via file sharing or unencrypted backup.
- Background upload continues while locked.
- Hand-editing an `AuditEntry` fails verification at the right index.
- `grep -rn "print(" Sources/` returns nothing.
- A 20-photo session's logs contain no signed URL, token, or free text.

## 9. Tests

| Test | Kind |
|---|---|
| 100-entry HMAC chain verifies | unit |
| Modifying entry 50 is detected at the right index | unit |
| Deleting a mid-chain entry is detected | unit |
| AES-GCM export bundle round-trips byte-identically | unit |
| Wrong key throws instead of returning garbage | unit |
| New files carry the expected `FileProtectionType` | integration |
| `.biometryCurrentSet` item unreadable before auth | integration, device |
| Redaction: entries and log metadata contain no free text | unit, snapshot |
