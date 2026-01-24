# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Lost in Translations is a macOS 14+ mac app for translation, rewriting, and synonym suggestions using LLM providers (OpenAI, Anthropic Claude, Google Gemini). It's built with Swift 6.2 and SwiftUI, targeting the Mac App Store.

## Build & Development Commands

```bash
# Build (debug)
./scripts/build.sh

# Run tests (uses mock scheme for isolation)
./scripts/test.sh

# Lint (swiftlint + swift-format)
./scripts/lint.sh

# Reset UserDefaults for first-run testing
./scripts/user-defaults-reset.sh          # preferences only
./scripts/user-defaults-reset.sh --full-reset  # full sandbox reset

# Open in Xcode
open LostInTranslations.xcodeproj

# Manual test command
xcodebuild test -project LostInTranslations.xcodeproj -scheme "LostInTranslations" -destination 'platform=macOS'
```

**Required tools:** `brew install swiftlint swift-format`

## Code Style

- **Line length:** 120 characters
- **Indentation:** 4 spaces
- **Disabled SwiftLint rules:** `trailing_comma`, `opening_brace`
- Run `./scripts/lint.sh` before committing

## Architecture

**Pattern:** MVVM with async/await throughout

**Swift 6.2 Concurrency Requirements:**
- `@MainActor` on all UI and EventKit classes
- `Sendable` conformance for all data types crossing actor boundaries
- Structured concurrency with Task-based patterns (no DispatchQueue or completion handlers)

**Key Components:**
- Menu bar popover with TextEditor input
- Mode controls: Translate / Improve / Synonyms
- Intent picker: Email / SMS / Chat / Plain Text
- Tone picker: Formal / Informal / Professional / Friendly / Direct
- Provider picker: Auto / OpenAI / Claude / Gemini (BYOK model)
- Model tier selector: Fast / Balanced / Best (advanced mode shows exact models)
- Multi-language output: 2-3 target languages simultaneously

**Data Persistence:**
- API keys: Keychain only (never UserDefaults)
- Preferences: AppStorage
- History (optional): SwiftData local storage

**Provider Clients:**
- URLSession-based, Codable JSON parsing
- OpenAI: chat/completions endpoint
- Anthropic: messages endpoint
- Gemini: generateContent endpoint
- Handle missing keys, rate limits, and provider-specific errors with user-friendly messages

## Testing

Uses Swift Testing framework (`import Testing`), not XCTest. Test scheme includes "(Mocks)" for isolated testing.

## Privacy & Security

- No external servers for app logic
- No tracking or analytics
- API keys stored exclusively in Keychain
- Privacy Manifest (`PrivacyInfo.xcprivacy`) for App Store compliance
