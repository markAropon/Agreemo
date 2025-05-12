import 'dart:convert';
import 'package:greenhouse_monitoring_project/functions/UserFunctions.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> AddMaintenanceRecord(
  BuildContext context, {
  required String title,
  required String description,
}) async {
  // Retrieve the email and name from SharedPreferences
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = prefs.getString('email') ??
      ''; // Default to empty string if no email found
  String name = prefs.getString('fullname') ??
      ''; // Default to empty string if no name found

  if (email.isEmpty || name.isEmpty) {
    showCustomDialog(
      context: context,
      title: 'Error',
      message: 'No email or name found in preferences.',
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.red[50]!,
    );
    return;
  }

  print('Starting maintenance record addition...');
  print('Title: $title, Description: $description, Email: $email, Name: $name');

  try {
    final url = Uri.parse('https://agreemo-api-v2.onrender.com/maintenance');
    final headers = {
      'x-api-key': 'AgreemoCapstoneProject',
      'Content-Type': 'application/x-www-form-urlencoded',
    };
    final body = {
      'email': email,
      'name': name,
      'title': title,
      'description': description,
    };

    print('Sending POST request to: $url');
    final response = await http.post(url, headers: headers, body: body);
    print('Received response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      /*  showCustomDialog(
        context: context,
        title: 'Success',
        message: 'Maintenance Record Saved',
        icon: Icons.check_circle_sharp,
        iconColor: const Color.fromARGB(255, 0, 104, 54),
        backgroundColor: Colors.green[50]!,
      ); */
      print('Maintenance record saved successfully');
    } else {
      /*   showCustomDialog(
        context: context,
        title: 'Error',
        message: 'Something went wrong. Please try again.',
        icon: Icons.error,
        iconColor: const Color.fromARGB(255, 170, 6, 82),
        backgroundColor: Colors.redAccent[50]!,
      ); */
      /*    showCustomDialog(
        context: context,
        title: 'Error',
        message: 'An unexpected error occurred.',
        icon: Icons.error,
        iconColor: Colors.red,
        backgroundColor: Colors.red[50]!,
      ); */
      print(response.reasonPhrase);
    }
  } catch (e) {
    print('Exception occurred: $e');
    showCustomDialog(
      context: context,
      title: 'Error',
      message: 'An unexpected error occurred.',
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.red[50]!,
    );
  }
}

// Simplified fetch function with debugging
Future<List<Map<String, dynamic>>> fetchMaintenanceLogs() async {
  print('Fetching maintenance logs...');
  try {
    final url = Uri.parse('https://agreemo-api-v2.onrender.com/maintenance');
    final headers = {'x-api-key': 'AgreemoCapstoneProject'};

    print('Sending GET request to: $url');
    final response = await http.get(url, headers: headers);
    print('Received response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      print('Successfully parsed ${data.length} records');
      return data.reversed
          .map((log) => {
                'title': log['title'],
                'description': log['description'],
                'date_completed': log['date_completed'],
              })
          .toList();
    }

    print('Failed to fetch logs: ${response.reasonPhrase}');
    return [];
  } catch (e) {
    print('Error fetching logs: $e');
    return [];
  }
}

Future<void> AddNewHardwareStatus(
  BuildContext context, {
  required String greenhouse_id,
  required String component_id,
  required bool isActive,
  required String statusNote,
}) async {
  try {
    final url =
        Uri.parse('https://agreemo-api-v2.onrender.com/hardware_status/add');
    final headers = {
      'x-api-key': 'AgreemoCapstoneProject',
    };
    final body = {
      'greenhouse_id': greenhouse_id,
      'component_id': component_id,
      'isActive': isActive.toString(),
      'statusNote': statusNote,
    };

    print('Sending POST request to: $url');
    final response = await http.post(url, headers: headers, body: body);
    print('Received response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print("Hardware Status Added");
    } else {
      print(response.reasonPhrase);
    }
  } catch (e) {
    print('Exception occurred: $e');
  }
}

