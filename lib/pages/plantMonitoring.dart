import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenhouse_monitoring_project/functions/UserFunctions.dart';
import 'package:greenhouse_monitoring_project/functions/camera.dart';
import 'package:greenhouse_monitoring_project/functions/pushNotif.dart';
import 'package:greenhouse_monitoring_project/functions/sqlite.dart';
import 'package:greenhouse_monitoring_project/pages/PlantStatus.dart';
import 'package:greenhouse_monitoring_project/pages/growthMonitor.dart';
import 'package:greenhouse_monitoring_project/pages/harvest_1.dart';
import '../functions/HarvestFunctions.dart';
import '../utility_widgets/modules.dart';
import 'CropStepper.dart';

class Plantmonitoring extends StatefulWidget {
  const Plantmonitoring({super.key});

  @override
  State<Plantmonitoring> createState() => _PlantmonitoringState();
}

class _PlantmonitoringState extends State<Plantmonitoring> {
  int selectedGreenhouse = 0;
  final _colorScheme = const {
    'primary': Color(0xFF2E7D32),
    'secondary': Color(0xFF00695C),
    'background': Color(0xFFF5F5F5),
  };

  var selectedGreenhouseId = 0;
  final TextEditingController countController = TextEditingController();

  // Add initialization check
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForReadySeedlings();
    });
  }

  Future<void> _checkForReadySeedlings() async {
    final dbHelper = DatabaseHelper();
    final seedlingsData = await dbHelper.queryData('seedlingsTable');

    if (seedlingsData.isNotEmpty) {
      // Check if any seedlings are ready (days_old_seedling >= 7)
      bool hasReadySeedlings = seedlingsData.any((seedling) =>
          seedling['days_old_seedling'] != null &&
          int.parse(seedling['days_old_seedling'].toString()) >= 7);

      if (hasReadySeedlings) {
        notifyUser();
        showCustomDialog(
          context: context,
          title: "Seedling Ready",
          message:
              "Your seedling is mature and ready for transfer to the greenhouse. Please transfer within 24 hours for best results.",
          icon: Icons.info_outline_rounded,
          iconColor: Colors.blue,
          backgroundColor: Colors.white,
        );
      }
    }
  }

  void notifyUser() {
    final notificationService = NotificationService();
    notificationService.showNotification(
      title: "GreenHouse Alert",
      description:
          "Your seedling has reached maturity and is now ready to be transferred to the greenhouses. Please transfer it within 24 hours for optimal results.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Monitoring',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: _colorScheme['primary'],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_colorScheme['primary']!, _colorScheme['background']!],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildModulesRow(),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        children: [
                          _buildSeedlingProgressCards(),
                          LiveStreamWidget(
                            streamUrl:
                                'https://agreemo-api.onrender.com/stream',
                          ),
                          const PlantStatusMini(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index == 0
                                ? _colorScheme['primary']
                                : Colors.grey.shade300,
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildStatisticsCard(),
              const SizedBox(height: 20),
              _buildActivityLog(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildAddSeedlingButton(),
    );
  }

  Widget _buildModulesRow() => Row(
        children: [
          _buildModule('Growth Tracker', Icons.timeline, const CropStepper()),
          const SizedBox(width: 8),
          _buildModule('Plant View', Icons.camera_alt, const Growthmonitor()),
          const SizedBox(width: 8),
          _buildModule(
              'Plant Status', Icons.local_florist, const Plantstatus()),
        ],
      );

  Widget _buildModule(String title, IconData icon, Widget page) => Expanded(
        child: SquareModule(
          title: title,
          icon: icon,
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
          color: _colorScheme['secondary']!,
        ),
      );

  Widget _buildSeedlingProgressCards() => Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Seedling Progress',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: DatabaseHelper().queryData('seedlingsTable'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Text(
                          'No seedlings found. Add your first seedling!');
                    } else {
                      return Column(
                        children: snapshot.data!.map((seedling) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _buildSeedlingCard(
                              'GRH.${seedling['greenhouse_id']} seedling',
                              int.parse(
                                  seedling['days_old_seedling'].toString()),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildSeedlingCard(String title, int currentDay) {
    final isReady = currentDay >= 7;
    Widget card = Container(
      padding: const EdgeInsets.all(16),
      decoration: isReady
          ? BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(255, 1, 93, 168),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500)),
              if (isReady)
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: _colorScheme['primary'],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Ready to Transfer',
                      style: TextStyle(
                        fontSize: 12,
                        color: _colorScheme['primary'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFullWidthProgress(currentDay),
          if (isReady)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, size: 16, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'Tap to transfer',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    if (isReady) {
      return InkWell(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Center(
                child: Text('Transfer Seedling',
                    style: TextStyle(color: Colors.black)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.transfer_within_a_station,
                    color: _colorScheme['primary'],
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ready for Transfer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _colorScheme['primary'],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Would you like to transfer this seedling to the Greenhouse now?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This process cannot be undone.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    print("DEBUG: Starting seedling transfer process...");

                    try {
                      final dbHelper = DatabaseHelper();

                      int greenhouseId =
                          int.parse(title.split('.')[1].split(' ')[0]);
                      selectedGreenhouse = greenhouseId;

                      await dbHelper.insertData(
                        'toHarvest',
                        {
                          'greenhouse_id': greenhouseId,
                          'seedlings_daysOld': currentDay,
                          'greenhouse_daysOld': 0,
                          'planting_date': DateTime.now().toString(),
                          'status': 'Just got Transferred',
                        },
                      );
                      postPlantedCrops(
                        context: context,
                        selectedGreenhouseId: selectedGreenhouseId.toString(),
                      );
                      final result = dbHelper.deleteData('seedlingsTable',
                          'greenhouse_id = ?', [selectedGreenhouse]);

                      Navigator.of(context).pop();
                      print("DEBUG: Deletion result: $result");
                    } catch (e) {
                      print("DEBUG ERROR: Failed to delete seedling data: $e");
                    } finally {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Harvest1()),
                      );
                    }
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        final progressContext = context;
                        Future.delayed(const Duration(seconds: 2), () {
                          Navigator.of(progressContext).pop();
                          showCustomDialog(
                            context: context,
                            title: "Seedling Transfered Successfully",
                            message:
                                "Your seedling has been successfully moved to the greenhouse environment for optimal growth.",
                            icon: Icons.check_circle_outline,
                            iconColor: _colorScheme['primary']!,
                            backgroundColor: Colors.white,
                          );
                        });

                        return AlertDialog(
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    _colorScheme['primary']!),
                                strokeWidth: 4,
                              ),
                              const SizedBox(width: 20),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Transferring Seedling",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Please wait...",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    print('Transferring seedling...');

                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);

                      showCustomDialog(
                          context: context,
                          title: title,
                          message: "Transfer successful!",
                          icon: Icons.check_circle_outline,
                          iconColor: _colorScheme['primary']!,
                          backgroundColor: Colors.white);
                    });

                    Future.delayed(Duration(seconds: 2), () {
                      Navigator.pop(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorScheme['primary'],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Transfer Now',
                    style: TextStyle(color: Color.fromARGB(255, 2, 32, 56)),
                  ),
                ),
              ],
            ),
          );
        },
        borderRadius: BorderRadius.circular(8),
        highlightColor: _colorScheme['primary']!.withOpacity(0.1),
        child: card,
      );
    } else {
      return card;
    }
  }

  Widget _buildFullWidthProgress(int currentDay) => Row(
        children: List.generate(10, (index) {
          final day = index + 1;
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: day <= currentDay
                        ? _colorScheme['primary']
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Text('D$day',
                    style: TextStyle(
                      fontSize: 10,
                      color: day == currentDay
                          ? _colorScheme['primary']
                          : Colors.grey.shade600,
                      fontWeight: day == currentDay
                          ? FontWeight.bold
                          : FontWeight.normal,
                    )),
              ],
            ),
          );
        }),
      );

  Widget _buildStatisticsCard() => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Growth Statistics',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${rod.toY.toStringAsFixed(1)} inches',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              'Week ${value.toInt() + 1}',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 2,
                          getTitlesWidget: (value, meta) => SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()} in',
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: true),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 2,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey.withOpacity(0.2),
                        strokeWidth: 1,
                      ),
                    ),
                    groupsSpace: 12,
                    barGroups: List.generate(
                      4,
                      (i) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: [5.0, 6.5, 8.0, 9.5][i],
                            color: _colorScheme['secondary'],
                            width: 20,
                            borderRadius: BorderRadius.circular(4),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildActivityLog() => Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recent Activity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              ..._buildActivityItems(),
            ],
          ),
        ),
      );

  List<Widget> _buildActivityItems() => [
        _buildActivityItem('Water level checked', '2h ago', 650, 6.5),
        _buildActivityItem('Nutrients added', '5h ago', 680, 6.4),
        _buildActivityItem('Temperature adjusted', '8h ago', 630, 6.6),
      ];

  Widget _buildActivityItem(String task, String time, int ppm, double ph) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.check_circle, color: _colorScheme['secondary']),
        title: Text(task, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Health Status: Optimal',
                style:
                    TextStyle(color: _colorScheme['secondary'], fontSize: 12)),
            Text('PPM: $ppm | pH: $ph',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
        trailing: Text(time,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      );

  Widget _buildAddSeedlingButton() => FloatingActionButton.extended(
        onPressed: () => _showAddSeedlingDialog(context),
        label: const Text('New Seedling'),
        icon: const Icon(Icons.add),
        backgroundColor: _colorScheme['primary'],
      );

  Widget buildGreenhouseDropdownField() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper().queryData('greenhouseTable'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No greenhouses available');
        } else {
          List<Map<String, dynamic>> greenhouseList = snapshot.data!;

          Map<String, String> GRH_size = {};
          Map<String, String> GRH_status = {};

          for (var greenhouse in greenhouseList) {
            String greenhouseId = greenhouse['greenhouse_id'].toString();
            GRH_size[greenhouseId] =
                greenhouse['size']?.toString() ?? 'Unknown';
            GRH_status[greenhouseId] =
                greenhouse['status']?.toString() ?? 'Unknown';
          }

          return DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Greenhouse ID',
              border: OutlineInputBorder(),
            ),
            items: greenhouseList.map((greenhouse) {
              String greenhouseId = greenhouse['id'].toString();
              String size = GRH_size[greenhouseId] ?? 'Unknown';

              return DropdownMenuItem<String>(
                value: greenhouseId,
                child: Text('Greenhouse $greenhouseId (Size: $size)'),
              );
            }).toList(),
            onChanged: (value) {
              selectedGreenhouseId = int.parse(value!);
              print("Selected Greenhouse ID: $value");
              print("Selected Greenhouse Size: ${GRH_size[value]}");
              print("Selected Greenhouse Status: ${GRH_status[value]}");
            },
          );
        }
      },
    );
  }

  void _showAddSeedlingDialog(BuildContext context) {
    final TextEditingController daysOldController = TextEditingController();
    final TextEditingController countController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.eco_sharp, color: Colors.greenAccent),
              SizedBox(width: 8),
              Text('Add Planted Crops'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter the details for the newly planted crops:'),
              const SizedBox(height: 8),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchGreenhouseList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No greenhouses available');
                  } else {
                    List<Map<String, dynamic>> greenhouseList = snapshot.data!;

                    // Maps to store greenhouse data for validation
                    Map<String, int> greenhouseSizes = {};
                    Map<String, String> greenhouseStatuses = {};

                    for (var greenhouse in greenhouseList) {
                      String greenhouseId = greenhouse['id'].toString();
                      greenhouseSizes[greenhouseId] =
                          int.tryParse(greenhouse['size']?.toString() ?? '0') ??
                              0;
                      greenhouseStatuses[greenhouseId] =
                          greenhouse['status']?.toString() ?? 'Unknown';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Greenhouse ID',
                            border: OutlineInputBorder(),
                          ),
                          items: greenhouseList.map((greenhouse) {
                            String greenhouseId = greenhouse['id'].toString();
                            String size =
                                greenhouse['size']?.toString() ?? 'Unknown';

                            return DropdownMenuItem<String>(
                              value: greenhouseId,
                              child: Text(
                                  'Greenhouse $greenhouseId Capacity: $size)'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              selectedGreenhouseId = int.parse(value);

                              if (greenhouseStatuses[value]?.toLowerCase() ==
                                  'inactive') {
                                showCustomDialog(
                                  context: context,
                                  title: "Inactive Greenhouse",
                                  message:
                                      "This greenhouse is currently inactive and cannot be used for planting.",
                                  icon: Icons.error_outline,
                                  iconColor: Colors.red,
                                  backgroundColor: Colors.white,
                                );
                              }

                              countController.text = '';
                              countController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: countController.text.length),
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 8),
                          child: Builder(
                            builder: (context) {
                              String greenhouseId =
                                  selectedGreenhouseId.toString();

                              if (greenhouseSizes.containsKey(greenhouseId)) {
                                return Text(
                                  'Maximum capacity: ${greenhouseSizes[greenhouseId] ?? 0} plants',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: daysOldController,
                decoration: const InputDecoration(
                  labelText: 'Days Old',
                  hintText: 'Days old (Optional)',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: countController,
                decoration: const InputDecoration(
                  labelText: 'Count',
                  hintText: 'Enter count of crops',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final greenhouseId = selectedGreenhouseId.toString();
                final daysOld = daysOldController.text;
                final count = countController.text;

                if (greenhouseId.isEmpty || daysOld.isEmpty || count.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                try {
                  final dbHelper = DatabaseHelper();
                  final allSeedlings =
                      await dbHelper.queryData('seedlingsTable');
                  final existingSeedlingData = allSeedlings
                      .where((row) =>
                          row['greenhouse_id'] != null &&
                          row['greenhouse_id'].toString() == greenhouseId)
                      .toList();
                  final allHarvest = await dbHelper.queryData('toHarvest');
                  final existingHarvestData = allHarvest
                      .where((row) =>
                          row['greenhouse_id'] != null &&
                          row['greenhouse_id'].toString() == greenhouseId)
                      .toList();

                  if (existingSeedlingData.isNotEmpty ||
                      existingHarvestData.isNotEmpty) {
                    showCustomDialog(
                      context: context,
                      title: "Error",
                      message: "Greenhouse $greenhouseId is already occupied",
                      icon: Icons.error_outline,
                      iconColor: Colors.red,
                      backgroundColor: Colors.white,
                    );
                    return;
                  }

                  // Attempt SQLite insertion
                  // First check greenhouse status and capacity from API
                  final greenhouseList = await fetchGreenhouseList();
                  final greenhouseData = greenhouseList
                      .where((greenhouse) =>
                          greenhouse['id'].toString() == greenhouseId)
                      .toList();

                  if (greenhouseData.isEmpty) {
                    throw Exception("Greenhouse not found");
                  }

                  final status = greenhouseData[0]['status']?.toString() ?? '';
                  final size = double.tryParse(
                          greenhouseData[0]['size']?.toString() ?? '3') ??
                      0;
                  final countValue = int.tryParse(count) ?? 0;

                  // Check if greenhouse is active
                  if (status.toLowerCase() == 'inactive') {
                    showCustomDialog(
                      context: context,
                      title: "Cannot Plant",
                      message:
                          "This greenhouse is inactive and cannot be used for planting.",
                      icon: Icons.error_outline,
                      iconColor: Colors.red,
                      backgroundColor: Colors.white,
                    );
                    return;
                  }

                  // Check if count exceeds greenhouse size
                  if (countValue > size) {
                    showCustomDialog(
                      context: context,
                      title: "Exceeds Capacity",
                      message:
                          "The number of crops ($countValue) exceeds greenhouse capacity ($size).",
                      icon: Icons.warning,
                      iconColor: Colors.orange,
                      backgroundColor: Colors.white,
                    );
                    return;
                  }

                  await dbHelper.insertData(
                    'seedlingsTable',
                    {
                      'greenhouse_id': greenhouseId,
                      'days_old_seedling': daysOld,
                      'days_in_greenhouse': 0,
                      'crop_count': count,
                    },
                  );
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Seedling added successfully!'),
                      backgroundColor: _colorScheme['primary'],
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  Navigator.pop(context); // Close dialog on success
                } catch (e) {
                  // Show error only for SQLite failures
                  showCustomDialog(
                    context: context,
                    title: "Database Error",
                    message: "Failed to save data: ${e.toString()}",
                    icon: Icons.error_outline,
                    iconColor: Colors.red,
                    backgroundColor: Colors.white,
                  );
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
