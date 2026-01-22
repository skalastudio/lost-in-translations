---
name: lost-in-translations
description: Repo-specific workflow, structure, and conventions for the "Lost In Translations" macOS menu bar app.
---

# Lost In Translations (macOS) — Codex Skill

Use this skill whenever you work in this repository: implement features, fix bugs, refactor, review code, or run build/quality checks.

## Technical Skills
- You are an expert in macOS development, proficient in Swift, SwiftUI and Foundation Model Framework.
- You always enforce the Apple development guidelines
- You always implement the features to be safe for App Store submission
- You are an expert on concurrency guidelines following the Approachable Concurrency model, Actor Isolation as MainActor
- You are an expert on Apple APIs and always check the available Apple documentation
- This app must follow macOS 14+ and Swift 6.2
- For testing use the `Swift Testing` framework, the latest Apple testing framework. 

## Repo overview
- This is a macOS menu bar app that perform translations using LLMs - [README](README.md)
- It uses Swift 6.2 with strict concurrency checks (e.g., `@MainActor`, `Sendable`) and modern async/await patterns. 

## Golden rules (must follow)
1. Follow `-codex/AGENTS.md` as the highest-priority repo guidance. [AGENTS.md](.codex/AGENTS.md)
2. Log **every AI prompt + response** in `.ai/logs/session-log.md` in Markdown, including:
   - model name
   - timestamp
   - prompt text
   - model output [AGENTS.md](.codex/AGENTS.md)
3. Be careful with permissions/entitlements:

## Local setup & run (Xcode)
- Open the project:
  - `open LostInTranslations.xcodeproj` 
- In Xcode: select your dev team under **Signing & Capabilities**.
- Run the app (Cmd+R) and grant Calendar access when prompted. [README](README.md)

## Build/test/analyze commands (CLI)
Use these exact commands (CI-mirroring, no signing):

- Build: use `scripts/build.sh`
- Test (if/when test target exists): use `scripts/test.sh`
- Static analysis: use `scripts/analyze.sh`

Quality checks used by CI:
- `swiftlint lint` [AGENTS.md](.codex/AGENTS.md)
- `swift-format lint --recursive UnifiedCalendarSync/` [AGENTS.md](.codex/AGENTS.md)

## Coding style & naming
- 4-space indentation; keep formatting consistent with existing files. [AGENTS.md](AGENTS.md)
- `UpperCamelCase` for types/files, `lowerCamelCase` for vars/methods. [AGENTS.md](AGENTS.md)
- Prefer Swift 6.2 concurrency annotations (`@MainActor`, `Sendable`) to avoid data races. 
- Run `swift-format` + `swiftlint` before pushing when possible. [AGENTS.md](AGENTS.md)

## Testing guidance
- Tests live in `LostInTranslationsTests/` and use Swift Testing (`import Testing`).
- Prefer testing sync logic; avoid direct EventKit access in unit tests when feasible. [AGENTS.md](.codex/AGENTS.md)

## How to finish a task (required output)
When you complete work, include:
- What changed (1–3 bullets)
- Files touched
- Commands run (build/lint/test/analyze)
- Any permission/sync-range implications
- And add the AI log entry to `.ai/logs/session-log.md`. [AGENTS.md](.codex/AGENTS.md)

## Codex code Dhanged
After any code changed run:
build: `scripts/build.sh` and check errors and warnings, if exists errors fix them and do this until no errors and warnings max 3 times