Future<void> registerNewComponents(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String email = prefs.getString('email') ?? '';
  TextEditingController emailController = TextEditingController(text: email);
  TextEditingController componentNameController = TextEditingController();
  TextEditingController manufacturerController = TextEditingController();
  TextEditingController modelNumberController = TextEditingController();
  TextEditingController serialNumberController = TextEditingController();
  String? selectedGreenhouseId;

  int? expandedTileIndex;

  String selectedComponentType = 'DHT Sensor';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Register New Components',
              style: TextStyle(
                color: Colors.blueGrey[900],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  ExpansionTile(
                    key: Key('tile1'),
                    initiallyExpanded: expandedTileIndex == 0,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        expandedTileIndex = expanded ? 0 : null;
                      });
                    },
                    title: Text(
                      'Greenhouse Details',
                      style: TextStyle(
                        color: Colors.blueGrey[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      buildGreenhouseDropdownField(
                        onChanged: (value) {
                          selectedGreenhouseId = value;
                        },
                        selectedValue: selectedGreenhouseId,
                      ),
                      _buildTextField(emailController, 'Email', readOnly: true),
                    ],
                  ),
                  ExpansionTile(
                    key: Key('tile2'),
                    initiallyExpanded: expandedTileIndex == 1,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        expandedTileIndex = expanded ? 1 : null;
                      });
                    },
                    title: Text(
                      'Component Details',
                      style: TextStyle(
                        color: Colors.blueGrey[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      _buildTextField(manufacturerController, 'Manufacturer',
                          isRequired: true),
                    ],
                  ),
                  ExpansionTile(
                    key: Key('tile3'),
                    initiallyExpanded: expandedTileIndex == 2,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        expandedTileIndex = expanded ? 2 : null;
                      });
                    },
                    title: Text(
                      'Additional Details',
                      style: TextStyle(
                        color: Colors.blueGrey[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    children: [
                      _buildTextField(modelNumberController, 'Model Number',
                          keyboardType: TextInputType.number),
                      _buildTextField(serialNumberController, 'Serial Number',
                          keyboardType: TextInputType.number),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blueGrey[700]),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (selectedGreenhouseId != null) {
                    registerComponent(
                      context: context,
                      greenhouseId: selectedGreenhouseId!,
                      email: emailController.text,
                      componentName: selectedComponentType,
                      manufacturer: manufacturerController.text,
                      modelNumber: modelNumberController.text,
                      serialNumber: serialNumberController.text,
                    );
                    selectedGreenhouseId = "";
                    componentNameController.clear();
                    manufacturerController.clear();
                    modelNumberController.clear();
                    serialNumberController.clear();
                  } else if (componentNameController.text.isEmpty ||
                      manufacturerController.text.isEmpty) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10),
                              Text('Error'),
                            ],
                          ),
                          content: Text(
                              'PLease enter a Component Name and Manufacturer.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Row(
                            children: [
                              Icon(
                                Icons.error,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10),
                              Text('Error'),
                            ],
                          ),
                          content: Text('Please select a greenhouse.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text(
                  'Register',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

clearTextFields(
    TextEditingController emailController,
    TextEditingController componentNameController,
    TextEditingController manufacturerController,
    TextEditingController modelNumberController,
    TextEditingController serialNumberController) {}

// Helper method to create text fields with consistent styling
Widget _buildTextField(TextEditingController controller, String label,
    {TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool isRequired = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        labelStyle: TextStyle(color: Colors.blueGrey[600]),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[300]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[300]!),
        ),
      ),
      readOnly: readOnly,
    ),
  );
}

Widget buildGreenhouseDropdownField({
  required Function(String?) onChanged,
  required String? selectedValue,
}) {
  return FutureBuilder<List<String>>(
    future: _getGreenhouseIds(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return const Text('No greenhouses available');
      } else {
        List<String> greenhouseList = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Greenhouse ID',
              labelStyle: TextStyle(color: Colors.blueGrey[600]),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blueGrey[200]!),
              ),
            ),
            value: selectedValue,
            items: greenhouseList.map((greenhouseId) {
              return DropdownMenuItem<String>(
                value: greenhouseId,
                child: Text('Greenhouse $greenhouseId'),
              );
            }).toList(),
            onChanged: (value) {
              onChanged(value);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a greenhouse';
              }
              return null;
            },
          ),
        );
      }
    },
  );
}

Future<void> registerComponent({
  required BuildContext context,
  required String greenhouseId,
  required String email,
  required String componentName,
  required String manufacturer,
  required String modelNumber,
  required String serialNumber,
}) async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  var body = {
    'greenhouse_id': greenhouseId,
    'email': email,
    'componentName': componentName,
    'manufacturer': manufacturer,
    'model_number': modelNumber,
    'serial_number': serialNumber,
  };

  var url =
      Uri.parse('https://agreemo-api-v2.onrender.com/hardware_components/add');

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      showCustomDialog(
          context: context,
          title: 'success',
          message: 'Component Registered',
          icon: Icons.check_circle_sharp,
          iconColor: const Color.fromARGB(255, 0, 104, 54),
          backgroundColor: Colors.green[50]!);
    } else {
      showCustomDialog(
          context: context,
          title: 'Error',
          message: 'An unexpected error occurred.',
          icon: Icons.error,
          iconColor: Colors.red,
          backgroundColor: Colors.red[50]!);
    }
  } catch (e) {
    print('Request failed: $e');
  }
}

