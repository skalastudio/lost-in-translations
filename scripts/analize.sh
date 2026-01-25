#!/usr/bin/env bash
set -euo pipefail

project="LostInTranslations.xcodeproj"
scheme="LostInTranslations"
derived_data_path="${TMPDIR}LostInTranslations-DerivedData"
arch="$(uname -m)"

xcodebuild analyze \
  -project "${project}" \
  -scheme "${scheme}" \
  -configuration Debug \
  -destination 'platform=macOS,arch=${arch}' \
  -derivedDataPath "${derived_data_path}" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
