import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class Controls extends StatefulWidget {
  const Controls({super.key});

  @override
  _ControlsState createState() => _ControlsState();
}

class _ControlsState extends State<Controls> {
  bool valve1 = false;
  bool valve2 = false;
  bool valve3 = false;
  bool valve4 = false;

  bool pump1 = false;
  bool pump2 = false;
  bool pump3 = false;
  bool exhaust = false;

  int timerSeconds = 0;
  Timer? countdownTimer;
  int selectedDuration = 20;
  bool isMistingActive = false;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }

  void _startListening() {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    database.child("valveControl").onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          valve1 = event.snapshot.child("phDown").value == 1;
          valve2 = event.snapshot.child("phUp").value == 1;
          valve3 = event.snapshot.child("sol-A").value == 1;
          valve4 = event.snapshot.child("sol-B").value == 1;
        });
      }
    });

    database.child("pumpControl").onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          pump1 = event.snapshot.child("pump1").value == 1;
          pump2 = event.snapshot.child("pump2").value == 1;
          pump3 = event.snapshot.child("pump3").value == 1;
          exhaust = event.snapshot.child("exhaust").value == 1;
        });
      }
    });
  }

  Future<void> _showConfirmDialog(int valve) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: Text(
              'Are you sure you want to toggle the ${_getValveName(valve)} valve?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                toggleValve(valve);
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  String _getValveName(int valve) {
    switch (valve) {
      case 1:
        return "Ph Down (-)";
      case 2:
        return "Ph Up (+)";
      case 3:
        return "Solution A";
      case 4:
        return "Solution B";
      default:
        return "";
    }
  }

  void toggleValve(int valve) async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    String valveKey;
    switch (valve) {
      case 1:
        valveKey = "phDown";
        break;
      case 2:
        valveKey = "phUp";
        break;
      case 3:
        valveKey = "sol-A";
        break;
      case 4:
        valveKey = "sol-B";
        break;
      default:
        return;
    }

    DataSnapshot snapshot =
        await database.child("valveControl/$valveKey").get();
    bool currentState = snapshot.exists && snapshot.value == 1;

    bool newValue = !currentState;
    await database.child("valveControl/$valveKey").set(newValue ? 1 : 0);

    setState(() {
      switch (valve) {
        case 1:
          valve1 = newValue;
          break;
        case 2:
          valve2 = newValue;
          break;
        case 3:
          valve3 = newValue;
          break;
        case 4:
          valve4 = newValue;
          break;
      }
    });
  }

  void togglePump(int pump) async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    bool newValue = false;
    setState(() {
      switch (pump) {
        case 1:
          pump1 = !pump1;
          newValue = pump1;
          break;
        case 2:
          pump2 = !pump2;
          newValue = pump2;
          break;
        case 3:
          pump3 = !pump3;
          newValue = pump3;
          break;
        default:
          return;
      }
    });

    await database.child("pumpControl/pump$pump").set(newValue ? 1 : 0);
  }

  void toggleExhaust() async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    setState(() {
      exhaust = !exhaust;
    });

    await database.child("pumpControl/exhaust").set(exhaust ? 1 : 0);
  }

  void _showTimerDialog() {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    if (isMistingActive) return;

    setState(() {
      isMistingActive = true;
      pump2 = true; // Turn on pump2 immediately
      timerSeconds = selectedDuration;
    });
    database.child("pumpControl/pump2").set(1); // Update Firebase

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Misting Active'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Misting is running for $selectedDuration seconds'),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: timerSeconds / selectedDuration,
                    backgroundColor: Colors.grey[300],
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text('$timerSeconds seconds remaining'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    countdownTimer?.cancel();
                    Navigator.of(context).pop();
                    setState(() {
                      isMistingActive = false;
                      pump2 = false;
                    });
                    database.child("pumpControl/pump2").set(0);
                  },
                  child: const Text('Stop Now'),
                ),
              ],
            );
          },
        );
      },
    );

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (timerSeconds > 0) {
            timerSeconds--;
          } else {
            timer.cancel();
            Navigator.of(context).pop();
            isMistingActive = false;
            pump2 = false;
            database.child("pumpControl/pump2").set(0);
          }
        });
      } else {
        timer.cancel();
        isMistingActive = false;
      }
    });
  }

  void _selectDuration(int duration) {
    setState(() {
      selectedDuration = duration;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Control Systems'),
        backgroundColor: Colors.deepPurple,
        elevation: 10,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
        child: Column(
          children: [
            _buildControlPanel(
              title: 'Nutrient Control Panel',
              children: [
                _buildValve(valve1, "Ph Down (-)", 1),
                _buildValve(valve2, "Ph Up (+)", 2),
                _buildValve(valve3, "Solution A", 3),
                _buildValve(valve4, "Solution B", 4),
              ],
              isDurationSelectionVisible: false,
            ),
            const SizedBox(height: 30),
            _buildControlPanel(
              title: 'Water Flow Control Panel',
              children: [
                _buildPump(pump1, "Misting Reservoir", 1),
                _buildPump(pump2, "Misting", 2),
                _buildExhaustButton()
              ],
              isDurationSelectionVisible: true,
              selectedDuration: selectedDuration,
              onDurationSelected: _selectDuration,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExhaustButton() {
    return GestureDetector(
      onTap: toggleExhaust,
      child: _buildButton(
        isOn: exhaust,
        buttonText: exhaust ? "On" : "Off",
        colorOn: Colors.purpleAccent,
        colorOff: Colors.grey,
        icon: Icons.air,
        label: "Exhaust",
      ),
    );
  }

  Widget _buildControlPanel({
    required String title,
    required List<Widget> children,
    required bool isDurationSelectionVisible,
    int selectedDuration = 20,
    ValueChanged<int>? onDurationSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple.shade700,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 15),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: children,
            ),
            if (isDurationSelectionVisible)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDurationButton(
                      duration: 10,
                      isSelected: selectedDuration == 10,
                      onPressed: () => onDurationSelected?.call(10)),
                  _buildDurationButton(
                      duration: 20,
                      isSelected: selectedDuration == 20,
                      onPressed: () => onDurationSelected?.call(20)),
                  _buildDurationButton(
                      duration: 30,
                      isSelected: selectedDuration == 30,
                      onPressed: () => onDurationSelected?.call(30)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationButton({
    required int duration,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey[300],
          foregroundColor: isSelected ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('${duration}s', style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildValve(bool isOn, String valveName, int valveId) {
    return GestureDetector(
      onTap: () => _showConfirmDialog(valveId),
      child: _buildButton(
        isOn: isOn,
        buttonText: isOn ? "On" : "Off",
        colorOn: Colors.green,
        colorOff: Colors.grey,
        icon: Icons.water_drop,
        label: valveName,
      ),
    );
  }

  Widget _buildPump(bool isOn, String pumpName, int pumpId) {
    return GestureDetector(
      onTap: () {
        if (pumpId == 2) {
          _showTimerDialog();
        } else {
          togglePump(pumpId);
        }
      },
      child: _buildButton(
        isOn: isOn,
        buttonText: isOn ? "On" : "Off",
        colorOn: Colors.blue,
        colorOff: Colors.grey,
        icon: Icons.stream_sharp,
        label: pumpName,
      ),
    );
  }

  Widget _buildButton({
    required bool isOn,
    required String buttonText,
    required Color colorOn,
    required Color colorOff,
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isOn ? colorOn.withOpacity(0.8) : colorOff.withOpacity(0.4),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 3,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Icon(
            icon,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          buttonText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isOn ? Colors.white : Colors.grey,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
