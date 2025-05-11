import 'package:flutter/material.dart';
import 'package:greenhouse_monitoring_project/functions/UserFunctions.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ready for Sale'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          } else {
            final data = snapshot.data!;
            final rejectionData = data['rejectionData'] as List<dynamic>;
            final harvestsData = data['harvestsData'] as List<dynamic>;

            final combinedData = [
              ...harvestsData.map((item) => {'type': 'harvest', ...item}),
              ...rejectionData.map((item) => {'type': 'rejection', ...item}),
            ];

            return ListView.builder(
              itemCount: combinedData.isEmpty ? 1 : combinedData.length,
              itemBuilder: (context, index) {
                if (combinedData.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(height: 20),
                      Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 20),
                      Text(
                        'No items available.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                }

                final item = combinedData[index];
                final isHarvest = item['type'] == 'harvest';
                final plantName = item['plant_name'] ?? 'Unknown Plant';
                final id = item['rejection_id']?.toString() ??
                    item['harvest_id']?.toString();

                final price =
                    (double.tryParse(item['price']?.toString() ?? '0') ?? 0) *
                        (double.tryParse(item['quantity']?.toString() ?? '1') ??
                            1);
                final quantity = item['quantity']?.toString() ??
                    item['accepted']?.toString() ??
                    '0';
                final deduction = item['deduction_rate']?.toString() ?? '0';
                final totalPrice = item['total_price']?.toString() ?? '0';
                final date =
                    isHarvest ? item['harvest_date'] : item['rejection_date'];
                final type = item['type'] ?? '';

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading:
                        const Icon(Icons.eco_sharp, color: Colors.greenAccent),
                    title: Text(
                      isHarvest
                          ? 'Harvested $plantName${type.isNotEmpty ? ' ($type)' : ''}'
                          : 'Rejected $plantName${type.isNotEmpty ? ' ($type)' : ''}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Date: $date\nPrice: ₱$price\nQuantity: $quantity',
                    ),
                    onTap: () {
                      final deductionController =
                          TextEditingController(text: deduction);

                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Details for $plantName'),
                            content: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Deduction:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextField(
                                    controller: deductionController,
                                    decoration: const InputDecoration(
                                        hintText: 'Enter deduction'),
                                    keyboardType: TextInputType.number,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text('Total Price:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('₱$totalPrice'),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    final newDeduction =
                                        deductionController.text;
                                    final salesData = {
                                      'currentPrice': totalPrice,
                                      'originalPrice': newDeduction,
                                      'plant_id': item['plant_id'].toString(),
                                      'cropDescription':
                                          item['type']?.toString() ??
                                              'Accepted',
                                      'quantity': quantity,
                                      if (isHarvest)
                                        'harvest_id': id
                                      else
                                        'rejection_id': id,
                                      'user_email':
                                          await SharedPreferences.getInstance()
                                              .then(
                                        (prefs) =>
                                            prefs.getString('email').toString(),
                                      ),
                                    };
                                    print('Submitting sales data: $salesData');
                                    await postSalesData(salesData, context);
                                    print('Sales data submitted successfully.');
                                    showCustomDialog(
                                      context: context,
                                      title: "Success",
                                      message:
                                          'Sales data submitted successfully!',
                                      icon: Icons.check_circle,
                                      iconColor: Colors.green,
                                      backgroundColor: Colors.white,
                                    );
                                  } catch (e) {
                                    print('Error submitting sales data: $e');
                                    showCustomDialog(
                                      context: context,
                                      title: "Error",
                                      message:
                                          'Failed to submit sales data: $e',
                                      icon: Icons.error,
                                      iconColor: Colors.red,
                                      backgroundColor: Colors.white,
                                    );
                                  }
                                },
                                child: const Text('Submit'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

Future<Map<String, dynamic>> fetchData() async {
  final rejectionUrl =
      Uri.parse('https://agreemo-api-v2.onrender.com/reason_for_rejection');
  final harvestsUrl = Uri.parse('https://agreemo-api-v2.onrender.com/harvests');

  try {
    final headers = {'x-api-key': 'AgreemoCapstoneProject'};

    final rejectionResponse = await http.get(rejectionUrl, headers: headers);
    final harvestsResponse = await http.get(harvestsUrl, headers: headers);

    if (rejectionResponse.statusCode == 200 &&
        harvestsResponse.statusCode == 200) {
      final rejectionDecoded = jsonDecode(rejectionResponse.body);
      final harvestsDecoded = jsonDecode(harvestsResponse.body);

      final rejectionData = (rejectionDecoded['reasons_for_rejection'] ?? [])
          .where((item) => item['status'] == 'Not Sold')
          .toList();
      final harvestsData = (harvestsDecoded['harvests'] ?? [])
          .where((item) => item['status'] == 'Not Sold')
          .toList();

      return {
        'rejectionData': rejectionData,
        'harvestsData': harvestsData,
      };
    } else {
      throw Exception('Failed to fetch data. Status codes: '
          '${rejectionResponse.statusCode} (${rejectionResponse.reasonPhrase}), '
          '${harvestsResponse.statusCode} (${harvestsResponse.reasonPhrase})');
    }
  } catch (e) {
    throw Exception('Error fetching data: $e');
  }
}

Future<void> postSalesData(
    Map<String, dynamic> salesData, BuildContext context) async {
  final url = Uri.parse('https://agreemo-api-v2.onrender.com/sales');
  final headers = {'x-api-key': 'AgreemoCapstoneProject'};

  try {
    final response = await http.post(
      url,
      headers: headers,
      body: salesData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Sales data posted successfully: ');
    } else {
      throw Exception('Failed to post sales data. Status code: ');
    }
  } catch (e) {
    throw Exception('Error posting sales data: $e');
  }
}
