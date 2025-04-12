import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PhTesting extends StatefulWidget {
  @override
  _PHMaintenancePageState createState() => _PHMaintenancePageState();
}

class _PHMaintenancePageState extends State<PhTesting> {
  List<bool?> stepResults = [null, null, null, null];
  int currentStep = 0;
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://www.w3schools.com/html/mov_bbb.mp4'))
      ..initialize().then((_) {
        setState(() {});
        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            setState(() {});
          }
        });
      });
  }

  void updateStepResult(int index, bool result) {
    setState(() {
      stepResults[index] = result;
      if (index < stepResults.length - 1) {
        currentStep = index + 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'pH Sensor Accuracy Test',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 35, 71, 126),
      ),
      backgroundColor: const Color.fromARGB(255, 35, 71, 126),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'pH Sensor Accuracy Test Checklist',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            ),
            SizedBox(height: 24),
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: Stepper(
                  key: ValueKey<int>(currentStep),
                  currentStep: currentStep,
                  onStepTapped: (step) => setState(() => currentStep = step),
                  controlsBuilder:
                      (BuildContext context, ControlsDetails details) {
                    return SizedBox.shrink();
                  },
                  steps: [
                    Step(
                      title: Text(
                        'Check the sensor connections',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ensure that the pH sensor is properly connected to the microcontroller. Check for loose wires or poor connections.',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Roboto'),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(0, true, 'Pass'),
                              _buildActionButton(0, false, 'Fail'),
                              if (stepResults[0] != null)
                                Icon(
                                  stepResults[0]!
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: stepResults[0]!
                                      ? Colors.green
                                      : Colors.red,
                                  size: 32,
                                ),
                            ],
                          ),
                        ],
                      ),
                      isActive: currentStep == 0,
                      state: stepResults[0] == null
                          ? StepState.indexed
                          : (stepResults[0]!
                              ? StepState.complete
                              : StepState.error),
                    ),
                    Step(
                      title: Text(
                        'Clean the sensor with a dry cloth',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gently wipe the pH sensor with a dry cloth to remove any dust or debris that may affect its performance.',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Roboto'),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(1, true, 'Pass'),
                              _buildActionButton(1, false, 'Fail'),
                              if (stepResults[1] != null)
                                Icon(
                                  stepResults[1]!
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: stepResults[1]!
                                      ? Colors.green
                                      : Colors.red,
                                  size: 32,
                                ),
                            ],
                          ),
                        ],
                      ),
                      isActive: currentStep == 1,
                      state: stepResults[1] == null
                          ? StepState.indexed
                          : (stepResults[1]!
                              ? StepState.complete
                              : StepState.error),
                    ),
                    Step(
                      title: Text(
                        'Ensure sensor is within proper temperature range',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verify that the pH sensor is placed in an environment with temperatures within its operating range.',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Roboto'),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(2, true, 'Pass'),
                              _buildActionButton(2, false, 'Fail'),
                              if (stepResults[2] != null)
                                Icon(
                                  stepResults[2]!
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: stepResults[2]!
                                      ? Colors.green
                                      : Colors.red,
                                  size: 32,
                                ),
                            ],
                          ),
                        ],
                      ),
                      isActive: currentStep == 2,
                      state: stepResults[2] == null
                          ? StepState.indexed
                          : (stepResults[2]!
                              ? StepState.complete
                              : StepState.error),
                    ),
                    Step(
                      title: Text(
                        'Compare sensor readings with reference',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      content: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'For better accuracy testing, measure the pH readings from your sensor and compare it with a reliable reference (like a known environment conditions).',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontFamily: 'Roboto'),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              _showVideoPlayer();
                            },
                            child: Text('Start Accuracy Test'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: EdgeInsets.symmetric(vertical: 18.0),
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                      isActive: currentStep == 3,
                      state: stepResults[3] == null
                          ? StepState.indexed
                          : (stepResults[3]!
                              ? StepState.complete
                              : StepState.error),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVideoPlayer() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: VideoPlayerDialog(
              controller: _controller,
              onUpdate: updateStepResult,
            ),
          ),
        );
      },
    );

    // Play video
    _controller.play();
  }

  Widget _buildActionButton(int index, bool result, String label) {
    return ElevatedButton(
      onPressed: () {
        updateStepResult(index, result); // Update the result for the step
      },
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: result ? Colors.green : Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Create a custom dialog that updates itself when the video finishes
class VideoPlayerDialog extends StatefulWidget {
  final VideoPlayerController controller;
  final Function(int, bool) onUpdate; // Callback to update step result

  VideoPlayerDialog({required this.controller, required this.onUpdate});

  @override
  _VideoPlayerDialogState createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  bool _showPassFailButtons = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (widget.controller.value.position ==
          widget.controller.value.duration) {
        setState(() {
          _showPassFailButtons =
              true; // Show the buttons once the video finishes
        });
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: widget.controller.value.aspectRatio,
          child: VideoPlayer(widget.controller),
        ),
        Positioned(
          bottom: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  widget.controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    if (widget.controller.value.isPlaying) {
                      widget.controller.pause();
                    } else {
                      widget.controller.play();
                    }
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.replay,
                  size: 40,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    widget.controller.seekTo(Duration.zero);
                    widget.controller.play();
                  });
                },
              ),
            ],
          ),
        ),
        if (_showPassFailButtons)
          Positioned(
            bottom: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildActionButton(true, 'Pass'),
                SizedBox(width: 20),
                _buildActionButton(false, 'Fail'),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(bool result, String label) {
    return ElevatedButton(
      child: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: result ? Colors.green : Colors.red,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        widget.onUpdate(3, result);
        Navigator.of(context).pop();
      },
    );
  }
}
