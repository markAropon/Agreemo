import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LiveStreamWidget extends StatefulWidget {
  const LiveStreamWidget({super.key});

  @override
  State<LiveStreamWidget> createState() => _LiveStreamWidgetState();
}

class _LiveStreamWidgetState extends State<LiveStreamWidget> {
  bool _isLoading = true;
  bool _hasError = false;
  late VideoPlayerController _videoPlayerController;
  late Timer _autoReloadTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _startAutoReload();
  }

  // Initialize the video player
  void _initializeVideoPlayer() {
    _videoPlayerController = VideoPlayerController.asset('assets/lettuce.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true); // Set video to loop
        }
      }).catchError((error) {
        setState(() {
          _hasError = true;
        });
      });
  }

  // Start auto reload timer
  void _startAutoReload() {
    _autoReloadTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (mounted && !_hasError) {
        _retryStream();
      }
    });
  }

  // Retry loading the video stream
  void _retryStream() {
    if (mounted) {
      setState(() {
        _hasError = false;
        _isLoading = true;
      });
    }
    _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _autoReloadTimer.cancel();
    _videoPlayerController.dispose();
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
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : VideoPlayer(_videoPlayerController),
                  ],
                ),
        ),
      ],
    );
  }

  // Error widget to retry stream
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Error loading video',
              style: TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _retryStream,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry Video'),
          ),
        ],
      ),
    );
  }
}
