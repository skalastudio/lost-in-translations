# Repository Guidelines

## Project Structure & Module Organization
_add info_

## Build, Test, and Development Commands

- `open <ProjectName>.xcodeproj` opens the project in Xcode; select a team under Signing & Capabilities.
- `xcodebuild clean build -project <ProjectName>.xcodeproj -scheme "<ProjectScheme>" -configuration Debug -destination 'platform=macOS' CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO` builds locally without signing (mirrors CI).
- `xcodebuild test -project <ProjectName>.xcodeproj -scheme "<ProjectScheme>" -destination 'platform=macOS' CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO` runs tests if a test target exists.
- `xcodebuild analyze -project <ProjectName>.xcodeproj -scheme "<ProjectScheme>" -configuration Debug -destination 'platform=macOS'` runs static analysis.
- `swiftlint lint` and `swift-format lint --recursive <ProjectName>/` are used by CI for code quality checks.
- `scripts/build.sh`, `scripts/test.sh`, `scripts/analyze.sh`, and `scripts/lint.sh` wrap the same commands for local use.


## Coding Style & Naming Conventions

- Swift uses 4-space indentation; keep formatting consistent with existing files.
- Types and file names use `UpperCamelCase` (e.g., `MenuBarController.swift`); variables and methods use `lowerCamelCase`.
- Prefer Swift 6.2 concurrency annotations (`@MainActor`, `Sendable`) where appropriate; avoid data races.
- Run `swift-format` and `swiftlint` before pushing when possible.

## Testing Guidelines

- Tests live in `<ProjectName>Tests/` and use Swift Testing (`import Testing`).
- Keep tests focused on sync logic; avoid direct EventKit access in unit tests when feasible.

## Commit Guidelines

- No strict commit convention appears in history; use short, imperative messages (e.g., "Add sync timeout").
- Note any permission or entitlement changes, especially Calendar access.

## Configuration & Permissions Notes

- Requires macOS 26+ and Xcode 26 with Swift 6.2.
- Calendar access is mandatory; document any changes to entitlements or sync ranges in PRs.

## AI Log Prompts

- Log every AI prompt and response in `.ai/prompts/logs.md` using Markdown.
- Each entry must include: model name, timestamp, prompt text, and model output.
