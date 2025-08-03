import 'package:flutter/material.dart';
import '../models/review_state.dart';
import '../services/review_manager.dart';

/// A banner widget that displays the review promotion flow
/// Automatically manages its own visibility based on internal state
class ReviewBanner extends StatefulWidget {
  /// Custom child widget to override default UI
  final Widget? child;

  /// Optional override to force hide the banner (rarely needed)
  final bool forceHide;

  /// Force show for debugging purposes (overrides all conditions)
  final bool debugForceShow;

  const ReviewBanner({
    Key? key,
    this.child,
    this.forceHide = false,
    this.debugForceShow = false,
  }) : super(key: key);

  @override
  State<ReviewBanner> createState() => _ReviewBannerState();
}

class _ReviewBannerState extends State<ReviewBanner> {
  late AppReviewManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = AppReviewManager.instance;
    _manager.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _manager.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug force show overrides everything
    if (widget.debugForceShow) {
      return _buildBannerContent();
    }

    // Force hide takes precedence (e.g., during privacy flow)
    if (widget.forceHide) {
      return const SizedBox.shrink();
    }

    // Check internal state managed by the review manager
    if (!_manager.state.isVisible) {
      return const SizedBox.shrink();
    }

    return _buildBannerContent();
  }

  Widget _buildBannerContent() {
    // If user provides custom child, use it
    if (widget.child != null) {
      return widget.child!;
    }

    // Default banner implementation
    return _buildDefaultBanner();
  }

  Widget _buildDefaultBanner() {
    final config = _manager.config;
    final style = config.style;

    return Container(
      margin: style?.margin ?? const EdgeInsets.all(8.0),
      padding: style?.padding ?? const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: style?.backgroundColor ?? Colors.blue[50],
        border: Border.all(
          color: style?.borderColor ?? Colors.blue[200]!,
          width: style?.borderWidth ?? 1.0,
        ),
        borderRadius: BorderRadius.circular(style?.borderRadius ?? 8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildMessage(),
          SizedBox(height: style?.spacing ?? 12.0),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    final config = _manager.config;
    final state = _manager.state;
    final style = config.style;

    String message;
    switch (state.step) {
      case ReviewStep.satisfaction:
        message = config.messages.initialQuestion;
        break;
      case ReviewStep.reviewRequest:
        final isSatisfied =
            state.satisfactionResponse == SatisfactionResponse.satisfied;
        message = config.messages.getSecondStepMessage(isSatisfied);
        break;
      case ReviewStep.thankYou:
        final agreedToReview = state.reviewResponse == ReviewResponse.agreed;
        message = config.messages.getFinalMessage(agreedToReview);
        break;
      default:
        message = '';
    }

    return Text(
      message,
      style: style?.messageTextStyle ??
          TextStyle(
            color: style?.messageTextColor ?? Colors.black87,
            fontSize: 14.0,
          ),
    );
  }

  Widget _buildButtons() {
    final state = _manager.state;

    // Don't show buttons in thank you step
    if (state.step == ReviewStep.thankYou) {
      return const SizedBox.shrink();
    }

    final config = _manager.config;

    return Row(
      children: [
        // 負向按鈕 (左側)
        Expanded(
          flex: 2, // 較小比例
          child: _buildButton(
            text: state.step == ReviewStep.satisfaction
                ? config.messages.initialNoButton
                : config.messages.secondNoButton,
            isPrimary: false,
            onPressed: () => _handleButtonPress(false),
          ),
        ),
        const SizedBox(width: 12.0), // 增加間距
        // 正向按鈕 (右側，更大更顯眼)
        Expanded(
          flex: 3, // 較大比例，更突出
          child: _buildButton(
            text: state.step == ReviewStep.satisfaction
                ? config.messages.initialYesButton
                : config.messages.secondYesButton,
            isPrimary: true,
            onPressed: () => _handleButtonPress(true),
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String text,
    required bool isPrimary,
    required VoidCallback onPressed,
  }) {
    final style = _manager.config.style;

    return SizedBox(
      height: 44.0, // 統一按鈕高度，符合觸控標準
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? (style?.primaryButtonBackgroundColor ??
                  Color(0xFF34C759)) // iOS 綠色
              : (style?.secondaryButtonBackgroundColor ?? Colors.grey[100]),
          foregroundColor: isPrimary
              ? (style?.buttonTextColor ?? Colors.white) // 正向按鈕文字顏色
              : (style?.secondaryButtonTextColor ??
                  Colors.grey[700]), // 負向按鈕文字顏色
          elevation: isPrimary ? 2.0 : 0.0, // 正向按鈕有陰影，負向按鈕扁平
          shadowColor: isPrimary ? Colors.black26 : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(style?.buttonBorderRadius ?? 10.0),
            side: isPrimary
                ? BorderSide.none // 正向按鈕無邊框
                : BorderSide(
                    // 負向按鈕有淺色邊框
                    color: style?.buttonBorderColor ?? Colors.grey[300]!,
                    width: 1.0,
                  ),
          ),
          textStyle: TextStyle(
            fontSize: 16.0, // 較大字體
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400, // 正向按鈕較粗
          ),
        ),
        child: Text(
          text,
          style: style?.buttonTextStyle,
        ),
      ),
    );
  }

  void _handleButtonPress(bool isPositive) {
    final state = _manager.state;

    switch (state.step) {
      case ReviewStep.satisfaction:
        _manager.handleSatisfactionResponse(isPositive);
        break;
      case ReviewStep.reviewRequest:
        _manager.handleReviewResponse(isPositive);
        break;
      default:
        break;
    }
  }
}
