import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import '../functions/sqlite.dart';
//import 'package:http/http.dart' as http;

class Plantstatus extends StatefulWidget {
  const Plantstatus({super.key});

  @override
  State<Plantstatus> createState() => _PlantstatusState();
}

class _PlantstatusState extends State<Plantstatus> {
  bool _isListView = true;
  bool _showPhEcAverage = true;
  String _selectedMetric = 'temperature';
  final Map<String, Color> _metricColors = {
    'temperature': Colors.red,
    'humidity': Colors.blue,
    'ph': Colors.green,
    'ec': Colors.orange,
  };

  Future<List<Map<String, dynamic>>> _fetchSensorData() async {
    return await DatabaseHelper().queryData('sensorReading');
  }

  String _metricKey(String metric) {
    switch (metric) {
      case 'temperature':
        return 'current_temperature';
      case 'humidity':
        return 'current_humidity';
      case 'ph':
        return 'current_ph';
      case 'ec':
        return 'current_ec';
      default:
        return 'current_temperature';
    }
  }

  double _calculateValue(List<Map<String, dynamic>> data, String key) {
    final total = data.fold(0.0, (sum, item) => sum + item[key]);
    return (key == 'current_temperature' || key == 'current_humidity')
        ? total / data.length
        : _showPhEcAverage
            ? total / data.length
            : total;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Status'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      floatingActionButton: ExpandableFab(
        distance: isSmallScreen ? 70.0 : 90.0,
        type: ExpandableFabType.up,
        childrenOffset: const Offset(0, -10),
        children: [
          FloatingActionButton(
            heroTag: 'viewToggle',
            child: Icon(_isListView ? Icons.bar_chart : Icons.list,
                size: isSmallScreen ? 24 : 28),
            onPressed: () => setState(() => _isListView = !_isListView),
          ),
          FloatingActionButton(
            heroTag: 'phEcToggle',
            child: Icon(_showPhEcAverage ? Icons.summarize : Icons.calculate,
                size: isSmallScreen ? 24 : 28),
            onPressed: () =>
                setState(() => _showPhEcAverage = !_showPhEcAverage),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchSensorData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No sensor data available'));
            } else {
              final data = snapshot.data!;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 12 : 16,
                      horizontal: isSmallScreen ? 8 : 16,
                    ),
                    child: _buildResponsiveRowSummaryBoxes(data, screenWidth),
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 8 : 16,
                      ),
                      child: _isListView
                          ? _buildListView(data, screenWidth)
                          : _buildGraphView(data, screenWidth),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveRowSummaryBoxes(
      List<Map<String, dynamic>> data, double screenWidth) {
    final isSmallScreen = screenWidth < 600;
    final boxSpacing = isSmallScreen ? 6.0 : 12.0;

    return Wrap(
      spacing: boxSpacing,
      runSpacing: boxSpacing,
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _buildSummaryBox(data, 'current_temperature', 'Avg Temp', '°C'),
        _buildSummaryBox(data, 'current_humidity', 'Avg Hum', '%'),
        _buildSummaryBox(
            data, 'current_ph', _showPhEcAverage ? 'Avg PH' : 'Sum PH', ''),
        _buildSummaryBox(
            data, 'current_ec', _showPhEcAverage ? 'Avg PPM' : 'Sum PPM', ''),
      ],
    );
  }

