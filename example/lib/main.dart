import 'package:flutter/material.dart';
import 'package:app_review_promoter/app_review_promoter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Review Promoter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'App Review Promoter Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  late AppReviewManager _reviewManager;

  @override
  void initState() {
    super.initState();
    _initializeReviewManager();
  }

  Future<void> _initializeReviewManager() async {
    _reviewManager = AppReviewManager.instance;

    // Configure the review promoter
    final config = ReviewConfig(
      appVersion: '1.0.0',
      minUsageTime: Duration(minutes: 2), // Show after 2 minutes of usage
      enableAnalytics: true,
      onReviewRequested: () async {
        print('User requested to review the app');
      },
      onFlowCompleted: (analytics) {
        print('Review flow completed: ${analytics.toString()}');
      },
      messages: ReviewMessages.defaultMessages(),
      style: ReviewStyle(),
    );

    await _reviewManager.initialize(config);
    _reviewManager.startTracking();
    return;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Simulate some usage - you might want to check for review after certain actions
    if (_counter % 10 == 0) {
      _checkForReviewPrompt();
    }
  }

  void _checkForReviewPrompt() {
    ReviewDialog.showIfNeeded(context);
  }

  void _forceShowReview() {
    _reviewManager.debugForceShow();
    ReviewDialog.showIfNeeded(context);
  }

  void _simulateUsage() {
    _reviewManager.debugSimulateUsage(Duration(minutes: 5));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Simulated 5 minutes of usage')),
    );
  }

  void _resetReviewData() {
    _reviewManager.resetAll();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Review data reset')),
    );
  }

  @override
  void dispose() {
    _reviewManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ReviewBanner(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _forceShowReview,
                child: Text('Force Show Review Dialog'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _simulateUsage,
                child: Text('Simulate 5 Min Usage'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _resetReviewData,
                child: Text('Reset Review Data'),
              ),
              SizedBox(height: 20),
              FutureBuilder<String>(
                future: _getDebugInfo(),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'Loading debug info...',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<String> _getDebugInfo() async {
    final debugInfo = _reviewManager.debugInfo;
    return debugInfo.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }
}
