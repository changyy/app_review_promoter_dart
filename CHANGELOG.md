# Changelog

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