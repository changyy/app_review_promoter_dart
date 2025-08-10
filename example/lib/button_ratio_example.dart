import 'package:flutter/material.dart';
import 'package:app_review_promoter/app_review_promoter.dart';

/// Button Ratio Example - Demonstrates how to customize the width ratio between positive and negative buttons
class ButtonRatioExample extends StatelessWidget {
  const ButtonRatioExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Button Ratio Example'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Button Ratio Configuration Examples',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 1. Default ratio 1:1
            const Text('1. Default Ratio (1:1)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildExampleBanner(
              title: 'Default ratio: Both buttons have equal width',
              positiveButtonFlex: null, // Uses default value 1
              negativeButtonFlex: null, // Uses default value 1
            ),
            const SizedBox(height: 20),

            // 2. Positive button wider 3:2
            const Text('2. Positive Button Wider (3:2)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildExampleBanner(
              title: 'Positive button wider: Encourages user clicks',
              positiveButtonFlex: 3,
              negativeButtonFlex: 2,
            ),
            const SizedBox(height: 20),

            // 3. Positive button much wider 2:1
            const Text('3. Positive Button Much Wider (2:1)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildExampleBanner(
              title: 'Positive button much wider: Emphasizes positive response',
              positiveButtonFlex: 2,
              negativeButtonFlex: 1,
            ),
            const SizedBox(height: 20),

            // 4. Negative button wider 1:2 (Not recommended)
            const Text('4. Negative Button Wider (1:2) - Not Recommended',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildExampleBanner(
              title: 'Negative button wider: Not recommended design',
              positiveButtonFlex: 1,
              negativeButtonFlex: 2,
            ),
            const SizedBox(height: 20),

            // 5. Extreme ratio 4:1
            const Text('5. Extreme Ratio (4:1)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _buildExampleBanner(
              title: 'Extreme ratio: Heavily emphasizes positive button',
              positiveButtonFlex: 4,
              negativeButtonFlex: 1,
            ),
            const SizedBox(height: 30),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('📖 Usage Guide',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8),
                    Text(
                        '• positiveButtonFlex: Flex value for positive button'),
                    Text(
                        '• negativeButtonFlex: Flex value for negative button'),
                    Text(
                        '• Ratio 3:2 means positive button takes 3 parts width, negative button takes 2 parts'),
                    Text('• If not set, defaults to 1:1 equal ratio'),
                    SizedBox(height: 8),
                    Text('💡 Recommendations:',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: Colors.orange)),
                    Text(
                        '• Recommend using 3:2 or 2:1 to highlight positive button'),
                    Text(
                        '• Avoid making negative button wider than positive button'),
                    Text('• Extreme ratios may affect user experience'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleBanner({
    required String title,
    int? positiveButtonFlex,
    int? negativeButtonFlex,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          // Simulate ReviewBanner
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border.all(color: Colors.blue[200]!),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Are you comfortable with iPTT\'s features?'),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Expanded(
                      flex: negativeButtonFlex ?? 1,
                      child: SizedBox(
                        height: 44.0,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[100],
                            foregroundColor: Colors.grey[700],
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                          child: const Text('Not comfortable',
                              style: TextStyle(fontSize: 15.0)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      flex: positiveButtonFlex ?? 1,
                      child: SizedBox(
                        height: 44.0,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34C759),
                            foregroundColor: Colors.white,
                            elevation: 2.0,
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Text('Good',
                              style: TextStyle(
                                  fontSize: 15.0, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Ratio setting: ${positiveButtonFlex ?? 1}:${negativeButtonFlex ?? 1}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
