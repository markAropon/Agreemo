// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class PhLevel extends StatefulWidget {
  final String title = "pH Level";
  final String icon = "assets/icons/ph icon.png";
  final String readingData;

  const PhLevel({super.key, required this.readingData});

  @override
  State<PhLevel> createState() => _PhLevelState();
}

class _PhLevelState extends State<PhLevel> {
  bool _autoModeEnabled = true; // Default to true, adjust after fetching data.
  bool _phUpOn = false;
  bool _phDownOn = false;

  @override
  void initState() {
    super.initState();
    _fetchAutoModeStatus();
    _fetchManualControlStates(); // Fetch initial states of pH Up and pH Down
  }

  Future<void> _fetchAutoModeStatus() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref();

      final DataSnapshot snapshot =
          await database.child('valveControl/autoMode/ph').get();
      final int autoModeValue = snapshot.value as int? ?? 0;

      setState(() {
        _autoModeEnabled =
            autoModeValue == 0; // Disabled when 1, Enabled when 0.
      });
    } catch (error) {
      print("Error fetching auto mode status: $error");
    }
  }

  Future<void> _fetchManualControlStates() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref();

      final DataSnapshot phUpSnapshot =
          await database.child('valveControl/phUp').get();
      final DataSnapshot phDownSnapshot =
          await database.child('valveControl/phDown').get();

      setState(() {
        _phUpOn = (phUpSnapshot.value as int? ?? 0) == 1;
        _phDownOn = (phDownSnapshot.value as int? ?? 0) == 1;
      });
    } catch (error) {
      print("Error fetching manual control states: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 500,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 19, 62, 135),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  widget.icon,
                  height: 25,
                  width: 25,
                ),
                const SizedBox(width: 10),
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.readingData,
              style: const TextStyle(
                fontSize: 32,
                color: Color.fromARGB(255, 11, 82, 13),
              ),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Min", style: TextStyle(fontSize: 13)),
                Text("Max", style: TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "pH level measures acidity or alkalinity, ranging from 0 (acidic) to 14 (alkaline), with 7 being neutral.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: _autoModeEnabled ? togglePhUp : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: _phUpOn
                          ? const Color.fromARGB(255, 19, 73, 21)
                          : const Color(0x00000000),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          color: _autoModeEnabled
                              ? const Color.fromARGB(255, 0, 8, 255)
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'pH+',
                          style: TextStyle(
                              color:
                                  _autoModeEnabled ? Colors.black : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _autoModeEnabled ? togglePhDown : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: _phDownOn
                          ? const Color.fromARGB(255, 19, 73, 21)
                          : const Color(0x00000000), // Green if on
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_downward,
                          color: _autoModeEnabled
                              ? const Color.fromARGB(255, 0, 8, 255)
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'pH-',
                          style: TextStyle(
                              color:
                                  _autoModeEnabled ? Colors.black : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void togglePhUp() async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    final DataSnapshot snapshot =
        await database.child('valveControl/phUp').get();
    final int currentValue = snapshot.value as int;
    final newValue = currentValue == 1 ? 0 : 1;
    await database.child('valveControl/phUp').set(newValue);

    setState(() {
      _phUpOn = newValue == 1; // Update local state
    });
  }

  void togglePhDown() async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    final DataSnapshot snapshot =
        await database.child('valveControl/phDown').get();
    final int currentValue = snapshot.value as int;
    final newValue = currentValue == 1 ? 0 : 1;
    await database.child('valveControl/phDown').set(newValue);

    setState(() {
      _phDownOn = newValue == 1; // Update local state
    });
  }
}

class PPM extends StatefulWidget {
  final String title = "EC Meter";
  final String icon = "assets/icons/coolingIcon.png";
  final String readingData;
  final double min = 500;
  final double max = 800;

  const PPM({
    super.key,
    required this.readingData,
  });

  @override
  State<PPM> createState() => _PPMState();
}

class _PPMState extends State<PPM> {
  bool _autoModeEnabled = true;
  bool _solAOn = false;
  bool _solBOn = false;

  @override
  void initState() {
    super.initState();
    _fetchAutoModeStatus();
    _fetchManualControlStates();
  }

  Future<void> _fetchAutoModeStatus() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref();

      final DataSnapshot snapshot =
          await database.child('valveControl/autoMode/ECmeter').get();
      final int autoModeValue = snapshot.value as int? ?? 0;

      setState(() {
        _autoModeEnabled =
            autoModeValue == 0; // Disabled when 1, Enabled when 0.
      });
    } catch (error) {
      print("Error fetching auto mode status: $error");
      // Handle error appropriately, maybe show a message.
    }
  }

  Future<void> _fetchManualControlStates() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref();

      final DataSnapshot solASnapshot =
          await database.child('valveControl/sol-A').get();
      final DataSnapshot solBSnapshot =
          await database.child('valveControl/sol-B').get();

      setState(() {
        _solAOn = (solASnapshot.value as int? ?? 0) == 1;
        _solBOn = (solBSnapshot.value as int? ?? 0) == 1;
      });
    } catch (error) {
      print("Error fetching manual control states: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
// Convert readingData to a double
    double reading = double.tryParse(widget.readingData) ?? 0;

// Calculate the width of the progress bar based on the min/max range
    double progress = (reading - widget.min) / (widget.max - widget.min);
    progress = progress.clamp(0.0, 1.0); // Ensure it stays between 0 and 1

    String statusMessage;
    Color barColor;

    if (reading < widget.min) {
      statusMessage = "Extremely Low";
      barColor = Colors.red; // Red for Extremely Low
    } else if (reading >= widget.min &&
        reading < (widget.min + widget.max) / 3) {
      statusMessage = "Low";
      barColor = Colors.yellow; // Yellow for Low
    } else if (reading >= (widget.min + widget.max) / 3 &&
        reading <= (widget.min + widget.max) * 2 / 3) {
      statusMessage = "Neutral";
      barColor = const Color.fromARGB(255, 19, 73, 21); // Green for Neutral
    } else if (reading > (widget.min + widget.max) * 2 / 3) {
      statusMessage = "Max";
      barColor = Colors.blue; // Blue for Max
    } else {
      statusMessage = "Normal";
      barColor =
          const Color.fromARGB(255, 19, 73, 21); // Default to green for normal
    }

    return Container(
      width: 500,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 19, 62, 135),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  widget.icon,
                  height: 25,
                  width: 25,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.readingData,
              style: const TextStyle(
                  fontSize: 32, color: Color.fromARGB(255, 11, 82, 13)),
            ),
            const SizedBox(height: 20),

            // Progress bar with the color based on the status
            Column(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[300], // background color
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress, // This is where we set the progress
                    child: Container(
                      decoration: BoxDecoration(
                        color: barColor, // Set the color based on the status
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  statusMessage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black, // Text color remains neutral
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Min and Max Labels
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Min", style: TextStyle(fontSize: 13)),
                Text("Max", style: TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 5),
            const Text(
              "The hydroponic solution is in a neutral state.",
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: _autoModeEnabled ? toggleSolA : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: _solAOn
                          ? const Color.fromARGB(255, 19, 73, 21)
                          : const Color(0x00000000), // Green if on
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_color_fill_outlined,
                          color: _autoModeEnabled
                              ? const Color.fromARGB(255, 11, 60, 53)
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Sol A',
                          style: TextStyle(
                              color:
                                  _autoModeEnabled ? Colors.black : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _autoModeEnabled ? toggleSolB : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    decoration: BoxDecoration(
                      color: _solBOn
                          ? const Color.fromARGB(255, 19, 73, 21)
                          : const Color(0x00000000), // Green if on
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.format_color_fill_outlined,
                          color: _autoModeEnabled
                              ? const Color.fromARGB(255, 2, 90, 1)
                              : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Sol B',
                          style: TextStyle(
                              color:
                                  _autoModeEnabled ? Colors.black : Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateValveAutomodeToDatabase(bool settoTrue) async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    await database
        .child("valveControl/autoMode/ECmeter")
        .set(settoTrue ? 1 : 0);
  }

  void showDisableConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure you want to disable this?'),
          content:
              const Text('Disabling will turn off the auto mode for EC meter.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
                updateValveAutomodeToDatabase(false);
              },
            ),
          ],
        );
      },
    );
  }

  void toggleSolA() async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    final DataSnapshot snapshot =
        await database.child('valveControl/sol-A').get();
    final int currentValue = snapshot.value as int;
    final newValue = currentValue == 1 ? 0 : 1;

    await database.child('valveControl/sol-A').set(newValue);
    setState(() {
      _solAOn = newValue == 1;
    });
  }

  void toggleSolB() async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    final DataSnapshot snapshot =
        await database.child('valveControl/sol-B').get();
    final int currentValue = snapshot.value as int;
    final newValue = currentValue == 1 ? 0 : 1;

    await database.child('valveControl/sol-B').set(newValue);
    setState(() {
      _solBOn = newValue == 1;
    });
  }
}

