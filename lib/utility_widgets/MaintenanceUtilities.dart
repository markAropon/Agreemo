import 'package:flutter/material.dart';
import 'package:greenhouse_monitoring_project/functions/UserFunctions.dart';
import '../functions/maintenanceFunction.dart';

//carousel items
class SensorCard extends StatelessWidget {
  final String imageAsset;
  final String title;
  final String testsNeeded;
  final VoidCallback onTap;

  const SensorCard({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.testsNeeded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromARGB(255, 24, 197, 240),
            width: 3,
          ),
          image: DecorationImage(
            image: AssetImage(imageAsset),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(136, 15, 0, 0),
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$testsNeeded tests needed',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showTaskCards(BuildContext context) {
  final List<Map<String, String>> componentTasks = [
    {'title': 'Irrigation', 'description': 'Check filters and pipes'},
    {'title': 'Misting', 'description': 'Clean misting nozzles'},
    {'title': 'Solution', 'description': 'Check nutrient levels'},
    {'title': 'Cooling', 'description': 'Check fan and system status'},
  ];

  final List<Map<String, String>> sensorTasks = [
    {'title': 'pH Sensor', 'description': 'Calibrate pH sensor'},
    {'title': 'TDS Sensor', 'description': 'Clean and calibrate TDS sensor'},
    {
      'title': 'DHT Sensor',
      'description': 'Check temperature and humidity readings'
    },
  ];

  final List<Map<String, String>> actuatorTasks = [
    {
      'title': 'Misting Pump',
      'description': 'Check pump operation and ensure no leaks'
    },
    {
      'title': 'Reserve Pump',
      'description': 'Check pump operation and ensure no leaks'
    },
    {
      'title': 'Irrigation Pump',
      'description': 'Check pump operation and ensure no leaks'
    },
    {
      'title': 'PH+ Valves',
      'description': 'Check if the valves are working properly'
    },
    {
      'title': 'PH- Valves',
      'description': 'Check if the valves are working properly'
    },
    {
      'title': 'Snap A Valves',
      'description': 'Check if the valves are working properly'
    },
    {
      'title': 'Snap B Valves',
      'description': 'Check if the valves are working properly'
    },
    {
      'title': 'Fans',
      'description': 'Clean fan blades and check motor functionality'
    },
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Center(child: Text('Choose Task')),
        content: SingleChildScrollView(
          child: _TaskCategoryExpander(
            categories: [
              {'title': 'Components', 'tasks': componentTasks},
              {'title': 'Sensors', 'tasks': sensorTasks},
              {'title': 'Actuators', 'tasks': actuatorTasks},
            ],
          ),
        ),
      );
    },
  );
}

// for maintenance tools
void _showBottomSheet(BuildContext context, String title, String content) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  content,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      overflow: TextOverflow.fade),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

