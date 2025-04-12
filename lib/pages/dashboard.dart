// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:greenhouse_monitoring_project/pages/HistoryData.dart';
import 'package:greenhouse_monitoring_project/pages/MaintenancePage.dart';
import '../functions/HarvestFunctions.dart';
//import 'dashboardLanding.dart';
import 'dataReading.dart';
import 'newDashboard.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    //Newdashboard(),
    Landing(),
    Datareading(),
    //Harvest(),
    Historydata(),
    Maintenancepage(),
  ];

  // This method can be used to navigate to the HistoryData page
  void navigateToHistoryData(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Historydata()),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    return await showExitDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        body: _pages[_selectedIndex],
        floatingActionButtonLocation: ExpandableFab.location,
        floatingActionButton: ExpandableFab(
          distance: 55.0,
          key: GlobalKey<ExpandableFabState>(),
          type: ExpandableFabType.up,
          overlayStyle: ExpandableFabOverlayStyle(
            color: Colors.black.withOpacity(0.5),
            blur: 5,
          ),
          children: [
            _buildExpandableButton(Icons.home, 'Home', 0),
            _buildExpandableButton(Icons.water, 'Water Monitoring', 1),
            _buildExpandableButtonFromAsset(
                'assets/icons/harvestIcon.png', 'Harvest', 2),
            _buildExpandableButton(Icons.history, 'History data', 3),
            _buildExpandableButton(Icons.construction, 'Maintenance', 4),
          ],
        ),
      ),
    );
  }

  // Helper function to build an expandable button with an icon and label
  Widget _buildExpandableButton(IconData icon, String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () {
              if (index >= 0) {
                setState(() {
                  _selectedIndex = index;
                });
              } else {
                // Navigate to History data page
                navigateToHistoryData(context);
              }
            },
            child: Icon(icon, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableButtonFromAsset(
      String assetPath, String label, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Text(
              label,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () {
              if (index >= 0) {
                setState(() {
                  _selectedIndex = index;
                });
              } else {
                // Navigate to History data page
                navigateToHistoryData(context);
              }
            },
            child: Image.asset(
              assetPath,
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
    );
  }
}
