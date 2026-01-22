#!/usr/bin/env bash
set -euo pipefail

project="LostInTranslations.xcodeproj"
scheme="Lost In Translations"
derived_data_path="build/DerivedData"
build_products_path="${derived_data_path}/Build/Products"
obj_root="${derived_data_path}/Build/Intermediates.noindex"

xcodebuild clean build \
  -project "${project}" \
  -scheme "${scheme}" \
  -configuration Debug \
  -destination 'platform=macOS' \
  -derivedDataPath "${derived_data_path}" \
  OBJROOT="${obj_root}" \
  SYMROOT="${build_products_path}" \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
