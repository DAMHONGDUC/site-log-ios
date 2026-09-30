# 0003 — Node + PostgreSQL backend with a hand-written sync engine

Status: Accepted · 2026-09-30 · Specs: [08](../feature-docs/02-upload-sync.md#08-auth-and-sync), [14](../feature-docs/03-backend.md)

## Context

The backend must sign R2 URLs, countersign capture hashes, own all metadata, serve delta sync to
several devices, and push job state. Firebase is already used for identity and crash reporting.

## Decision

Node 22 + TypeScript + Fastify, PostgreSQL 16 with raw SQL. Sync is hand-written: cursor-based
delta pull, batched push, tombstones with a purge window, LWW per field, monotonic session state,
and an offline mutation queue in SwiftData on the device.

## Rejected

| Option | Why not |
|---|---|
| Firestore | Data model and queries tied to one vendor; hash countersigning and presigning still need a server |
| Supabase | Postgres, but row-level sync and conflict rules would still be ours |
| CloudKit | Apple-only; no server-side verification of evidence |

## Consequences

- Offline persistence, delete propagation and listener fan-out are ours (tombstones, `pg_notify`).
- Expect ~1800–2500 lines of TypeScript and a two-device convergence test (`P43`).
- Hosting, migrations and backups are operated by us.
