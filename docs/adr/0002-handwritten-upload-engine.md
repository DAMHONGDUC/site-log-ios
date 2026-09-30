# 0002 — Hand-written upload engine on background `URLSession`

Status: Accepted · 2026-09-30 · Spec: [04](../feature-docs/02-upload-sync.md#04-upload-engine)

## Context

A session produces 150–250 files and several GB that must reach R2 through network loss, app
suspension, OS termination, reboot, and presigned-URL expiry. This is the product's core claim.

## Decision

`UploadKit` is written in-house on a background `URLSessionConfiguration`: its own job store
protocol, state machine, S3 multipart with resume, retry with jittered backoff, and relaunch
reconciliation. It imports nothing from the project.

## Rejected

| Option | Why not |
|---|---|
| Alamofire | Foreground sessions; no background-session relaunch or task ↔ job reconciliation |
| Firebase Storage `putFile()` | Cannot reattach after cold launch; no control over `isDiscretionary` or priority |
| AWS Amplify / S3 SDK | Heavy; hides the background session and its lifecycle |

## Consequences

- Full control of retry, priority, Wi-Fi policy and URL refresh.
- The largest block of work in the roadmap (`P16`–`P21`) and the most test surface: state machine,
  `MockTransport` scripting 503/403/timeouts, kill-and-relaunch tests.