// Helper function to convert List<Map<String, dynamic>> to List<String> for the dropdown
Future<List<String>> _getGreenhouseIds() async {
  // Get the greenhouse data
  try {
    final url = Uri.parse('https://agreemo-api-v2.onrender.com/greenhouses');
    final headers = {'x-api-key': 'AgreemoCapstoneProject'};

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data.containsKey('greenhouses')) {
        final greenhouseList = data['greenhouses'] as List;
        return greenhouseList
            .map<String>((greenhouse) => greenhouse['greenhouse_id'].toString())
            .toList();
      }
      return [];
    }
    return [];
  } catch (e) {
    print('Error fetching greenhouse list: $e');
    return [];
  }
}

Future<List<Map<String, dynamic>>> fetchComponentData() async {
  print('Fetching component data...');
  try {
    final url =
        Uri.parse('https://agreemo-api-v2.onrender.com/hardware_components');
    final headers = {'x-api-key': 'AgreemoCapstoneProject'};

    print('Sending GET request to: $url');
    final response = await http.get(url, headers: headers);
    print('Received response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      print('Successfully parsed ${data.length} records');
      return data
          .map((component) => {
                'componentName': component['componentName'],
                'manufacturer': component['manufacturer'],
                'model_number': component['model_number'],
                'serial_number': component['serial_number'],
                'greenhouse_id': component['greenhouse_id'],
              })
          .toList();
    }

    print('Failed to fetch component data: ${response.reasonPhrase}');
    return [];
  } catch (e) {
    print('Error fetching component data: $e');
    return [];
  }
}

class HardwareDropdown extends StatefulWidget {
  const HardwareDropdown({Key? key}) : super(key: key);

  @override
  _HardwareDropdownState createState() => _HardwareDropdownState();
}

class _HardwareDropdownState extends State<HardwareDropdown> {
  List<Map<String, dynamic>> _componentTypes = [];
  Map<String, dynamic>? _selectedComponent;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchComponentTypes();
  }

  Future<void> _fetchComponentTypes() async {
    try {
      // Fetch hardware status
      final statusResponse = await http.get(
        Uri.parse('https://agreemo-api-v2.onrender.com/hardware_status'),
        headers: {'x-api-key': 'AgreemoCapstoneProject'},
      );

      // Fetch hardware components
      final componentsResponse = await http.get(
        Uri.parse('https://agreemo-api-v2.onrender.com/hardware_components'),
        headers: {'x-api-key': 'AgreemoCapstoneProject'},
      );

      if (statusResponse.statusCode == 200 &&
          componentsResponse.statusCode == 200) {
        final List<dynamic> statusData = json.decode(statusResponse.body);
        final List<dynamic> componentsData =
            json.decode(componentsResponse.body);

        // Filter "Not Working" components and map to their full details
        final Set<String> uniqueComponentIds = Set<String>();
        final List<Map<String, dynamic>> notWorkingComponents = [];

        for (var statusItem in statusData) {
          if (statusItem['statusNote'] == 'Not Working') {
            String componentId = statusItem['component_id'].toString();

            // Avoid duplicates
            if (uniqueComponentIds.add(componentId)) {
              // Find matching component details
              final matchingComponent = componentsData.firstWhere(
                (comp) => comp['component_id'].toString() == componentId,
                orElse: () => null,
              );

              if (matchingComponent != null) {
                notWorkingComponents.add({
                  'id': componentId,
                  'name':
                      matchingComponent['componentName'] ?? 'Unknown Component',
                });
              }
            }
          }
        }

        setState(() {
          _componentTypes = notWorkingComponents.isNotEmpty
              ? notWorkingComponents
              : [
                  {'id': '0', 'name': 'No Components Available'}
                ];
          _selectedComponent = _componentTypes.first;
          _isLoading = false;
        });
      } else {
        _handleError();
      }
    } catch (e) {
      _handleError();
    }
  }

  void _handleError() {
    setState(() {
      _componentTypes = [
        {'id': '0', 'name': 'Unable to Load'}
      ];
      _selectedComponent = _componentTypes.first;
      _isLoading = false;
      _hasError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedComponent,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          hint: _isLoading
              ? Text('Loading...', style: TextStyle(color: Colors.grey))
              : Text('Select Component', style: TextStyle(color: Colors.grey)),
          items: _componentTypes.map((Map<String, dynamic> component) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: component,
              child: Text(
                component['name'],
                style: TextStyle(
                  color: _hasError ||
                          component['name'] == 'No Components Available' ||
                          component['name'] == 'Unable to Load'
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            );
          }).toList(),
          onChanged: _hasError ||
                  _componentTypes.first['name'] == 'No Components Available'
              ? null
              : (Map<String, dynamic>? newValue) {
                  setState(() {
                    _selectedComponent = newValue;
                  });
                },
        ),
      ),
    );
  }
}
