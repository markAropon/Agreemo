import 'package:flutter/material.dart';
import 'package:greenhouse_monitoring_project/pages/PlantStatus.dart';
import '../pages/HistoryData.dart';
import '../pages/MaintenancePage.dart';
import '../pages/dataReading.dart';
import '../pages/harvest_1.dart';
import '../pages/plantMonitoring.dart';
import '../pages/reports.dart';
import '../pages/inventory.dart';
import 'modules.dart';

class Modulepageview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    Modules(
                      title: "Water Monitoring",
                      color: Colors.deepPurple,
                      icon: Icons.water,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const Datareading(),
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    Modules(
                      title: "Plant Monitoring",
                      color: Colors.green.shade900,
                      icon: Icons.eco_sharp,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const Plantmonitoring(),
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    Modules(
                      title: "Growth History",
                      color: const Color.fromARGB(255, 34, 18, 60),
                      icon: Icons.history_sharp,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const Historydata(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Modules(
                      title: "Greenhouse Maintenance",
                      color: const Color.fromARGB(255, 63, 63, 63),
                      icon: Icons.construction_sharp,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const Maintenancepage(),
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    Modules(
                      title: "Harvest",
                      color: const Color.fromARGB(255, 16, 185, 129),
                      icon: Icons.local_florist,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const Harvest1(),
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    Modules(
                      title: "Reports",
                      color: const Color.fromARGB(255, 20, 61, 96),
                      icon: Icons.note_alt_sharp,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => const Reports(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Second page with the third row (the second page of the PageView)
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Modules(
                        title: 'Inventory',
                        color: const Color.fromARGB(255, 24, 34, 25),
                        icon: Icons.inventory,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const InventoryPage(),
                            ),
                          );
                        },
                      ),
                      Modules(
                        title: 'Readings Status',
                        color: const Color.fromARGB(255, 38, 135, 41),
                        icon: Icons.info_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (BuildContext context) =>
                                  const Plantstatus(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
