# Lost in Translations
_add info_

## Features
_add info_

## Requirements

- macOS 14.0 or later
- Xcode 26.0 or later with Swift 6.2

## Setup Instructions

### 1. Configure Internet Accounts
_add info_


### 2. Build and Run the App

1. Open the project in Xcode:
   ```bash
   open LostInTranslations.xcodeproj
   ```

2. Select your development team in the project settings:
   - Click on the project in the navigator
   - Select the LostInTranslations target
   - Go to "Signing & Capabilities"
   - Select your team from the dropdown

3. Build and run the project (Cmd + R)

Optional CLI testing:
```bash
./scripts/test.sh
```

Optional reset (first-run testing):
```bash
./scripts/user-defaults-reset.sh
# Use --full-reset to remove the sandbox container (prompts for confirmation).
```

### 3. Using the App
### 4. First Sync

## How It Works
## Architecture

### Key Components

### Swift 6.2 Features

This app demonstrates modern Swift 6.2 best practices:
- **Strict Concurrency Checking**: Complete data-race safety with explicit `@MainActor` annotations on all UI and EventKit classes
- **Default MainActor Isolation**: Project-wide configuration (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- **Sendable Conformance**: All data types crossing actor boundaries properly marked (including nested enums)
- **Structured Concurrency**: Task-based async patterns, no DispatchQueue or completion handlers
- **LocalizedError**: User-facing error messages with proper descriptions
- **UserNotifications Framework**: Modern notification API replacing deprecated NSUserNotification


## Permissions

Entitlements and prompts live here:
- `LostInTranslations/LostInTranslations.entitlements` controls the Calendar entitlement.

## App Store Release Checklist

## Testing

### Running Tests
```bash
./scripts/test.sh
# or
xcodebuild test -project LostInTranslations.xcodeproj -scheme "LostInTranslations" -destination 'platform=macOS'
```

## Privacy

This app respects your privacy:
- All calendar data stays on your local machine
- No data is sent to external servers
- No tracking or analytics
- The app only accesses calendars you've configured in macOS
- Includes Privacy Manifest (`PrivacyInfo.xcprivacy`) for App Store transparency

## Code Quality
See `.ai/reviews/` for detailed code review reports.
