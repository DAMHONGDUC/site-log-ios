# Architecture decision records

One file per decision that is expensive to reverse. Each record states the context, the decision,
the options rejected, and the consequences. A superseded record stays, marked `Superseded by NNNN`.

| # | Decision | Status |
|---|---|---|
| [0001](0001-factory-di.md) | Factory for dependency injection | Accepted |
| [0002](0002-handwritten-upload-engine.md) | Hand-written upload engine on background `URLSession` | Accepted |
| [0003](0003-node-postgres-sync.md) | Node + PostgreSQL backend with a hand-written sync engine | Accepted |
| [0004](0004-websocket-realtime.md) | WebSocket realtime channel | Accepted |
| [0005](0005-kingfisher-images.md) | Kingfisher for remote images | Accepted |
| [0006](0006-test-libraries.md) | Swift Testing + swift-snapshot-testing + FactoryTesting | Accepted |
| [0007](0007-firebase-crashlytics.md) | Firebase Crashlytics for crash reporting | Accepted |
| [0008](0008-xcodegen.md) | XcodeGen owns the Xcode project | Accepted |

Template: copy any record, keep the four sections, add a row above.
