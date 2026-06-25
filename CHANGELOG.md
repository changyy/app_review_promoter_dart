# Changelog

## [1.1.0]

### Added
- Built-in store navigation: the package can now take the user to the store/system
  review itself (previously the host had to wire it via `onReviewRequested`).
- `ReviewMode` (`system` / `storeListing`) and per-platform `PlatformReviewConfig`
  on `ReviewConfig` (`ios` / `android` / `macos` / `windows`). When a platform is
  left null it defaults to `system` (native `requestReview()`).
- `onReviewRequest` handler (`ReviewRequestHandler`): runs first; return `true` to
  stop, `false` to fall through to the package default. `ReviewContext` exposes the
  current platform, app version, and `runPackageDefault`.
- `markEngagement()`: bump tracked usage to the threshold and re-evaluate, so the
  prompt can appear on an explicit engagement signal without waiting for the timer.
- `StoreReviewLauncher` abstraction with default `InAppReviewLauncher` (injectable
  for tests). Added `in_app_review` dependency.

### Behavior
- `storeListing` opens the store page directly (reliable for explicit "rate" intent),
  avoiding the OS-throttled, undetectable native `requestReview()`.
- iOS/macOS `storeListing` requires a store id; if missing (or the store fails to
  open) it falls back to the native prompt. Android uses the running package name.

### Compatibility
- Fully backward compatible: existing `onReviewRequested` still works and is treated
  as "handled". With no handler and no per-platform config, behavior is unchanged
  (native prompt path), so upgrading needs no code changes.

## [1.0.3] - 2025-08-10

### Added
- Button ratio configuration feature - customize width ratio between positive and negative buttons
- New `positiveButtonFlex` and `negativeButtonFlex` parameters in `ReviewStyle`
- Comprehensive button ratio example demonstrating various ratio configurations
- Documentation for button ratio feature usage and best practices

### Changed
- Improved button layout implementation with flexible width ratios
- Enhanced button text rendering with auto-scaling for better responsiveness
- Converted all Chinese comments to English for better international collaboration

### Example
```dart
ReviewStyle(
  positiveButtonFlex: 3,  // Positive button takes 3 parts width
  negativeButtonFlex: 2,  // Negative button takes 2 parts width
)
```

## [1.0.2] - 2025-08-03

### Changed
- Simplified README.md documentation for better readability
- Removed redundant sections and overly detailed platform-specific examples
- Condensed documentation from 426 lines to 154 lines while maintaining essential information

## [1.0.1] - 2025-08-03

### Added
- Complete example application demonstrating all package features
- Example includes debug tools for testing review flows
- Example shows custom configuration and styling options
- Added comprehensive example documentation

### Fixed
- Updated pubspec.yaml with correct repository URLs
- Fixed dart analyze issues in example code

## [1.0.0] - 2025-08-03

### Added
- Initial release of app_review_promoter package
- Smart timing-based review prompts (configurable usage duration)
- Multi-step user engagement flow (satisfaction → review request)
- Version-specific tracking (only prompts once per app version)
- Fully customizable messages and styling
- Custom review action callbacks
- Built-in analytics support
- ReviewBanner and ReviewDialog UI components
- Persistent storage for user choices and usage tracking

### Features
- ⏰ Configurable minimum usage time before showing prompts
- 🔄 Two-step flow: satisfaction survey followed by review request
- 📱 Automatic version tracking and management
- 🎨 Complete UI customization (colors, fonts, spacing, etc.)
- 📊 Analytics events with custom callback support
- 🏪 Custom store/review action handling
- 💾 Persistent storage using SharedPreferences
- 🧪 Comprehensive testing support

### API
- `AppReviewManager`: Core singleton manager for review flow
- `ReviewConfig`: Configuration class for all customization options
- `ReviewMessages`: Complete message customization
- `ReviewStyle`: UI styling and appearance customization
- `ReviewBanner`: Banner widget for displaying review prompts
- `ReviewDialog`: Dialog widget for modal review prompts
- `ReviewStorageService`: Internal storage management

### Platform Support
- ✅ Android
- ✅ iOS  
- ✅ Linux
- ✅ macOS
- ✅ Windows
- ✅ Web