import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // For handling image data
import 'dart:async'; // For the Timer

class VideoStream extends StatefulWidget {
  const VideoStream({super.key});

  @override
  _VideoStreamState createState() => _VideoStreamState();
}

class _VideoStreamState extends State<VideoStream> {
  final String videoUrl = "https://agreemo-api-v2.onrender.com/stream";
  bool isStreamAvailable = false;

  late SnapshotHandler snapshotHandler;

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    snapshotHandler = SnapshotHandler();
    _checkStreamAvailability();

    // Set up a periodic timer to take a snapshot every 8 hours (8 * 60 * 60 * 1000 ms = 28800000 ms)
    _timer = Timer.periodic(const Duration(milliseconds: 28800000), (timer) {
      snapshotHandler
          .takeSnapshot(); // Call the takeSnapshot method from SnapshotHandler
    });
  }

  @override
  void dispose() {
    // Dispose of the timer when the widget is disposed to avoid memory leaks
    _timer.cancel();
    super.dispose();
  }

  Future<void> _checkStreamAvailability() async {
    try {
      final response = await http.post(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        setState(() {
          isStreamAvailable = true;
        });
      } else {
        setState(() {
          isStreamAvailable = false;
        });
      }
    } catch (e) {
      setState(() {
        isStreamAvailable = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: isStreamAvailable
          ? InAppWebView(
              initialUrlRequest:
                  URLRequest(url: WebUri(Uri.parse(videoUrl).toString())),
              onWebViewCreated: (controller) {
                snapshotHandler.webViewController = controller;
              },
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  '😢 Stream Not Available',
                  style: TextStyle(fontSize: 24, color: Colors.red),
                ),
              ),
            ),
    );
  }
}

class SnapshotHandler {
  List<Uint8List> snapshots = []; // List to hold snapshots
  InAppWebViewController? webViewController;

  SnapshotHandler({this.webViewController});

  // Function to capture a snapshot
  Future<void> takeSnapshot() async {
    if (webViewController != null) {
      try {
        var screenshotData = await webViewController!.takeScreenshot();
        if (screenshotData != null) {
          snapshots.add(screenshotData);
          print("Snapshot taken and added to the list.");
        }
      } catch (e) {
        print("Error taking snapshot: $e");
      }
    }
  }

  // Getter to access the snapshots anywhere
  List<Uint8List> getSnapshots() {
    return snapshots;
  }

  // Function to build a ListView with the snapshots
  Widget buildSnapshotListView() {
    return ListView.builder(
      itemCount: snapshots.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Image.memory(
            snapshots[index], // Display the snapshot image
            fit: BoxFit.cover,
            width: 100,
            height: 100,
          ),
          title: Text('Snapshot ${index + 1}'),
        );
      },
    );
  }
}
