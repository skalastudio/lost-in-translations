# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Unified Calendar Sync is a macOS menu bar application that syncs calendar events from multiple accounts (local, exchange, calDAV, mobileMe, subscribed, birthdays) into a single unified calendar (calDAV). Built with Swift 6.2, it uses EventKit for calendar integration and emphasizes strict concurrency safety with `@MainActor` annotations and modern async/await patterns.

## Essential Commands

### Building
```bash
./scripts/build.sh
```
Or directly:
```bash
xcodebuild clean build -project <ProjectName>.xcodeproj -scheme "<ProjectScheme>" -configuration Debug -destination 'platform=macOS' CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

### Testing
```bash
./scripts/test.sh
```
Uses Swift Testing framework (`import Testing`). Tests live in `<ProjectName>Tests/`.

### Linting
```bash
./scripts/lint.sh
```
Runs both `swiftlint` and `swift-format`. Install with:
```bash
brew install swiftlint swift-format
```

### Static Analysis
```bash
scripts/analyze.sh
```

### Running in Xcode
```bash
open <ProjectName>.xcodeproj
```
Select a development team under Signing & Capabilities, then press Cmd+R.

## Architecture

### Core Services Layer
_add info_

### UI Layer
_add info_

### Application Entry
_add info_

### State Management
_add info_

## Key Patterns

### Concurrency Model
- `@MainActor` on `AppSettings` ensures UI updates are main-thread safe
- Async/await throughout, no completion handlers

## Configuration Details
_add info_

### Permissions & Entitlements
_add info_

## Development Guidelines

### Swift 6.2 Requirements
- Strict concurrency checking enabled
- All shared mutable state must be `@MainActor` or use actors
- Types crossing concurrency boundaries must be `Sendable`
- Use structured concurrency (async/await, TaskGroup) not dispatch queues

### Testing Strategy
- Use Swift Testing framework, not XCTest

### Code Style
- 4-space indentation
- UpperCamelCase for types/files, lowerCamelCase for properties/methods
- Run `swift-format` and `swiftlint` before committing

### Important Notes for AI Agents
- **Log all AI prompts/responses** in `.ai/prompts/logs.md` (see `AGENTS.md`)
- When modifying sync logic, consider impact on existing unified calendar events

----

# Claude Apple Ecosystem Code Review Specialist
The following file descript the instructions defined: [Specialist](./SPECIALIST.md)
