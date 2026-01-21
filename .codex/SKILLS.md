---
name: <project-name>
description: <project-description>
---

# Codex Skill

Use this skill whenever you work in this repository: implement features, fix bugs, refactor, review code, or run build/quality checks.

## Technical Skills
- You are an expert in macOS development, proficient in Swift, SwiftUI and EventKit.
- You always enforce the Apple development guidelines
- You always implement the features to be safe for App Store submission
- You are an expert on concurrency guidelines following the Approachable Concurrency model, Actor Isolation as MainActor
- You are an expert on Apple APIs and always check the available Apple documentation
- This app must follow macOS 26.0 and Swift 6.2
- For testing use the `Swift Testing` framework, the latest Apple testing framework. 

## Repo overview
- This is a macOS menu bar app that detects calendars configured in macOS, creates a unified calendar (customizable name, default: **"Unified Calendar"**), and syncs events from multiple accounts with deduplication, updates, and configurable auto-sync (intervals: 2, 5, 10, 15, 30, 60 minutes; default: 15) - [README](README.md)
- Features a comprehensive Settings panel for calendar selection, event prefixes, sync configuration, and launch at login
- It uses Swift 6.2 with strict concurrency checks (e.g., `@MainActor`, `Sendable`) and modern async/await patterns. 

## Golden rules (must follow)
1. Follow `AGENTS.md` as the highest-priority repo guidance. [AGENTS.md](AGENTS.md)
2. Log **every AI prompt + response** in `.ai/prompts/logs.md` in Markdown, including:
   - model name
   - timestamp
   - prompt text
   - model output [AGENTS.md](AGENTS.md)
3. Be careful with permissions/entitlements: Calendar access is mandatory; call out changes to entitlements or sync range. 

## Project structure (where to look)
_add info_

## Local setup & run (Xcode)
- Open the project:
  - `open <ProjectName>.xcodeproj` 
- In Xcode: select your dev team under **Signing & Capabilities**.
- Run the app (Cmd+R) and grant Calendar access when prompted. [README](README.md)

## Build/test/analyze commands (CLI)
Use these exact commands (CI-mirroring, no signing):

- Build:
  - `xcodebuild clean build -project <ProjectName>.xcodeproj -scheme "<ProjectSchema>" -configuration Debug -destination 'platform=macOS' CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO` [AGENTS.md](AGENTS.md)
- Test (if/when test target exists):
  - `xcodebuild test -project <ProjectName>.xcodeproj -scheme "<ProjectSchema>" -destination 'platform=macOS' CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO` [AGENTS.md](AGENTS.md)
- Static analysis:
  - `xcodebuild analyze -project <ProjectName>.xcodeproj -scheme "<ProjectSchema>" -configuration Debug -destination 'platform=macOS'` [AGENTS.md](AGENTS.md)

Quality checks used by CI:
- `swiftlint lint` [AGENTS.md](AGENTS.md)
- `swift-format lint --recursive <ProjectSchema>/` [AGENTS.md](AGENTS.md)

## Coding style & naming
- 4-space indentation; keep formatting consistent with existing files. [AGENTS.md](AGENTS.md)
- `UpperCamelCase` for types/files, `lowerCamelCase` for vars/methods. [AGENTS.md](AGENTS.md)
- Prefer Swift 6.2 concurrency annotations (`@MainActor`, `Sendable`) to avoid data races. 
- Run `swift-format` + `swiftlint` before pushing when possible. [AGENTS.md](AGENTS.md)

## Domain-specific guardrails 
__add info__

## Key files (architecture map)
__add info__

## Testing guidance
- Tests live in `<ProjectName>Tests/` and use Swift Testing (`import Testing`).

## Commit expectations
- Use short, imperative commit messages (e.g., “Add sync timeout”).

## How to finish a task (required output)
When you complete work, include:
- What changed (1–3 bullets)
- Files touched
- Commands run (build/lint/test/analyze)
- Any permission/sync-range implications
- And add the AI log entry to `.ai/prompts/logs.md`. [AGENTS.md](AGENTS.md)