class TemperatureHumidityBox extends StatefulWidget {
  final String temperature;
  final String humidity;

  const TemperatureHumidityBox({
    super.key,
    required this.temperature,
    required this.humidity,
  });

  @override
  State<TemperatureHumidityBox> createState() => _TemperatureHumidityBoxState();
}

class _TemperatureHumidityBoxState extends State<TemperatureHumidityBox> {
  bool _autoModeEnabled = true;
  bool _reservoirOn = false;
  bool _mistingOn = false;
  bool _exhaustOn = false;

  @override
  void initState() {
    super.initState();
    _fetchAutoModeStatus();
    _fetchManualControlStates();
  }

  Future<void> _fetchAutoModeStatus() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref();

      final DataSnapshot snapshot =
          await database.child('pumpControl/autoMode').get();
      final int autoModeValue = snapshot.value as int? ?? 0;

      setState(() {
        _autoModeEnabled =
            autoModeValue == 0; // Disabled when 1, Enabled when 0.
      });
    } catch (error) {
      print("Error fetching auto mode status: $error");
      // Handle error appropriately, maybe show a message.
    }
  }

  Future<void> _fetchManualControlStates() async {
    try {
      final DatabaseReference database = FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
      ).ref();

      final DataSnapshot reservoirSnapshot =
          await database.child('pumpControl/pump1').get();
      final DataSnapshot mistingSnapshot =
          await database.child('pumpControl/pump2').get();
      final DataSnapshot exhaustSnapshot =
          await database.child('pumpControl/exhaust').get();

      setState(() {
        _reservoirOn = (reservoirSnapshot.value as int? ?? 0) == 1;
        _mistingOn = (mistingSnapshot.value as int? ?? 0) == 1;
        _exhaustOn = (exhaustSnapshot.value as int? ?? 0) == 1;
      });
    } catch (error) {
      print("Error fetching manual control states: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

// Adjust width based on screen size
    double containerWidth = screenWidth > 600
        ? 500
        : screenWidth *
            0.9; // For large screens, 500px; for smaller screens, 90% of screen width

    return Container(
      width: containerWidth,
      margin: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color.fromARGB(255, 19, 62, 135),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.thermostat_outlined,
                  color: Color.fromARGB(255, 19, 62, 135),
                  size: 25,
                ),
                Text(
                  'Temperature & Humidity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Temperature: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${widget.temperature}°C',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 151, 92, 3),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      'Humidity:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${widget.humidity}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color.fromARGB(255, 3, 87, 79),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /* GestureDetector(
                  onTap: _autoModeEnabled ? toggleReservoir : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                    decoration: BoxDecoration(
                      color: _reservoirOn
                          ? const Color.fromARGB(255, 19, 73, 21)
                          : const Color(0x00000000), // Green if on
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.water,
                          color: _autoModeEnabled
                              ? const Color.fromARGB(255, 25, 0, 246)
                              : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            'Reservoir',
                            style: TextStyle(
                                color: _autoModeEnabled
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ), */
                GestureDetector(
                  onTap: _autoModeEnabled ? toggleMisting : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    decoration: BoxDecoration(
                      color: _mistingOn
                          ? const Color.fromARGB(255, 19, 73, 21)
                          : const Color(0x00000000),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          color: _autoModeEnabled
                              ? const Color.fromARGB(255, 0, 8, 255)
                              : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            'Start Cooling GreenHouse💦💨',
                            style: TextStyle(
                                color: _autoModeEnabled
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                /*   GestureDetector(
                  onTap: _autoModeEnabled ? toggleExhaust : null,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                    decoration: BoxDecoration(
                      color: _exhaustOn
                          ? const Color.fromARGB(255, 19, 73, 21)
                          : const Color(0x00000000), // Green if on
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.air,
                          color: _autoModeEnabled
                              ? const Color.fromARGB(255, 22, 41, 32)
                              : Colors.grey,
                          size: 18,
                        ),
                        const SizedBox(width: 5),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                            'Fans',
                            style: TextStyle(
                                color: _autoModeEnabled
                                    ? Colors.black
                                    : Colors.grey,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ), */
              ],
            ),
          ],
        ),
      ),
    );
  }

  toggleReservoir() async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    final DataSnapshot snapshot =
        await database.child('pumpControl/pump1').get();
    final int currentValue = snapshot.value as int;
    final newValue = currentValue == 1 ? 0 : 1;
    await database.child('pumpControl/pump1').set(newValue);

    setState(() {
      _reservoirOn = newValue == 1;
    });
  }

  toggleMisting() async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    final DataSnapshot snapshot =
        await database.child('pumpControl/pump2').get();
    final int currentValue = snapshot.value as int;
    final newValue = currentValue == 1 ? 0 : 1;
    await database.child('pumpControl/pump2').set(newValue);

    setState(() {
      _mistingOn = newValue == 1;
    });
  }

  toggleExhaust() async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    final DataSnapshot snapshot =
        await database.child('pumpControl/exhaust').get();
    final int currentValue = snapshot.value as int;
    final newValue = currentValue == 1 ? 0 : 1;
    await database.child('pumpControl/exhaust').set(newValue);

    setState(() {
      _exhaustOn = newValue == 1;
    });
  }
}

Future<void> fetchControlData(BuildContext context) async {
  print('Fetching control data');

  final DatabaseReference database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  List<String> controlPaths = [
    'valveControl/autoMode/airVentCooling',
    'valveControl/autoMode/ECmeter',
    'valveControl/autoMode/ph',
    'pumpControl/autoMode',
  ];
  try {
    for (String path in controlPaths) {
      DataSnapshot snapshot = await database.child(path).get();
      int currentValue = snapshot.value as int? ?? 0;
      print("Control at path $path is: $currentValue");
    }
  } catch (e) {
    print("Error fetching control data: $e");
  }
}
