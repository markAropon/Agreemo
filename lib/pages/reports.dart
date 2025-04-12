import 'package:flutter/material.dart';

class Reports extends StatelessWidget {
  const Reports({super.key});

  @override
  Widget build(BuildContext context) {
    // List of example reports (maintenance and harvested crops)
    final List<String> reports = [
      "Maintenance Report - Cooling System Check (Feb 14, 2025)",
      "Maintenance Report - Misting Pump Calibration (Feb 15, 2025)",
      "Maintenance Report - Irrigation System Check (Feb 16 2025)",
      "Harvested Crops Report - Lettuce (Feb 2025)",
      "Harvested Crops Report - Lettuce (Mar 2025)",
    ];

    // Function to simulate report generation
    void generateReport() {
      // Add a new simulated report
      reports.add("New Report - ${DateTime.now().toString()}");
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance & Harvest Reports'),
        backgroundColor: Colors.greenAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Simulate report generation when refresh button is pressed
              generateReport();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Reports:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(
                        reports[index],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      leading: Icon(
                        // Choose different icons based on report type
                        reports[index].contains("Maintenance")
                            ? Icons.build
                            : Icons.eco,
                        color: Colors.greenAccent,
                      ),
                      onTap: () {
                        // Handle tapping a report to view details (could open another screen)
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Report Details'),
                            content: Text('Details for: ${reports[index]}'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                generateReport();
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                backgroundColor: Colors.greenAccent,
              ),
              child: const Text('Generate New Report'),
            ),
          ],
        ),
      ),
    );
  }
}

//fetch all the data needed for reports
void maintenanceReports() {}
void harvestReports() {}
