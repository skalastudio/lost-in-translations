#!/usr/bin/env bash
set -euo pipefail

project="LostInTranslations.xcodeproj"
scheme="LostInTranslations"
derived_data_path="${TMPDIR}LostInTranslations-DerivedData"

xcodebuild analyze \
  -project "${project}" \
  -scheme "${scheme}" \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath "${derived_data_path}" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
