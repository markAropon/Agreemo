import 'package:flutter/material.dart';

import '../functions/HarvestFunctions.dart';

Widget buildSummarySection(int total, int accepted, int rejected,
    double percentage, BuildContext context) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryValue(
                'Total',
                total,
                Colors.blue,
                context,
                dataType: 'total',
              ),
              _buildSummaryValue(
                'Accepted',
                accepted,
                Colors.green,
                context,
                dataType: 'accepted',
              ),
              _buildSummaryValue(
                'Rejected',
                rejected,
                Colors.red,
                context,
                dataType: 'rejected',
              ),
              _buildSummaryValue(
                'Loss Rate',
                '${percentage.toStringAsFixed(0)}%',
                Colors.orange,
                context,
                dataType: 'lossRate',
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildSummaryValue(
    String label, dynamic value, Color valueColor, BuildContext context,
    {required String dataType}) {
  return Expanded(
    child: GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.2,
              maxChildSize: 1,
              builder:
                  (BuildContext context, ScrollController scrollController) {
                return FutureBuilder<Map<String, dynamic>>(
                  future: fetchDataList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text("No data available"));
                    } else {
                      var harvestsData = snapshot.data!['harvestsData'] ?? [];
                      var rejectionData = snapshot.data!['rejectionData'] ?? [];

                      List filteredHarvestsData = [];
                      if (dataType == 'total') {
                        filteredHarvestsData = harvestsData;
                      } else if (dataType == 'accepted') {
                        filteredHarvestsData = harvestsData
                            .where((harvest) =>
                                harvest['accepted'] != null &&
                                harvest['accepted'] > 0)
                            .toList();
                      }

                      List filteredRejectionData = [];
                      if (dataType == 'rejected') {
                        filteredRejectionData =
                            rejectionData.where((rejection) {
                          return rejection['diseased'] > 0 ||
                              rejection['physically_damaged'] > 0 ||
                              rejection['too_small'] > 0;
                        }).toList();
                      }

                      return SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          children: [
                            if (filteredHarvestsData.isNotEmpty) ...[
                              const Text(
                                'Total Harvested this month:',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 350,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredHarvestsData.length,
                                  itemBuilder: (context, index) {
                                    final harvest = filteredHarvestsData[index];
                                    return Card(
                                      elevation: 8,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'GRH: 100${harvest['greenhouse_id']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.blueGrey),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${harvest['plant_type']}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${harvest['harvest_date']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Text(
                                                  'Yield: ${harvest['total_yield']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.lightBlue),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  'Accepted: ${harvest['accepted']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.green),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  'Rejected: ${harvest['total_rejected']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.red),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Notes: ${harvest['notes'] ?? 'No notes available'}',
                                              style: const TextStyle(
                                                fontStyle: FontStyle.italic,
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (filteredRejectionData.isNotEmpty) ...[
                              const Text(
                                'Rejection Data:',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 300,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredRejectionData.length,
                                  itemBuilder: (context, index) {
                                    final rejection =
                                        filteredRejectionData[index];
                                    return Card(
                                      elevation: 8,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                /*    Text(
                                                  'Rejection ID: ${rejection['rejection_id']}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87),
                                                ),
                                                const Spacer(), */
                                                Text(
                                                  'GRH: 100${rejection['greenhouse_id']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.blueGrey),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${rejection['rejection_date']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.black87),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Text(
                                                  'Diseased: ${rejection['diseased']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.red),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  'Physically Damaged: ${rejection['physically_damaged']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Colors.orange),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  'Too Small: ${rejection['too_small']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color.fromARGB(
                                                          255, 108, 108, 0)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Comments: ${rejection['comments'] ?? 'No comments available'}',
                                              style: const TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (filteredHarvestsData.isEmpty &&
                                filteredRejectionData.isEmpty) ...[
                              const Text(
                                'No relevant data available.',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ],
                        ),
                      );
                    }
                  },
                );
              },
            );
          },
        );
      },
      child: Container(
        width: double.infinity - 20,
        height: 85,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: valueColor.withOpacity(0.1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildInputField({
  required String label,
  required Function(String) onChanged,
  required String iconPath,
  bool showDropdown = false,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: label,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 8),
          if (showDropdown)
            Flexible(
              flex: 4,
              child: _buildDropdownField(),
            ),
        ],
      ),
    ),
  );
}

Widget buildAcceptedInputField({
  required TextEditingController acceptedController,
  required String iconPath,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6, // Allocate 60% of the width to the TextField
            child: TextField(
              controller: acceptedController,
              decoration: InputDecoration(
                labelText: 'Add Accepted Crops',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
              keyboardType: TextInputType.number,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDropdownField() {
  return ClipRect(
    child: Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: SizedBox(
        width: 117,
        child: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Reason',
            border: OutlineInputBorder(),
          ),
          items: ['Disease', 'Size', 'Damage'].map((reason) {
            return DropdownMenuItem(
              value: reason,
              child: Text(reason),
            );
          }).toList(),
          onChanged: (value) {},
        ),
      ),
    ),
  );
}

Widget buildProgressBar({
  required int totalHarvested,
  required int acceptedProgress,
  required int diseaseProgress,
  required int sizeProgress,
  required int damageProgress,
}) {
  // Normalize the progress values as a percentage of totalHarvested
  double acceptedPercentage = (acceptedProgress / totalHarvested) * 100;
  double diseasePercentage = (diseaseProgress / totalHarvested) * 100;
  double sizePercentage = (sizeProgress / totalHarvested) * 100;
  double damagePercentage = (damageProgress / totalHarvested) * 100;

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 350),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 187, 219, 246),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: Text(
                  "Accepted",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 224, 125, 118),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: Text(
                  "Disease",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 241, 228, 102),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: Text(
                  "Size",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              Container(
                height: 15,
                width: 15,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 205, 81, 227),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: Text(
                  "Damage",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 20,
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.black.withOpacity(0.3), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildProgressSegment(acceptedPercentage, "Accepted",
                    const Color.fromARGB(255, 187, 219, 246)),
                _buildProgressSegment(diseasePercentage, "Disease",
                    const Color.fromARGB(255, 224, 125, 118)),
                _buildProgressSegment(sizePercentage, "Size",
                    const Color.fromARGB(255, 241, 228, 102)),
                _buildProgressSegment(damagePercentage, "Damage",
                    const Color.fromARGB(255, 205, 81, 227)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Total Harvested: ${totalHarvested.toString()}",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildProgressSegment(double progress, String label, Color color) {
  return Flexible(
    flex: progress.toInt(),
    child: Container(
      color: color,
      child: Stack(
        children: [
          Center(
            child: Text(
              '${progress.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildRejectionInputAndDropdown({
  required TextEditingController rejectionController,
  required String selectedRejectionReason,
  required String iconPath,
  required Function(String?) onChanged,
}) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Icon for Rejection
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 8),

          // Expanded TextField for Rejection Input
          Expanded(
            flex: 6, // Allocate 60% of the width to the TextField
            child: TextField(
              controller: rejectionController,
              decoration: InputDecoration(
                labelText: 'Rejected Crops for $selectedRejectionReason',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
              keyboardType: TextInputType.number,
            ),
          ),

          const SizedBox(
              width: 16), // Space between the text field and dropdown

          // Dropdown for Rejection Reason
          Expanded(
            flex: 4, // Allocate 40% of the width to the Dropdown
            child: DropdownButtonFormField<String>(
              value: selectedRejectionReason,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: 'Reason for Rejection',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.blue.shade50,
              ),
              items: ['Size', 'Damage', 'Disease']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildplantTypeDropdownField() {
  return DropdownButtonFormField<String>(
    decoration: const InputDecoration(
      labelText: 'Select Plant Type',
      border: OutlineInputBorder(),
    ),
    items: const [
      DropdownMenuItem(
        value: 'lettuce',
        child: Text('Lettuce'),
      ),
      DropdownMenuItem(
        value: 'Cucumber',
        child: Text('Cucumber'),
      ),
    ],
    onChanged: (value) {},
  );
}

class ExpandingRejectionCard extends StatefulWidget {
  final String iconPath;
  final String title;
  final List<RejectionReason> rejectionReasons;

  const ExpandingRejectionCard({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.rejectionReasons,
  }) : super(key: key);

  @override
  State<ExpandingRejectionCard> createState() => _ExpandingRejectionCardState();
}

class _ExpandingRejectionCardState extends State<ExpandingRejectionCard> {
  bool _isExpanded = false;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    for (var reason in widget.rejectionReasons) {
      _controllers[reason.label] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Image.asset(
              widget.iconPath,
              height: 24,
              width: 24,
              color: Colors.blueGrey,
            ),
            const SizedBox(width: 8),
            Text(widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        initiallyExpanded: _isExpanded,
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpanded = expanded;
          });
        },
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: widget.rejectionReasons.map((reason) {
                return Column(
                  children: [
                    _buildRejectionTextField(
                      controller: _controllers[reason.label]!,
                      labelText: reason.label,
                      hintText: reason.hint,
                    ),
                    const SizedBox(height: 8),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.blue.shade50,
      ),
    );
  }

  Map<String, String> getRejectionData() {
    return _controllers
        .map((label, controller) => MapEntry(label, controller.text));
  }
}

class RejectionReason {
  final String label;
  final String hint;

  RejectionReason({required this.label, required this.hint});
}
