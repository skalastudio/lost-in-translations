#!/usr/bin/env bash
set -euo pipefail

if command -v swiftlint >/dev/null 2>&1; then
  swiftlint lint
else
  echo "swiftlint not installed. Install with: brew install swiftlint" >&2
  exit 1
fi

if command -v swift-format >/dev/null 2>&1; then
  swift-format lint --recursive LostInTranslations/
else
  echo "swift-format not installed. Install with: brew install swift-format" >&2
  exit 1
fi
