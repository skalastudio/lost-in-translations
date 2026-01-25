# Lost in Translations
Lost in Translations is a macOS 14+ mac app for translation, rewriting, and synonym suggestions using LLM providers (OpenAI, Anthropic Claude, Google Gemini). It's built with Swift 6.2 and SwiftUI, targeting the Mac App Store.


## Features
- User can input text to translate in any language and when press translate, it will translate into the defined languages.
- The user can define max 3 languages to be translated in one call 
- The user can define the type target message: email, message, chat 
- The user can define the type of tone  
- The user can use to get synonyms, improve a messsage
- The user can use audio input to right the message
- The app allows using different LLM providers (OpenAI, Anthropic Claude, Google Gemini)
- The app allows set the API key for each provider 
- The app allows to set the model for each provider (and by default suggest the more appropriated models and with less costs)
- The app if no API Key is defined, the list of providers will be disabled. Only providers with API keys will be enabled.

## Requirements

- macOS 14.0 or later
- Xcode 26.0 or later with Swift 6.2

## Setup Instructions

### 1. Configure API Keys Accounts
1. Go to Settings and set the API Keys for each provider 


### 2. Build and Run the App

- The scripts to build, analize and tests user a `${TMPDIR}` to perform the builds
- Xcode use the folders defined on "Settings/Locations" > `~/Library/Developer/Xcode/DerivedData`

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
