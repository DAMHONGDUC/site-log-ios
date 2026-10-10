# Reporting and security

<dl><dd>

- The paid deliverable and the protection of the evidence behind it.

</dd></dl>

## Contents

<dl><dd>

- [05 PDF and spreadsheet export](#05-pdf-and-spreadsheet-export) — sections, rendering, spreadsheet
- [07 Security and audit log](#07-security-and-audit-log) — at rest, app lock, audit log, leaks and secrets

---

</dd></dl>

## 05. PDF and spreadsheet export

<dl><dd>

- Module: `Packages/DataLayer/Sources/DataLayer/DataSources/Local/Reporting`

**Goal:** turn a `Session` into a branded, signed PDF plus CSV/XLSX, shareable on the spot with no
network — never truncated, never missing images, never crashing on page 38 of 40.

| In | Out |
|---|---|
| Branded cover, summary by severity / floor / assignee | Fully custom per-company layouts (v2) |
| Plan pin maps, checklist tables, issue blocks with annotated photos | PKI digital signatures — these are handwritten signatures with internal acceptance value, and the app says so |
| Before/after pairs, stale-issue section, two-party signature page | |
| Grouping by location or by assignee (a parameter, not a second code path) | |
| PDF + CSV/XLSX via Files / `UIActivityViewController` | |

### 05.1 Sections

<dl><dd>

| Section | Source |
|---|---|
| Cover — project, client, dates, surveyor, logo | Project + `ReportBranding` |
| Summary — counts by severity, floor, assignee | Issues |
| Plan pin maps, one page per sheet | [11](01-field-work.md#11-floor-plans-and-issue-pins) |
| Checklist results per location | [13](01-field-work.md#13-checklist-templates) |
| Issue detail, before/after pairs, stale issues | [03](01-field-work.md#03-issues-and-before-after-pairing), [12](01-field-work.md#12-annotation-and-verifiable-stamps) |
| Signatures | `PencilKit` PNG + `signedAt`, `signerName`, `signerRole` per party |

```swift
struct ReportBranding: Codable, Sendable {
    let companyName: String
    let logoFileURL: URL?
    let accentColorHex: String
    let clientBlock: String
    let footerNote: String
}
```

- Branding: one `report_branding` row per user; the logo uploads like any file.
- Signing sets `Session.state = .exported` (read-only); re-signing creates a `-R2` revision, keeps the original.

</dd></dl>

### 05.2 Rendering

<dl><dd>

- `UIGraphicsPDFRenderer`: no third-party library, no WebView printing (HTML→PDF with 200 images
  gives blank pages).

```
Session → SessionSnapshot (one fetch) → ReportLayoutEngine (pure, no UIKit) → [ReportPage]
        → PDFPageRenderer (UIKit, one autoreleasepool per page) → temp file → atomic move → share
```

| Rule | Reason |
|---|---|
| Layout counts images, renderer draws them | Guarantees no dropped evidence |
| `CGImageSourceCreateThumbnailAtIndex` to `maxImagePixelSize` | 160 full-size `UIImage`s = jetsam |
| Background queue; `@MainActor` gets progress only | |
| Temp file + `moveItem` | A kill mid-render never leaves a partial file |
| Renders the stamped, annotated derivative | The archive keeps the clean original |

**Integrity on every page**

- Under each image: first 8 hash characters, the code and its state (`registered`/`verified`), time
  confidence when below `.serverVerified`.
- Unsynced captures print "not yet verified".
- Final page: SHA-256 over the `captureID`-sorted hash list.
- Spacing, color and type come from `SystemDesign` tokens, inside the PDF too.

**Spreadsheet**

- CSV always; XLSX above `csvOnlyRowThreshold`; streamed with `FileHandle`.
- One row per issue: `report_id, project, session_date, location_code, plan_sheet, pin_x, pin_y,
  issue_id, title, detail, severity, status, assignee, trade, due_date, capture_count,
  first_capture_sha256, verification_code, created_at`.

```swift
enum ReportConstants {
    static let pageSize: CGSize = CGSize(width: 595, height: 842)   // A4 @72dpi
    static let margin: CGFloat = 40
    static let imagesPerRow: Int = 2
    static let maxImagePixelSize: CGFloat = 1400
    static let jpegCompressionQuality: CGFloat = 0.8
    static let hashPrefixLength: Int = 8
    static let staleIssueSessionThreshold: Int = 3
    static let csvOnlyRowThreshold: Int = 5000
    static let maxLogoPixelSize: CGFloat = 600
}
```

| Risk | Handling |
|---|---|
| Image missing from disk | Placeholder "Image no longer on device — {hash}"; never crash or skip |
| Non-ASCII file names | Percent-encode on share; test with "Ánh Dương – Block B" |
| Too large for chat apps | Show estimated size first, offer a compression level |

**Done**

- 200 images / 40 issues on a low-end iPhone under 200 MB peak
- Image count equals non-excluded capture count (asserted)
- Pairs matched and labeled with `Location.code`
- Works in airplane mode

**Tests**

- Image count
- Empty / 1 / 500 issues
- 20-image issue paginates
- Missing file placeholder
- Hash-of-hashes order-stable
- Both groupings give the same total
- CSV escaping
- "not yet verified"
- Pin numbering matches detail
- 200-image memory
- Opens in Preview and Acrobat

---

</dd></dl>

</dd></dl>

## 07. Security and audit log

<dl><dd>

- Modules: `SiteLog/Presentation/Access/` (`FaceIDLock`, `PasscodeUnlock`, `PrivacyOverlay`), `SiteLog/Presentation/Settings/AppLock`, `Domain`

**Goal:** media and reports are unreadable if the device is lost, unmodifiable without a trace, and
never leaked into logs or analytics.

### 07.1 At rest

<dl><dd>

| Data | Protection |
|---|---|
| Media, plans, upload temp parts | `FileProtectionType.completeUnlessOpen` |
| SwiftData store | `.complete` |
| Export bundles leaving the app | AES-GCM (CryptoKit), per-bundle key |
| Audit chain | HMAC-SHA256 (CryptoKit), key in Keychain |
| Firebase tokens | Keychain, `.whenUnlockedThisDeviceOnly` |

**Why not AES-GCM for media**

- Background `URLSession` uploads only raw files on disk → encrypted media needs a plaintext temp copy
  for the whole upload window: worse than nothing, and double the disk.
- `.completeUnlessOpen` encrypts on lock but keeps open files readable, which background upload needs.
- `.complete` would stop uploads when the phone goes into a pocket.

</dd></dl>

### 07.2 App lock

<dl><dd>

| Screen | Purpose |
|---|---|
| S4 **Settings → Privacy → App lock** | Two groups: *Lock app*, *Lock after* |
| S5 | Set passcode |
| A1 | Face ID unlock |
| A3 | App passcode unlock |

| Setting | Values | Default |
|---|---|---|
| Lock app | On / Off | Off |
| Passcode | 6 digits, app-only; required before Lock app turns on | — |
| Unlock with Face ID | On / Off; hidden when the device has no biometrics | On once a passcode is set |
| Lock after | Immediately · 1 minute · 5 minutes · 15 minutes · 1 hour | 5 minutes |

| Rule | Detail |
|---|---|
| Turning on | Set passcode (enter + confirm) first, then offer Face ID |
| Turning off, changing passcode | Requires the current passcode or Face ID |
| Face ID | `LAContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics)`; fallback button is the **app** passcode (Face ID fails under helmets and masks) |
| Biometry changed | `evaluatedPolicyDomainState` differs from the stored one → Face ID off, passcode required |
| Passcode storage | Never stored: PBKDF2-SHA256 + 16-byte random salt, Keychain `.whenUnlockedThisDeviceOnly` (not in backups) |
| Wrong attempts | 5 free, then waits of 1 · 5 · 15 · 60 min; counter and wait-until in Keychain, so killing the app does not reset them |
| Forgot passcode | Device-owner check (`.deviceOwnerAuthentication`, device passcode) → set a new app passcode; no data erased |
| When it locks | Cold launch, and foreground return after *Lock after*, measured with `ContinuousClock` (not `Date()`) |
| App switcher | Privacy overlay on resign-active while Lock app is on |

- A UI gate on `RootView`, not encryption (on a sheet it would be bypassable by killing the app).
- Sensitive Keychain items use `.biometryCurrentSet`.

</dd></dl>

### 07.3 Audit log

<dl><dd>

- Records every view, delete, export, report exclusion, metadata change, pin move, annotation edit.

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

- The chain makes edits and deletions detectable.
- Key generated once, never leaves the device.
- Verified at launch; a break raises a Diagnostics flag and a Crashlytics non-fatal.
- Entries survive project deletion.
- Losing the key on device migration is accepted: the log is per device, and Diagnostics says so.

</dd></dl>

### 07.4 Leaks and secrets

<dl><dd>

| Rule | Detail |
|---|---|
| Never log presigned URLs, tokens, Keychain values | They carry credentials |
| Never log user text | Log `issueID`, not `issue.detail` (names, unit and phone numbers) |
| Crashlytics and analytics | IDs and enums only; no free text, no GPS |
| Logger | `os.Logger`, `privacy: .private` by default; no `print` |
| Secrets | `GoogleService-Info.plist` and endpoints written by CI; `.xcconfig` per env, `.example` committed; R2 keys only on the backend |
| Privacy | GPS disclosed in onboarding and disableable; `PrivacyInfo.xcprivacy` declares location, device ID, crash data; account deletion is immediate locally, within 30 days on the server |

```swift
enum SecurityConstants {
    static let lockAfterOptions: [Duration] = [.zero, .seconds(60), .seconds(300), .seconds(900), .seconds(3600)]
    static let defaultLockAfter: Duration = .seconds(300)
    static let passcodeLength: Int = 6
    static let passcodeSaltBytes: Int = 16
    static let passcodePBKDF2Rounds: UInt32 = 210_000
    static let freePasscodeAttempts: Int = 5
    static let passcodeLockoutSteps: [Duration] = [.seconds(60), .seconds(300), .seconds(900), .seconds(3600)]
    static let keychainService: String = "app.dd.site.log.keys"
    static let auditHMACKeyTag: String = "app.dd.site.log.audit.hmac"
    static let exportKeyLengthBytes: Int = 32
}
```

**Done**

- A locked device's media is unreadable via file sharing or unencrypted backup
- Background upload continues while locked
- A hand-edited entry fails at the right index
- No `print(`
- A 20-photo session's logs hold no URL, token or free text

**Tests**

- 100-entry chain verifies
- Edit at 50 and mid-chain deletion detected at the right index
- AES-GCM bundle round-trip
- Wrong key throws
- New files carry the expected protection
- `.biometryCurrentSet` unreadable before auth
- Redaction snapshot
- Passcode hash round-trip and wrong passcode rejected
- Lockout steps survive relaunch
- Lock after boundary (just under / at the value)
- Biometry change turns Face ID off

</dd></dl>

</dd></dl>
