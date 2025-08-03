/// A Flutter package for intelligently promoting app reviews with customizable
/// timing and multi-step user engagement flow.
///
/// This package provides a comprehensive solution for encouraging users to
/// leave app reviews at optimal moments, with smart timing based on usage
/// duration and version tracking to avoid repetitive prompts.
library app_review_promoter;

// Export all public APIs

// Core models
export 'src/models/review_config.dart';
export 'src/models/review_state.dart';
export 'src/models/review_analytics.dart';

// Services
export 'src/services/review_manager.dart';
export 'src/services/storage_service.dart';

// UI Components
export 'src/widgets/review_banner.dart';
export 'src/widgets/review_dialog.dart';

// Constants
export 'src/utils/constants.dart';