// maintenance tools at the bottom
Widget maintenancenTools(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8.0,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        // Maintenance Tips Button
        TextButton.icon(
          onPressed: () => _showBottomSheet(
            context,
            '💡Maintenance Tips💡\n',
            '• Ensure sensors are regularly calibrated for accurate readings and performance.\n\n'
                '• Clean sensors every 3 months to prevent buildup of dust or debris that could affect sensor accuracy.\n\n'
                '• Monitor sensor readings frequently to catch irregularities early and ensure optimal operation.\n\n'
                '• Replace worn-out or damaged sensor parts as soon as they are identified to maintain the sensor’s efficiency.\n\n'
                '• Check sensor connections and wiring to prevent loose or faulty connections that could lead to inaccurate readings.\n\n'
                '• Ensure proper environmental conditions (temperature, humidity) around the sensors to avoid damage.\n\n'
                '• Keep a maintenance log for all checks and repairs, so you can track performance and anticipate future needs.',
          ),
          icon: const Icon(Icons.tips_and_updates, color: Colors.blue),
          label: const Text(
            'Maintenance Tips',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(color: Colors.black12, thickness: 1, height: 20),

        // Upcoming Maintenance Button
        TextButton.icon(
          onPressed: () => _showBottomSheet(
            context,
            '🗓️Upcoming Maintenance Tasks🗓️\n',
            '• **Sensor Calibration** - March 15, 2025\n'
                'Ensure sensors are calibrated for accurate readings and optimal performance.\n\n'
                '• **Clean Sensor Lenses** - June 15, 2025\n'
                'Regular cleaning of sensor lenses prevents dirt buildup that may interfere with measurements.\n\n'
                '• **Battery Check** - December 15, 2025\n'
                'Check and replace batteries to avoid interruptions in sensor functionality.',
          ),
          icon: const Icon(Icons.calendar_today, color: Colors.green),
          label: const Text(
            'Upcoming Maintenance Tasks',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(color: Colors.black12, thickness: 1, height: 20),

        // Contact Support Button
        TextButton.icon(
          onPressed: () => _showBottomSheet(
            context,
            '☎️Need Help? Contact Support☎️\n',
            'For any issues or sensor-related questions, reach out to our support team at:\n\n'
                'Email: support@sensors.com\n\n'
                'Phone: +1 (123) 456-7890',
          ),
          icon: const Icon(Icons.support_agent, color: Colors.red),
          label: const Text(
            'Need Help? Contact Support',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

//add maintenance log
Widget AddNewMaintenanceLog(BuildContext context) {
  return GestureDetector(
    onTap: () {
      showTaskCards(context);
    },
    child: Row(
      children: [
        const Text(
          'Add new Maintenance log',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        IconButton(
          onPressed: () {
            showTaskCards(context);
          },
          icon: const Icon(
            Icons.add,
            color: Colors.blueAccent,
          ),
        ),
      ],
    ),
  );
}

void _showWorkingNonWorkingDialog(
    BuildContext context, Map<String, String> task) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Is the ${task['title']} working?'),
        actions: [
          // Working button
          TextButton(
            onPressed: () async {
              try {
                await AddNewHardwareStatus(
                  context,
                  greenhouse_id: '4',
                  component_id: '10',
                  isActive: true,
                  statusNote: 'Working',
                );

                // Always add maintenance record after updating status
                await AddMaintenanceRecord(
                  context,
                  title: '${task['title']} (Working)',
                  description: task['description']!,
                );

                // Show success dialog
                showCustomDialog(
                  context: context,
                  title: 'Success',
                  message: 'Maintenance Record Saved',
                  icon: Icons.check_circle_sharp,
                  iconColor: const Color.fromARGB(255, 0, 104, 54),
                  backgroundColor: Colors.green[50]!,
                );
              } catch (e) {
                // Handle error
                showCustomDialog(
                  context: context,
                  title: 'Error',
                  message: 'Something went wrong. Please try again later.',
                  icon: Icons.error,
                  iconColor: Colors.red,
                  backgroundColor: Colors.red[50]!,
                );
                print(e);
              }
            },
            child: const Text('Working'),
          ),
          // Not Working button
          TextButton(
            onPressed: () async {
              try {
                // Call the status update function, don't check its result since it returns void
                await AddNewHardwareStatus(
                  context,
                  greenhouse_id: '4',
                  component_id: '10',
                  isActive: false,
                  statusNote: 'Not Working',
                );

                // Always add maintenance record after updating status
                await AddMaintenanceRecord(
                  context,
                  title: '${task['title']} (Not Working)',
                  description: task['description']!,
                );

                // Show success dialog
                showCustomDialog(
                  context: context,
                  title: 'Success',
                  message: 'Maintenance Record Saved',
                  icon: Icons.check_circle_sharp,
                  iconColor: const Color.fromARGB(255, 0, 104, 54),
                  backgroundColor: Colors.green[50]!,
                );
              } catch (e) {
                // Handle error
                showCustomDialog(
                  context: context,
                  title: 'Error',
                  message: 'Something went wrong. Please try again later.',
                  icon: Icons.error,
                  iconColor: Colors.red,
                  backgroundColor: Colors.red[50]!,
                );
                print(e);
              }
            },
            child: const Text('Not Working'),
          ),
        ],
      );
    },
  );
}

// maintenance History logss
class MaintenanceLogs extends StatefulWidget {
  const MaintenanceLogs({super.key});

  @override
  _MaintenanceLogsState createState() => _MaintenanceLogsState();
}

class _MaintenanceLogsState extends State<MaintenanceLogs> {
  bool _isExpanded = false;
  List<Map<String, dynamic>> _maintenanceLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

  Future<void> _fetchLogs() async {
    List<Map<String, dynamic>> logs = await fetchMaintenanceLogs();
    setState(() {
      _maintenanceLogs = logs;
    });
    return Future.delayed(const Duration(seconds: 0));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Maintenance Logs:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: _isExpanded ? 350 : 0,
                ),
                child: _maintenanceLogs.isEmpty
                    ? const Center(child: Text('No logs available'))
                    : RefreshIndicator(
                        onRefresh: () => _fetchLogs(),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _maintenanceLogs.length,
                          itemBuilder: (context, index) {
                            final log = _maintenanceLogs[index];
                            return Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.check_circle,
                                      color: Colors.green),
                                  title: Text(log['title'] ?? 'No Title'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Completed on: ${log['date_completed']}'),
                                      const SizedBox(height: 4),
                                      Text(
                                        log['description'] ??
                                            'No description available',
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//component status
class ComponentStatus extends StatefulWidget {
  const ComponentStatus({super.key});

  @override
  _ComponentStatusState createState() => _ComponentStatusState();
}

class _ComponentStatusState extends State<ComponentStatus> {
  bool _isIrrigationExpanded = false;
  bool _isMistingExpanded = false;
  bool _isNutrientControlExpanded = false;
  bool _isCoolingExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Component Status',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          // Two Cards per Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildComponentCard(
                'Irrigation🌾',
                '✓Operational',
                'Check and clean irrigation filters. Ensure no clogging.',
                _isIrrigationExpanded,
                () {
                  setState(() {
                    _isIrrigationExpanded = !_isIrrigationExpanded;
                  });
                },
                Icons.water_drop,
                Colors.blue,
              ),
              const SizedBox(width: 10),
              _buildComponentCard(
                'Misting💧',
                '⚠️Needs checking',
                'Clean misting nozzles and check pump functionality.',
                _isMistingExpanded,
                () {
                  setState(() {
                    _isMistingExpanded = !_isMistingExpanded;
                  });
                },
                Icons.opacity,
                Colors.blueGrey,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildComponentCard(
                'Nutrient🍅',
                '✓Operational',
                'Check nutrient tank levels and ensure proper flow rates.',
                _isNutrientControlExpanded,
                () {
                  setState(() {
                    _isNutrientControlExpanded = !_isNutrientControlExpanded;
                  });
                },
                Icons.local_dining,
                Colors.green,
              ),
              const SizedBox(width: 10),
              _buildComponentCard(
                'Cooling❄️',
                '✓Operational',
                'Check the Indicator on the cooling System',
                _isCoolingExpanded,
                () {
                  setState(() {
                    _isCoolingExpanded = !_isCoolingExpanded;
                  });
                },
                Icons.ac_unit,
                Colors.lightBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponentCard(String title, String status, String maintenance,
      bool isExpanded, VoidCallback onTap, IconData icon, Color iconColor) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          height: isExpanded ? 175 : 90,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: iconColor),
                      const SizedBox(width: 5),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: isExpanded ? double.infinity : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      const Center(
                        child: Text(
                          '🛠Recommendation:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            maintenance,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//sensor & acuators
class GreenhouseActuatorsAndSensors extends StatefulWidget {
  const GreenhouseActuatorsAndSensors({super.key});

  @override
  _GreenhouseActuatorsAndSensorsState createState() =>
      _GreenhouseActuatorsAndSensorsState();
}

class _GreenhouseActuatorsAndSensorsState
    extends State<GreenhouseActuatorsAndSensors> {
  bool _isPumpExpanded = false;
  bool _isFanExpanded = false;
  bool _isLightExpanded = false;
  bool _isSensorExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Actuators and Sensors',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildComponentCard(
                'Pumps🚰',
                '✓Operational',
                'Check pump operation and ensure no leaks.',
                _isPumpExpanded,
                () {
                  setState(() {
                    _isPumpExpanded = !_isPumpExpanded;
                  });
                },
                Icons.water,
                Colors.blue,
              ),
              const SizedBox(width: 10),
              _buildComponentCard(
                'Fans🌬️',
                '⚠️Needs checking',
                'Clean fan blades and check motor functionality.',
                _isFanExpanded,
                () {
                  setState(() {
                    _isFanExpanded = !_isFanExpanded;
                  });
                },
                Icons.air,
                Colors.blueGrey,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildComponentCard(
                'Valves🔧',
                '✓Operational',
                'Check if the valves are working properly',
                _isLightExpanded,
                () {
                  setState(() {
                    _isLightExpanded = !_isLightExpanded;
                  });
                },
                Icons.water_drop_outlined,
                Colors.yellow,
              ),
              const SizedBox(width: 10),
              _buildComponentCard(
                'Sensors📡',
                '✓Operational',
                'Ensure sensors are calibrated and functioning correctly.',
                _isSensorExpanded,
                () {
                  setState(() {
                    _isSensorExpanded = !_isSensorExpanded;
                  });
                },
                Icons.sensors,
                Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponentCard(String title, String status, String maintenance,
      bool isExpanded, VoidCallback onTap, IconData icon, Color iconColor) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          height: isExpanded ? 175 : 90,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: iconColor),
                      const SizedBox(width: 5),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                    color: Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: isExpanded ? double.infinity : 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 5),
                      const Center(
                        child: Text(
                          '🛠Recommendation:',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            maintenance,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCategoryExpander extends StatefulWidget {
  final List<Map<String, dynamic>> categories;

  const _TaskCategoryExpander({required this.categories});

  @override
  _TaskCategoryExpanderState createState() => _TaskCategoryExpanderState();
}

class _TaskCategoryExpanderState extends State<_TaskCategoryExpander> {
  int? _expandedCategoryIndex;

  void _toggleCategory(int index) {
    setState(() {
      if (_expandedCategoryIndex == index) {
        // If tapping the already expanded category, close it
        _expandedCategoryIndex = null;
      } else {
        // Otherwise, expand the new category
        _expandedCategoryIndex = index;
      }
    });
  }

  Widget _buildCollapsibleCategory(BuildContext context, String title,
      List<Map<String, String>> tasks, int index) {
    bool isExpanded = _expandedCategoryIndex == index;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _toggleCategory(index),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(
                isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isExpanded ? 200 : 0,
          child: isExpanded ? _buildTaskGrid(context, tasks) : null,
        ),
      ],
    );
  }

  Widget _buildTaskGrid(BuildContext context, List<Map<String, String>> tasks) {
    return SizedBox(
      height: 200,
      width: MediaQuery.of(context).size.width * 0.8,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _showWorkingNonWorkingDialog(context, tasks[index]);
            },
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      tasks[index]['title']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          tasks[index]['description']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.categories.length, (index) {
        final category = widget.categories[index];
        return Column(
          children: [
            _buildCollapsibleCategory(
                context, category['title'], category['tasks'], index),
            if (index < widget.categories.length - 1)
              const SizedBox(height: 20),
          ],
        );
      }),
    );
  }
}
