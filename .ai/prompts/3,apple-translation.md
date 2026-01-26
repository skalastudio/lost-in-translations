# Promp
Add a new translation provider that uses Apple’s built-in Translation services (no API key required) and integrate it into the existing provider architecture (protocol ProviderClient, existing providers: OpenAI/Claude/Gemini/Mock). This provider must allow users to use the app without configuring any external API_KEY.

Constraints / Current Architecture
- Provider implementations live in: Services/Providers/
- Provider selection + wiring is in: Services/
- There is a ProviderClient protocol that all providers conform to.
- Follow the same functionaliy of all the providers: Translate, Improve, Rephrase, Synonyms

Apple Translation Provider Requirements
1) Implement a new provider: AppleTranslationProviderClient (or similar name consistent with existing files)
   - Location: Services/Providers/AppleTranslation/
   - Conform to ProviderClient.
   - Does NOT require any API key.
   - Should support translating text between user-selected languages (2–3 target languages).
   - If Apple Translation does not support certain language pairs, return a clear user-facing error (and expose it to UI).

2) Decide and implement the translation mechanism:
   - Use Apple’s official Translation APIs available on Apple platforms.
   - Prefer on-device/system translation where available.
   - If the Translation API is async, implement using Swift concurrency (async/await).
   - Keep the implementation clean and testable (allow injection/mocking).

3) Deliverables
   - New provider implementation files
   - Updated provider factory / wiring
   - Updated settings UI and any model enums for provider type
   - Updated copy strings (localized if the project uses localization)
   - Tests passing
   - Run swift-format on touched files

Acceptance Criteria
- User can install and use the app to translate text with provider = “Apple Translation” without entering any API_KEY.
- Provider appears in UI provider selector.
- No API-key fields required/visible for Apple provider.
- Translations work for at least common languages (EN/PT/DE) when supported by the system.
- Graceful error when unsupported.
- Existing providers remain unchanged and functional.

Implementation Notes
- Keep naming consistent with the existing ProviderClient implementations.
- Don’t break the Mock provider; Apple is not a mock, it is a real provider.
- Prefer small changes per file and clean commits.

Now implement it.
