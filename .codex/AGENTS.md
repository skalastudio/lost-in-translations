# Repository Guidelines

## Project Structure & Module Organization
- `README.md` describes the app goals, requirements, and setup steps.
- `scripts/` holds build/test/lint helpers for Xcode.
- `design/` is reserved for design assets (currently empty).
- `.ai/` contains product notes and prompt history for internal reference.
- Source code lives under `LostInTranslations/` with the Xcode project at `LostInTranslations.xcodeproj`.

## Build, Test, and Development Commands
- `./scripts/build.sh` runs a Debug build via `xcodebuild` without code signing.
- `./scripts/test.sh` executes the macOS test scheme.
- `./scripts/analize.sh` runs Xcode static analysis (note the script name is `analize.sh`).
- `./scripts/lint.sh` runs `swiftlint` and `swift-format` (requires `brew install swiftlint swift-format`).
- `./scripts/user-defaults-reset.sh --full-reset` clears preferences and optionally removes the sandbox container for first-run testing.

## Coding Style & Naming Conventions
- Swift formatting is enforced by `.swift-format`; lint rules live in `.swiftlint.yml`.
- Prefer Swift 6.2 concurrency patterns (actors, async/await) as outlined in `README.md`.
- Keep module and folder names aligned with the active Xcode project name to avoid mismatches in scripts.

## Testing Guidelines
- Test execution is driven by `xcodebuild test` via `./scripts/test.sh`.
- Schemes are configured in the Xcode project; the test script targets `LostInTranslations`.
- Use the reset script for deterministic first-run test coverage when needed.

## Commit & Pull Request Guidelines
- There is only one commit in history, so no established message convention yet.
- Use clear, imperative commit messages (e.g., `Add calendar sync mock fixtures`).

## Security & Configuration Tips
- Calendar access requires entitlements in `LostInTranslations/LostInTranslations.entitlements` (per README).
- Keep privacy-related changes documented in `PrivacyInfo.xcprivacy` if present in the project.
