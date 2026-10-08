# TianfuGlass

A private, minimal iOS 27 app using App Intents and SwiftUI snippets to display a QR code passed from Apple Shortcuts.

## Status

The v0.3 diagnostic build is intended to investigate a system Snippet presentation issue where only the Done button appears. Compilation is not proof that Snippet rendering works on-device.

No real boarding codes, cookies, or account tokens belong in this repository.

## Build

GitHub Actions uses Xcode 27 to generate an **unsigned** iOS IPA. The IPA needs signing before it can be installed on an unmodified iPhone.
