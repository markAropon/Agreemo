import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DataListView extends StatefulWidget {
  final Function? ontap;
  const DataListView({Key? key, this.ontap}) : super(key: key);

  @override
  _DataListViewState createState() => _DataListViewState();
}

class _DataListViewState extends State<DataListView> {
  final String baseUrl = "https://agreemo-api-v2.onrender.com/planted_crops";
  String selectedFilter = "All";

  Future<List<Map<String, dynamic>>> _fetchData() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'x-api-key': 'AgreemoCapstoneProject'},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic jsonData = json.decode(response.body);
        if (jsonData is Map && jsonData.containsKey("planted_crops")) {
          final crops = (jsonData["planted_crops"] as List)
              .where((item) => item["status"] == "not harvested")
              .toList();
          if (crops.isEmpty) {
            return [
              {"message": "No data available"}
            ];
          }
          return crops.map((item) => item as Map<String, dynamic>).toList();
        } else {
          throw Exception("Missing 'planted_crops' key in response");
        }
      } else {
        throw Exception("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  void _handleTap(int greenhouseId) {
    if (widget.ontap != null) {
      widget.ontap!(greenhouseId);
    }
  }

  Future<void> _refreshData() async {
    setState(() {});
  }

  List<Map<String, dynamic>> _filterData(List<Map<String, dynamic>> data) {
    for (var record in data) {
      int totalDaysGrown = record['total_days_grown'] ?? 0;
      if (totalDaysGrown > 30) {
        record['status'] = "Ready for Harvest";
      } else if (totalDaysGrown <= 10) {
        record['status'] = "Just Got Transferred";
      } else {
        record['status'] = "Not Ready for Harvest";
      }
    }
    if (selectedFilter == "All") return data;
    return data.where((record) => record['status'] == selectedFilter).toList();
  }

  Widget _buildFilterButton(String filterLabel) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedFilter == filterLabel ? Colors.green : Colors.grey[300],
          foregroundColor: Colors.black,
        ),
        onPressed: () {
          setState(() {
            selectedFilter = filterLabel;
          });
        },
        child: Text(filterLabel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data found.'));
        }

        final filteredData = _filterData(snapshot.data!);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton("All"),
                    _buildFilterButton("Just Got Transferred"),
                    _buildFilterButton("Ready for Harvest"),
                    _buildFilterButton("Not Ready for Harvest"),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (context, index) {
                        final record = filteredData[index];
                        Color borderColor;
                        String status;
                        int totalDaysGrown = record['total_days_grown'] ?? 0;

                        if (totalDaysGrown > 30) {
                          status = "Ready for Harvest";
                        } else if (totalDaysGrown <= 10) {
                          status = "Just Got Transferred";
                        } else {
                          status = "Not Ready for Harvest";
                        }

                        switch (status) {
                          case "Ready for Harvest":
                            borderColor = Colors.green;
                            break;
                          case "Not Ready for Harvest":
                            borderColor = Colors.red;
                            break;
                          case "Just Got Transferred":
                            borderColor = Colors.blue;
                            break;
                          default:
                            borderColor = Colors.grey;
                        }

                        return GestureDetector(
                          onTap: () {
                            if (status == "Just Got Transferred") {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Center(
                                      child: const Text(
                                    "Notice",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )),
                                  content: const Text(
                                    "This crop was recently transferred and isn't ready yet.",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK")),
                                  ],
                                ),
                              );
                            } else if (status != "Ready for Harvest") {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Center(
                                      child: const Text(
                                    "Confirmation Required",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )),
                                  content: const Text(
                                    "This crop is not yet ready to be harvested. Proceed anyway?",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel")),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _handleTap(record['greenhouse_id']);
                                        },
                                        child: const Text("Proceed")),
                                  ],
                                ),
                              );
                            } else {
                              _handleTap(record['greenhouse_id']);
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 3, color: borderColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                leading: const Icon(Icons.agriculture,
                                    color: Color(0xFF2E7D32)),
                                title: Text(
                                    'Greenhouse ${record['greenhouse_id']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$status'),
                                    Text(
                                        'Planted: ${record['planting_date']?.toString().substring(0, 10) ?? 'Unknown'}'),
                                    Text(
                                        'Days in greenhouse: ${record['greenhouse_daysOld'] ?? 0}'),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Text(status,
                                    style: TextStyle(color: borderColor)),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
