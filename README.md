# <Project Name>
_add info_

## Features
_add info_

## Requirements

- macOS 26.0 or later
- Xcode 26.0 or later with Swift 6.2

## Setup Instructions

### 1. Configure Internet Accounts
_add info_


### 2. Build and Run the App

1. Open the project in Xcode:
   ```bash
   open <Project Name>.xcodeproj
   ```

2. Select your development team in the project settings:
   - Click on the project in the navigator
   - Select the "<Prohect Name>" target
   - Go to "Signing & Capabilities"
   - Select your team from the dropdown

3. Build and run the project (Cmd + R)

4. Grant calendar access when prompted

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
- **Modern Async/Await**: Native async patterns for EventKit operations
- **LocalizedError**: User-facing error messages with proper descriptions
- **UserNotifications Framework**: Modern notification API replacing deprecated NSUserNotification


## Permissions

The app requires:
- **Calendar Access**: To read calendars and write to the unified calendar
- App Sandbox with calendar entitlement

Entitlements and prompts live here:
- `UnifiedCalendarSync/UnifiedCalendarSync.entitlements` controls the Calendar entitlement.
- `UnifiedCalendarSync/Info.plist` contains `NSCalendarsUsageDescription` (update if messaging changes).

## App Store Release Checklist

## Testing

### Running Tests
```bash
./scripts/test.sh
# or
xcodebuild test -project <ProjectName>.xcodeproj -scheme "Unified Calendar Sync" -destination 'platform=macOS'
```

**Note**: EventKit integration is verified manually during app runs because system permissions cannot be exercised reliably in unit tests.

## Privacy

This app respects your privacy:
- All calendar data stays on your local machine
- No data is sent to external servers
- No tracking or analytics
- The app only accesses calendars you've configured in macOS
- Includes Privacy Manifest (`PrivacyInfo.xcprivacy`) for App Store transparency

## Code Quality
See `.ai/reviews/` for detailed code review reports.

## Future Enhancements

## License

This project is provided as-is for personal use.

## Support
