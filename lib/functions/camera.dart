import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LiveStreamWidget extends StatefulWidget {
  final String streamUrl;

  const LiveStreamWidget({super.key, required this.streamUrl});

  @override
  State<LiveStreamWidget> createState() => _LiveStreamWidgetState();
}

class _LiveStreamWidgetState extends State<LiveStreamWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  int _reloadTrigger = 0;
  late Timer _autoReloadTimer;
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
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
      ..loadHtmlString(_getHtmlContent());
  }

  String _getHtmlContent() => '''
    <html>
      <body style="margin:0;padding:0;">
        <img src="${widget.streamUrl}?t=${DateTime.now().millisecondsSinceEpoch}" 
             style="width:100%;height:100%;object-fit:cover;" 
             alt="Live Stream">
      </body>
    </html>
  ''';

  void _retryStream() {
    if (mounted) {
      setState(() {
        _hasError = false;
        _isLoading = true;
        _reloadTrigger++;
      });
    }
    _webViewController.loadHtmlString(_getHtmlContent());
  }

  @override
  void dispose() {
    _autoReloadTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
}