  Widget _buildSummaryBox(
      List<Map<String, dynamic>> data, String key, String label, String unit) {
    final value = _calculateValue(data, key);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              children: [
                TextSpan(text: value.toStringAsFixed(1)),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Map<String, dynamic>> data, double screenWidth) {
    final isSmallScreen = screenWidth < 600;
    final cardPadding = isSmallScreen ? 12.0 : 16.0;

    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final reading = data[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
              ),
            ],
          ),
          child: Card(
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Time: ${_formatTimestamp(reading['timestamp'])}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: [
                      _buildSensorItem('TEMP',
                          '${reading['current_temperature'].toStringAsFixed(1)}°C'),
                      _buildSensorItem('HUM',
                          '${reading['current_humidity'].toStringAsFixed(1)}%'),
                      _buildSensorItem(
                          'PH', reading['current_ph'].toStringAsFixed(2)),
                      _buildSensorItem(
                          'PPM', reading['current_ec'].toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensorItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraphView(List<Map<String, dynamic>> data, double screenWidth) {
    final metricKey = _metricKey(_selectedMetric);
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value[metricKey].toDouble()))
        .toList();

    final minY = data.fold(
        double.infinity,
        (min, item) =>
            item[metricKey].toDouble() < min ? item[metricKey] : min);
    final maxY = data.fold(
        double.negativeInfinity,
        (max, item) =>
            item[metricKey].toDouble() > max ? item[metricKey] : max);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButton<String>(
              value: _selectedMetric,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade700),
              items: [
                _buildDropdownItem('Temperature', 'temperature'),
                _buildDropdownItem('Humidity', 'humidity'),
                _buildDropdownItem('pH', 'ph'),
                _buildDropdownItem('EC', 'ec'),
              ],
              onChanged: (value) => setState(() => _selectedMetric = value!),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade200,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          value.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      interval: (maxY - minY) / 4,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${value.toInt() + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      interval: (data.length / 5).ceilToDouble(),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: _metricColors[_selectedMetric],
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: _metricColors[_selectedMetric]!.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(String timestamp) {
    final dt = DateTime.parse(timestamp).toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')} '
        '${dt.day}/${dt.month}/${dt.year}';
  }

  DropdownMenuItem<String> _buildDropdownItem(String text, String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(text,
          style: TextStyle(
              color: _metricColors[value], fontWeight: FontWeight.w600)),
    );
  }
}

class PlantStatusMini extends StatefulWidget {
  const PlantStatusMini({super.key});

  @override
  State<PlantStatusMini> createState() => _PlantStatusMiniState();
}

class _PlantStatusMiniState extends State<PlantStatusMini> {
  String _selectedMetric = 'temperature';
  final Map<String, Color> _metricColors = {
    'temperature': Colors.red,
    'humidity': Colors.blue,
    'ph': Colors.green,
    'ec': Colors.orange,
  };

  Future<List<Map<String, dynamic>>> _fetchSensorData() async {
    return await DatabaseHelper().queryData('sensorReading');
  }

  String _metricKey(String metric) {
    switch (metric) {
      case 'temperature':
        return 'current_temperature';
      case 'humidity':
        return 'current_humidity';
      case 'ph':
        return 'current_ph';
      case 'ec':
        return 'current_ec';
      default:
        return 'current_temperature';
    }
  }

  double _calculateAverage(List<Map<String, dynamic>> data, String key) {
    if (data.isEmpty) return 0;
    final total = data.fold(0.0, (sum, item) => sum + item[key]);
    return total / data.length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchSensorData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available'));
        } else {
          final sensorData = snapshot.data!;
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 6,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Summary Row
                _buildMiniSummaryRow(sensorData),
                const SizedBox(height: 12),

                // Metric Selector
                _buildMetricSelector(),
                const SizedBox(height: 8),

                // Mini Graph
                SizedBox(
                  height: 150,
                  child: _buildMiniGraph(sensorData),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildMiniSummaryRow(List<Map<String, dynamic>> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMiniSummaryItem('TEMP',
            '${_calculateAverage(data, 'current_temperature').toStringAsFixed(1)}°C'),
        _buildMiniSummaryItem('HUM',
            '${_calculateAverage(data, 'current_humidity').toStringAsFixed(1)}%'),
        _buildMiniSummaryItem(
            'PH', _calculateAverage(data, 'current_ph').toStringAsFixed(2)),
        _buildMiniSummaryItem(
            'PPM', _calculateAverage(data, 'current_ec').toStringAsFixed(1)),
      ],
    );
  }

  Widget _buildMiniSummaryItem(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            )),
        Text(value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }

  Widget _buildMetricSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: _selectedMetric,
        isExpanded: true,
        underline: const SizedBox(),
        iconSize: 20,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
        ),
        items: [
          _buildDropdownItem('Temperature', 'temperature'),
          _buildDropdownItem('Humidity', 'humidity'),
          _buildDropdownItem('pH', 'ph'),
          _buildDropdownItem('EC', 'ec'),
        ],
        onChanged: (value) => setState(() => _selectedMetric = value!),
      ),
    );
  }

  Widget _buildMiniGraph(List<Map<String, dynamic>> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final metricKey = _metricKey(_selectedMetric);
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value[metricKey].toDouble()))
        .toList();

    final minY = data.fold(
        double.infinity,
        (min, item) =>
            item[metricKey].toDouble() < min ? item[metricKey] : min);
    final maxY = data.fold(
        double.negativeInfinity,
        (max, item) =>
            item[metricKey].toDouble() > max ? item[metricKey] : max);

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              interval: (maxY - minY) / 4,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final timestamp = data[index]['timestamp'];
                  final date = DateTime.parse(timestamp).toLocal();
                  return Text(
                    '${date.day}/${date.month}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              interval: (data.length / 5).ceilToDouble(),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData:
            FlBorderData(show: true, border: Border.all(color: Colors.grey)),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _metricColors[_selectedMetric],
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: _metricColors[_selectedMetric]!.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  DropdownMenuItem<String> _buildDropdownItem(String text, String value) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(text,
          style: TextStyle(color: _metricColors[value], fontSize: 14)),
    );
  }
}

/* Future<List<Map<String, dynamic>>> fetchSensorDataFromApi() async {
  const url = 'https://agreemo-api-v2.onrender.com/sensor-readings';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((item) {
        final Map<String, dynamic> sensorData = item as Map<String, dynamic>;
        sensorData['reading_time'] = item['reading_time'];
        sensorData['reading_value'] = item['reading_value'];
        sensorData['unit'] = item['unit'];
        final phData = jsonData.where((item) => item['unit'] == 'pH').toList();
        final ppmData =
            jsonData.where((item) => item['unit'] == 'ppm').toList();
        return sensorData;
      }).toList();
    } else {
      throw Exception('Failed to load sensor data: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching sensor data: $e');
  }
} */
