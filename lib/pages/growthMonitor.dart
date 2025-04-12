import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dashboard.dart';

class Growthmonitor extends StatefulWidget {
  const Growthmonitor({super.key});

  @override
  State<Growthmonitor> createState() => _GrowthmonitorState();
}

class _GrowthmonitorState extends State<Growthmonitor> {
  String temperature = "Loading...";
  String humidity = "Loading...";
  bool _isLoading = true;
  bool _hasError = false;
  int _reloadTrigger = 0;
  final String _streamUrl = 'https://agreemo-api.onrender.com/stream';
  late Timer _autoReloadTimer;

  final DatabaseReference tempRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("sensorReadings/temp");

  final DatabaseReference humidityRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("sensorReadings/humidity");

  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _fetchData();
    _startAutoReload();
  }

  void _startAutoReload() {
    _autoReloadTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted && !_hasError) {
        _retryStream();
      }
    });
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
          },
          onWebResourceError: (error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadHtmlString('''
        <html>
          <body style="margin:0;padding:0;">
            <img src="$_streamUrl?t=${DateTime.now().millisecondsSinceEpoch}" 
                 style="width:100%;height:100%;object-fit:cover;" 
                 alt="Live Stream">
          </body>
        </html>
      ''');
  }

  void _fetchData() async {
    try {
      final tempSnapshot = await tempRef.get();
      final humiditySnapshot = await humidityRef.get();

      if (mounted) {
        setState(() {
          temperature =
              tempSnapshot.exists ? '${tempSnapshot.value} °C' : 'No data';
          humidity = humiditySnapshot.exists
              ? '${humiditySnapshot.value}%'
              : 'No data';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          temperature = 'Error';
          humidity = 'Error';
        });
      }
    }
  }

  void _retryStream() {
    if (mounted) {
      setState(() {
        _hasError = false;
        _isLoading = true;
        _reloadTrigger++;
      });
    }
    _webViewController.loadHtmlString('''
      <html>
        <body style="margin:0;padding:0;">
          <img src="$_streamUrl?t=${DateTime.now().millisecondsSinceEpoch}" 
               style="width:100%;height:100%;object-fit:cover;" 
               alt="Live Stream">
        </body>
      </html>
    ''');
  }

  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        temperature = "Loading...";
        humidity = "Loading...";
      });
    }
    _fetchData();
  }

  @override
  void dispose() {
    _autoReloadTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 68, 194, 72),
        title: const Text(
          'GROWTH MONITORING',
          style: TextStyle(
            fontSize: 20,
            color: Color.fromARGB(255, 19, 62, 135),
          ),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Dashboard(),
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Color.fromARGB(255, 68, 194, 72),
                    Color.fromARGB(255, 248, 241, 241),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildStreamSection(),
                    const SizedBox(height: 20),
                    _buildSensorCards(),
                    const SizedBox(height: 20),
                    _buildQuestionCards(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreamSection() {
    return Column(
      children: [
        const Row(
          children: [
            Icon(Icons.videocam, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'Live Camera Feed',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(10),
          ),
          child: _hasError
              ? _buildErrorWidget()
              : Stack(
                  children: [
                    WebViewWidget(
                      controller: _webViewController,
                      key: ValueKey<int>(_reloadTrigger),
                    ),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildSensorCards() {
    return Column(
      children: [
        _buildSensorCard(
          icon: Icons.thermostat,
          label: 'Temperature',
          value: temperature,
          color: Colors.red,
        ),
        const SizedBox(height: 10),
        _buildSensorCard(
          icon: Icons.water_drop,
          label: 'Humidity',
          value: humidity,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildQuestionCards() {
    int? _expandedIndex; // Track which item is expanded

    Widget _buildFAQItem(
        {required String question,
        required String answer,
        required int index}) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              ListTile(
                title: Text(
                  question,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  _expandedIndex == index
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.green,
                ),
                onTap: () {
                  setState(() {
                    _expandedIndex = (_expandedIndex == index)
                        ? null
                        : index; // Toggle expansion
                  });
                },
              ),
              if (_expandedIndex == index)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 5.0),
                  child: Text(answer,
                      style: const TextStyle(color: Colors.black54)),
                ),
              const Divider(),
            ],
          );
        },
      );
    }

    return Card(
      margin: const EdgeInsets.only(top: 20),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Growth Monitoring FAQs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            _buildFAQItem(
              index: 0,
              question: 'What is the optimal pH for lettuce?',
              answer:
                  'Maintain pH between 5.5 - 6.5 for best nutrient absorption.',
            ),
            _buildFAQItem(
              index: 1,
              question: 'What are the ideal TDS levels?',
              answer: 'Keep TDS between 560 - 840 ppm for balanced nutrients.',
            ),
            _buildFAQItem(
              index: 2,
              question: 'What is the best temperature range?',
              answer:
                  'Air: 15°C - 21°C, Water: 20°C - 26.3°C for optimal growth.',
            ),
            _buildFAQItem(
              index: 3,
              question: 'What is the ideal humidity level?',
              answer:
                  'Maintain 40% - 60% RH to prevent dehydration and disease.',
            ),
          ],
        ),
      ),
    );
  }

  /* Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            answer,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  } */

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Stream Connection Error',
              style: TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _retryStream,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry Connection'),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
