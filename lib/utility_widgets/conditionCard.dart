import 'package:flutter/material.dart';

class ConditionCard extends StatelessWidget {
  final String title;
  final String tempIconPath;
  final String humidityIconPath;
  final String temperature;
  final String humidity;

  const ConditionCard({
    super.key,
    required this.title,
    required this.tempIconPath,
    required this.humidityIconPath,
    required this.temperature,
    required this.humidity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 19, 62, 135),
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          const SizedBox(height: 15),
          _buildRow(tempIconPath, 'Temp', temperature, Colors.red),
          const SizedBox(height: 6),
          _buildRow(humidityIconPath, 'Humidity', humidity, Colors.green),
        ],
      ),
    );
  }

  Widget _buildRow(
      String iconPath, String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              iconPath,
              height: 20,
              width: 20,
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(color: valueColor, fontSize: 12),
        ),
      ],
    );
  }
}
