import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse_monitoring_project/pages/maintenancePagesFolder/TDS.dart';
import 'package:greenhouse_monitoring_project/utility_widgets/component.dart';
import 'package:greenhouse_monitoring_project/utility_widgets/modules.dart';
import '../utility_widgets/MaintenanceUtilities.dart';
import 'maintenancePagesFolder/DHT.dart';
import 'maintenancePagesFolder/PH.dart';

class Maintenancepage extends StatefulWidget {
  const Maintenancepage({super.key});

  @override
  State<Maintenancepage> createState() => _MaintenancepageState();
}

class _MaintenancepageState extends State<Maintenancepage> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    void tdsDialog() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TdsTesting(),
        ),
      );
      print("Container clicked!");
    }

    void phDialog() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhTesting(),
        ),
      );
      print("Container clicked!");
    }

    void dhtDialog() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DHTMaintenancePage(),
        ),
      );
      print("Container clicked!");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensors and Components'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(255, 62, 162, 160),
                Color.fromARGB(255, 79, 177, 223),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 227, 227, 227),
                Color.fromARGB(255, 151, 156, 199),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 15.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 79, 177, 223),
                          Color.fromARGB(255, 62, 162, 160),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              'No Urgent Checking Needed',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Expandable Content
                        AnimatedSize(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: _isExpanded ? 100.0 : 0.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_isExpanded) ...[
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Last Checked:',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                'Jan 15, 2025',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Spacer(),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Next Checking:',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              Text(
                                                'Mar 15, 2025',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  const Center(
                                    child: Text(
                                      'Monitor for irregularities.',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                ],
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        _isExpanded
                                            ? const Icon(Icons.arrow_drop_up,
                                                color: Colors.black38)
                                            : const Icon(Icons.arrow_drop_down,
                                                color: Colors.black38)
                                      ],
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
                const SizedBox(height: 40),
                // Carousel for sensor images
                CarouselSlider(
                  options: CarouselOptions(
                      height: 200,
                      enlargeCenterPage: true,
                      autoPlay: true,
                      aspectRatio: 16 / 9,
                      enableInfiniteScroll: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      viewportFraction: 2 / 4),
                  items: [
                    SensorCard(
                      imageAsset: 'assets/bgImages/tdsSensor.jpg',
                      title: 'TDS SENSOR',
                      testsNeeded: '3',
                      onTap: tdsDialog,
                    ),
                    SensorCard(
                      imageAsset: 'assets/bgImages/phIcon.jpg',
                      title: 'PH SENSOR',
                      testsNeeded: '4',
                      onTap: phDialog,
                    ),
                    SensorCard(
                      imageAsset: 'assets/bgImages/dhtBg.jpg',
                      title: 'DHT SENSOR',
                      testsNeeded: '2',
                      onTap: dhtDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  children: [
                    SquareModule(
                      title: "New Component",
                      color: const Color.fromARGB(255, 75, 105, 214),
                      icon: Icons.build,
                      onTap: () =>
                          showComponentRegistrationStepperDialog(context),
                    ),
                    SquareModule(
                      title: "Add Maintenance",
                      color: const Color.fromARGB(255, 6, 70, 39),
                      icon: Icons.receipt,
                      onTap: () => showTaskCards(context),
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: const Text(
                        'GRH. Sensors & Actuator Status',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        const ComponentStatus(),
                        const SizedBox(height: 20),
                        const GreenhouseActuatorsAndSensors(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                /* Row(
                  children: [
                    const Spacer(),
                    AddNewMaintenanceLog(context),
                  ],
                ), */
                const SizedBox(height: 5),
                const MaintenanceLogs(),
                const SizedBox(height: 40),
                maintenancenTools(context),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
