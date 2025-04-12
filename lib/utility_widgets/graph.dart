import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Graph extends StatelessWidget {
  const Graph({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 1:
                      return const Text('1 inch',
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 46, 83),
                          ));
                    case 2:
                      return const Text('2 inch',
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 46, 83),
                          ));
                    case 3:
                      return const Text('3 inch',
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 46, 83),
                          ));
                    case 4:
                      return const Text('4 inch',
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 46, 83),
                          ));
                    case 5:
                      return const Text('5 inch',
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 46, 83),
                          ));
                    case 6:
                      return const Text('6 inch',
                          style: TextStyle(
                            color: Color.fromARGB(255, 2, 46, 83),
                          ));
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 50,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  const titles = {
                    1: '1 week',
                    2: '2 week',
                    3: '3 week',
                    4: '4 week',
                    5: '5 week',
                  };
                  return titles.containsKey(value)
                      ? Text(titles[value]!,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 2, 46, 83),
                          ))
                      : const SizedBox.shrink();
                },
                reservedSize: 70,
              ),
            ),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
                color: const Color.fromARGB(255, 2, 46, 83), width: 2),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                const FlSpot(1, 1),
                const FlSpot(2, 3),
                const FlSpot(3, 3),
                const FlSpot(4, 4),
                const FlSpot(5, 5),
                const FlSpot(6, 6),
              ],
              isCurved: true,
              dotData: const FlDotData(show: true),
              color: Colors.green[800]!,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class GraphSummary extends StatelessWidget {
  const GraphSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Growth Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 2, 46, 83),
              ),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.trending_up, color: Color.fromARGB(255, 17, 42, 1)),
              SizedBox(width: 2),
              Text(
                'Steady growth',
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 2, 46, 83),
                ),
              ),
            ],
          ),
          Center(
            child: Text(
              'From 1 to 6 Inches',
              style: TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 57, 151, 3),
              ),
            ),
          )
        ],
      ),
    );
  }
}
