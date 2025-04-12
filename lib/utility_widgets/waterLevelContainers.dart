import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../functions/pushNotif.dart';
import 'waterLevel.dart';

class WaterLevelContainer extends StatelessWidget {
  final String label;
  final double waterLevel;
  final Color waveColor;
  final int percentage;

  const WaterLevelContainer({
    required this.label,
    required this.waterLevel,
    required this.waveColor,
    required this.percentage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final containerSize = screenSize.width * 0.25;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color.fromARGB(255, 7, 111, 159),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                WaterLevel(
                  duration: const Duration(seconds: 3),
                  size: containerSize,
                  level: waterLevel,
                  waveColor: waveColor,
                ),
                Center(
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: containerSize * 0.1,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: containerSize * 0.1,
            ),
          ),
        ),
      ],
    );
  }
}

class WaterLevelPage extends StatefulWidget {
  const WaterLevelPage({super.key});

  @override
  State<WaterLevelPage> createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  double irrigation = 0.0;
  double misting = 0.0;
  double cooling = 0.0;
  Timer? _mistingTimer;
  // Firebase Database References
  final DatabaseReference irrigationRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("ultraSonicSensor/2/irrigation");

  final DatabaseReference mistingRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("ultraSonicSensor/2/misting");

  final DatabaseReference coolingRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("ultraSonicSensor/2/cooling");

  final DatabaseReference MistingActive = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("pumpControl/pump2");

  @override
  void initState() {
    super.initState();

    // Listen for changes in 'irrigation'
    irrigationRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          irrigation = 1 - ((value as num).toDouble() / 10);
        });
        _checkLevel(value as num, 'Irrigation', 10);
      }
    });

    // Listen for changes in 'misting'
    mistingRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          misting = 1 - ((value as num).toDouble() / 20);
        });
        _checkLevel(value as num, 'Misting', 17);
      }
      if (MistingActive == 1) {
        _startMistingReduction();
      } else {
        _mistingTimer?.cancel();
      }
    });

    // Listen for changes in 'cooling'
    coolingRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          cooling = 1 - ((value as num).toDouble() / 8);
        });
        _checkLevel(value as num, 'Cooling', 8);
      }
    });
  }

  void _startMistingReduction() {
    _mistingTimer?.cancel(); // Cancel previous timer if running

    _mistingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        misting =
            (misting - 0.5).clamp(0.0, 1.0); // Ensure it doesn't go below 0
      });

      if (misting <= 0) {
        timer.cancel(); // Stop when misting reaches 0
      }
    });
  }

  void _checkLevel(num value, String label, int threshold) {
    if (value >= threshold - 4 && value < threshold - 3) {
      _showNotification('⚠️ $label level is low. Consider refilling soon. ⏳');
    } else if (value >= threshold - 3 && value < threshold - 2) {
      _showNotification(
          '🚨 $label level is critically low. Refill urgently needed! ⛔');
    } else if (value >= threshold - 2) {
      _showNotification('❌ $label is empty. Immediate refill required! 💥');
    }
  }

  void _showNotification(String message) async {
    await NotificationService().showNotification(
      title: "Greenhouse Alert",
      description: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0, left: 20),
                  child: Text(
                    'Container Water Levels',
                    style: TextStyle(
                        fontSize: 20,
                        color: Color.fromARGB(255, 19, 62, 135),
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                WaterLevelContainer(
                  label: 'Irrigation',
                  waterLevel: irrigation,
                  waveColor: const Color.fromARGB(255, 220, 20, 60),
                  percentage: (irrigation * 100).toInt(),
                ),
                WaterLevelContainer(
                  label: 'Misting Reservoir',
                  waterLevel: misting + 2,
                  waveColor: const Color.fromARGB(255, 255, 165, 0),
                  percentage: (misting * 100).toInt(),
                ),
                WaterLevelContainer(
                  label: 'Cooling Reservoir',
                  waterLevel: cooling,
                  waveColor: Color.fromARGB(255, 61, 116, 255),
                  percentage: (cooling * 100).toInt(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SolutionLevelPage extends StatefulWidget {
  const SolutionLevelPage({super.key});

  @override
  _SolutionLevelPageState createState() => _SolutionLevelPageState();
}

class _SolutionLevelPageState extends State<SolutionLevelPage> {
  double sol_A = 0.0;
  double sol_B = 0.0;
  double phMinus = 0.0;
  double phPLus = 0.0;

  // Firebase Database References
  final DatabaseReference uss1 = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("ultraSonicSensor/1/sol-A");

  final DatabaseReference uss2 = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("ultraSonicSensor/1/sol-B");

  final DatabaseReference phRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("ultraSonicSensor/1/PH-");

  final DatabaseReference tdsRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("ultraSonicSensor/1/PH+");

  @override
  void initState() {
    super.initState();

    // Listen for changes in 'sol-A' (Solution A)
    uss2.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          sol_A = 1 - ((value as num).toDouble() / 8);
        });
        _checkLevel(value as num, 'Solution A');
      }
    });

    // Listen for changes in 'sol-B' (Solution B)
    uss1.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          sol_B = 1 - ((value as num).toDouble() / 8);
        });
        _checkLevel(value as num, 'Solution B');
      }
    });

    // Listen for changes in 'ph-' (pH Solution -)
    phRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          phMinus = 1 - ((value as num).toDouble() / 8);
        });
        _checkLevel(value as num, 'pH Solution -');
      }
    });

    // Listen for changes in 'ph+' (pH Solution +)
    tdsRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          phPLus = 1 - ((value as num).toDouble() / 8);
        });
        _checkLevel(value as num, 'pH Solution +');
      }
    });
  }

  void _checkLevel(num value, String label) {
    if (value >= 6 && value < 7) {
      _showNotification('⚠️ $label level is low. Consider refilling soon. ⏳');
    } else if (value >= 7 && value < 8) {
      _showNotification(
          '🚨 $label level is critically low. Refill urgently needed! ⛔');
    } else if (value >= 8) {
      _showNotification('❌ $label is empty. Immediate refill required! 💥');
    }
  }

  void _showNotification(String message) async {
    await NotificationService().showNotification(
      title: "Greenhouse Alert",
      description: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          children: [
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0, left: 20),
                  child: Text(
                    'Solution Levels',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 19, 62, 135),
                      letterSpacing: 2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WaterLevelContainer(
                      label: 'Solution A',
                      waterLevel: sol_A,
                      waveColor: Color.fromARGB(255, 34, 139, 34),
                      percentage: (sol_A * 100).toInt(),
                    ),
                    WaterLevelContainer(
                      label: 'Solution B',
                      waterLevel: sol_B,
                      waveColor: Color.fromARGB(255, 75, 0, 130),
                      percentage: (sol_B * 100).toInt(),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    WaterLevelContainer(
                      label: 'pH Solution +',
                      waterLevel: phPLus,
                      waveColor: const Color.fromARGB(255, 255, 69, 0),
                      percentage: (phPLus * 100).toInt(),
                    ),
                    WaterLevelContainer(
                      label: 'pH Solution -',
                      waterLevel: phMinus,
                      waveColor: const Color.fromARGB(255, 0, 191, 255),
                      percentage: (phMinus * 100).toInt(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
