# Session State (2026-01-26)

## Status
- Apple Translation provider integrated and wired; capabilities now disable unsupported modes.
- macOS deployment target set to 15.0.

## Latest change (not yet committed)
- Overlays in Improve/Rephrase/Synonyms now explicitly say the selected provider only supports Translate.
- Localization updated accordingly.

## Files touched since last commit
- `LostInTranslations/Views/ImproveModeView.swift`
- `LostInTranslations/Views/RephraseModeView.swift`
- `LostInTranslations/Views/SynonymsModeView.swift`
- `LostInTranslations/Resources/en.lproj/Localizable.strings`

## Commands already run
- `swift-format --in-place --recursive LostInTranslations`
- `bash scripts/lint.sh`
- `bash scripts/build.sh` (succeeded; only AppIntents metadata warning)

## Notes
- Provider selection UI lives in Settings → General; no toolbar provider picker.
- Modes remain visible but disabled when unsupported by the selected provider.
- Apple Translation still guards features with macOS 15+ and uses Translation APIs.
