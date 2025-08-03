import 'package:flutter/material.dart';
import '../services/review_manager.dart';
import 'review_banner.dart';

/// A dialog widget that displays the review promotion flow
class ReviewDialog extends StatelessWidget {
  const ReviewDialog({Key? key}) : super(key: key);

  /// Show the review dialog if conditions are met
  static Future<void> showIfNeeded(BuildContext context) async {
    final manager = AppReviewManager.instance;

    if (manager.state.isVisible) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const ReviewDialog(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: ReviewBanner(),
      ),
    );
  }
}
