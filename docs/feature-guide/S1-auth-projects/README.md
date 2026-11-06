# S1 — Auth and projects

<dl><dd>

- Sprint 1 · 2 weeks · 56h · [all sprints](../README.md)

</dd></dl>

## Contents

<dl><dd>

1. [Overview](#overview)
2. [Tasks](#tasks)
3. [Done](#done)
4. [Self-check](#self-check)

</dd></dl>

## Overview

<dl><dd>

- **Goal:** real sign-in next to Continue offline; projects, sessions and locations stored on the device with sync-ready fields.
- **Demo — offline:** Continue offline → project → 80 generated locations → walkthrough; relaunch keeps everything.
- **Demo — signed in:** Sign in with Apple or email → same flow; the backend has the project tables and rejects calls without a token.

| F | Feature | Guide | Hours |
|---|---|---|---|
| F02 | Auth | [F02-auth.md](F02-auth.md) | 21 |
| F03 | Projects, sessions, locations | [F03-projects.md](F03-projects.md) | 35 |

```mermaid
flowchart LR
    subgraph App["iOS app"]
        SignIn["A2 Sign in"] --> AuthRepo["AuthRepositoryImpl"]
        AuthRepo --> AuthDS["AuthRemoteDataSourceImpl"]
        Projects["P1–P7 Projects"] --> ProjectRepo["ProjectRepositoryImpl"]
        ProjectRepo --> ProjectDS["ProjectLocalDataSourceImpl"]
        ProjectDS --> SD[("SwiftData")]
    end
    AuthDS --> FB["Firebase Auth"]
    subgraph BE["Backend"]
        Guard["requireUser"] --> Tables[("projects · locations · sessions")]
    end
    App -->|"Bearer ID token"| Guard
```

</dd></dl>

## Tasks

<dl><dd>

| Task | Step | Layer | Hours | Status |
|---|---|---|---|---|
| F02.1 | Auth contract: token, account deletion | Contract | 1 | not start |
| F02.2 | Auth types and use cases | Domain | 1 | not start |
| F02.3 | `AuthRemoteDataSourceImpl` in memory | Fake data | 1 | not start |
| F02.4 | Sign in, account, sign out view models | View models | 4 | not start |
| F02.5 | Firebase Auth inside the data source (split: Apple · email · token) | Local | 10 | not start |
| F02.6 | [site-log-be F02](https://github.com/DAMHONGDUC/site-log-be/blob/main/docs/feature-guide/S1-auth-projects/F02-auth.md): `requireUser`, `DELETE /account` | Backend | 4 | not start |
| F03.1 | Project, session, location contract | Contract | 1 | not start |
| F03.2 | Sync-ready entities, protocols, use cases | Domain | 4 | not start |
| F03.3 | Repositories + data sources in memory | Fake data | 2 | not start |
| F03.4 | Projects view models (split: list · detail · survey · bulk) | View models | 10 | not start |
| F03.5 | SwiftData models, schema, data sources (split: models · data sources · schema) | Local | 15 | not start |
| F03.6 | [site-log-be F03](https://github.com/DAMHONGDUC/site-log-be/blob/main/docs/feature-guide/S1-auth-projects/F03-projects.md): `0001_projects.sql` | Backend | 3 | not start |

</dd></dl>

## Done

<dl><dd>

- [ ] Offline demo on a real device, airplane mode
- [ ] Signed-in demo: Apple and email sign-in; relaunch offline after sign-in goes straight in
- [ ] Backend: a call without a token → `401`; project tables migrate on an empty database
- [ ] F02 and F03 tests written and green

</dd></dl>

## Self-check

<dl><dd>

- Why does every entity get a client-made `UUID` instead of a server id?
- A2 has two ways in. Which screens must behave the same in both?
- Projects are not synced yet in S1. Which fields already prepare them for S2?

</dd></dl>
