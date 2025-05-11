import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greenhouse_monitoring_project/functions/UserFunctions.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Greenhouse {
  final int id;
  final String name;
  final String location;
  double size;
  final String status;
  final String createdAt;

  Greenhouse({
    required this.id,
    required this.name,
    required this.location,
    required this.size,
    required this.status,
    required this.createdAt,
  });

  factory Greenhouse.fromJson(Map<String, dynamic> json) {
    return Greenhouse(
      id: json['greenhouse_id'] ?? 0,
      name: json['name'] ?? 'Unnamed',
      location: json['location'] ?? 'Unknown',
      size: (json['size'] ?? 0).toDouble(),
      status: json['status'] ?? 'N/A',
      createdAt: json['created_at'] ?? 'N/A',
    );
  }
}

class GreenhouseList extends StatefulWidget {
  @override
  _GreenhouseListState createState() => _GreenhouseListState();
}

class _GreenhouseListState extends State<GreenhouseList> {
  late Future<List<Greenhouse>> _greenhousesFuture;

  @override
  void initState() {
    super.initState();
    _greenhousesFuture = fetchGreenhouses();
  }

  Future<List<Greenhouse>> fetchGreenhouses() async {
    final headers = {
      'x-api-key': 'AgreemoCapstoneProject',
    };

    final uri = Uri.parse('https://agreemo-api-v2.onrender.com/greenhouses');

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['greenhouses'];
      return data.map((json) => Greenhouse.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load greenhouses: ${response.reasonPhrase}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Greenhouses')),
      body: FutureBuilder<List<Greenhouse>>(
        future: _greenhousesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No greenhouses found.'));
          }

          final greenhouses = snapshot.data!;
          return ListView.builder(
            itemCount: greenhouses.length,
            itemBuilder: (context, index) {
              final g = greenhouses[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with greenhouse name and Edit button
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              g.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColorDark,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final TextEditingController sizeController =
                                      TextEditingController(
                                          text: g.size.toString());
                                  return AlertDialog(
                                    title: Text('Edit Size for ${g.name}'),
                                    content: TextField(
                                      controller: sizeController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Size (qty.)',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          final newSize = double.tryParse(
                                              sizeController.text);
                                          if (newSize != null) {
                                            updateGreenhouseSize(
                                                    context, g.id, newSize)
                                                .then((_) {
                                              setState(() {
                                                g.size = newSize;
                                              });
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Greenhouse size updated successfully.')),
                                              );
                                              Navigator.of(context).pop();
                                            }).catchError((error) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content:
                                                        Text('Error: $error')),
                                              );
                                            });
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Invalid size value.')),
                                            );
                                          }
                                        },
                                        child: Text('Update'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                Text(
                                  'Edit Size',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColorDark,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.edit,
                                    size: 16,
                                    color: Theme.of(context).primaryColorDark),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InfoRow(
                              icon: Icons.location_on,
                              label: 'Location',
                              value: g.location),
                          InfoRow(
                              icon: Icons.square_foot,
                              label: 'Size',
                              value: '${g.size} qty.'),
                          InfoRow(
                              icon: Icons.verified_user,
                              label: 'Status',
                              value: g.status),
                          InfoRow(
                              icon: Icons.access_time_filled,
                              label: 'Created',
                              value: g.createdAt),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> updateGreenhouseSize(
    BuildContext context, int greenhouseId, double newSize) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? email = prefs.getString('email');
  final headers = {
    'x-api-key': 'AgreemoCapstoneProject',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  final uri =
      Uri.parse('https://agreemo-api-v2.onrender.com/greenhouse/$greenhouseId');
  final body = {'size': newSize.toString(), 'email': email ?? ''};

  final response = await http.patch(uri, headers: headers, body: body);

  if (response.statusCode == 200) {
    print('Greenhouse size updated successfully.');
    showCustomDialog(
        context: context,
        title: 'Success',
        message: 'Greenhouse size updated successfully.',
        icon: Icons.check_circle,
        iconColor: Colors.green,
        backgroundColor: Colors.white);
  } else {
    throw Exception(
        'Failed to update greenhouse size: ${response.reasonPhrase}');
  }
}
