import 'package:flutter/material.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../utility_widgets/mistingPageBoxes.dart';

class Datareading extends StatefulWidget {
  const Datareading({super.key});

  @override
  State<Datareading> createState() => _DatareadingState();
}

class _DatareadingState extends State<Datareading> {
  double tds = 0.0;
  double ph = 0.0;
  String temperature = "Loading...";
  String humidity = "Loading...";
  String phValue = "Loading...";
  String tdsValue = "Loading...";

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
  final DatabaseReference phRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("sensorReadings/ph");
  final DatabaseReference tdsRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("sensorReadings/tds");

  @override
  void initState() {
    super.initState();

    tempRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          temperature = value.toString();
        });
      }
    });

    humidityRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          humidity = value.toString();
        });
      }
    });

    phRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          // Adding +7 to the ph value
          phValue = (double.tryParse(value.toString())! + 15).toString();
        });
      }
    });

    tdsRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value != null) {
        setState(() {
          tdsValue = value.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 155, 183),
        title: const Text(
          "Water Monitoring",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: Color.fromARGB(255, 19, 62, 135),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 177, 203, 216),
              Color.fromARGB(255, 115, 158, 211),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle("Irrigation 🌱"),
                const SizedBox(height: 10),
                const Divider(
                  color: Color.fromARGB(255, 19, 62, 135),
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 20),
                TemperatureHumidityBox(
                  temperature: temperature,
                  humidity: humidity,
                ),
                const SizedBox(height: 20),
                PPM(readingData: tdsValue),
                const SizedBox(height: 20),
                PhLevel(readingData: phValue),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Section title with an icon
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        const Icon(
          Icons.water_drop,
          color: Color.fromARGB(255, 19, 62, 135),
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 19, 62, 135),
          ),
        ),
      ],
    );
  }
}
