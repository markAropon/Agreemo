// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TdsTesting extends StatefulWidget {
  @override
  _TDSMaintenancePageState createState() => _TDSMaintenancePageState();
}

class _TDSMaintenancePageState extends State<TdsTesting> {
  List<bool?> stepResults = [null, null, null, null];
  int currentStep = 0;
  late VideoPlayerController _controller;
  var _isVideoPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse('https://www.w3schools.com/html/mov_bbb.mp4'))
      ..initialize().then((_) {
        setState(() {});
        _controller.addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            setState(() {
              _isVideoPlaying = false;
            });
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
          'TDS Sensor Accuracy Test',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.blue[700],
      ),
      backgroundColor: Colors.blue[700],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TDS Sensor Accuracy Test Checklist',
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
                            'Ensure that the TDS sensor is properly connected to the microcontroller. Check for loose wires or poor connections.',
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
                            'Gently wipe the TDS sensor with a dry cloth to remove any dust or debris that may affect its performance.',
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
                            'Verify that the TDS sensor is placed in an environment with temperatures within its operating range.',
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
                            'For better accuracy testing, measure the TDS readings from your sensor and compare it with a reliable reference (like a known environment condition).',
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

class VideoPlayerDialog extends StatefulWidget {
  final VideoPlayerController controller;
  final Function(int, bool) onUpdate;

  VideoPlayerDialog({required this.controller, required this.onUpdate});

  @override
  _VideoPlayerDialogState createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.black,
            height: 200,
            child: VideoPlayer(widget.controller),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () {
              widget.controller.pause();
              widget.onUpdate(3, true); // Update the step result
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}
