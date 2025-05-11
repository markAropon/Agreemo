import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../functions/maintenanceFunction.dart';

class ComponentRegistrationStepperDialog extends StatefulWidget {
  const ComponentRegistrationStepperDialog({Key? key}) : super(key: key);

  @override
  _ComponentRegistrationStepperDialogState createState() =>
      _ComponentRegistrationStepperDialogState();
}

class _ComponentRegistrationStepperDialogState
    extends State<ComponentRegistrationStepperDialog> {
  // Step tracking
  int _currentStep = 0;

  // Controllers
  late TextEditingController _emailController;
  final TextEditingController _manufacturerController = TextEditingController();
  final TextEditingController _modelNumberController = TextEditingController();
  final TextEditingController _serialNumberController = TextEditingController();

  // State variables
  String? _selectedGreenhouseId;
  String _selectedComponentType = 'DHT Sensor';

  final List<String> _componentTypes = [
    'DHT Sensor',
    'PH Sensor',
    'TDS Sensor',
    'Valve',
    'Pump',
    'Fan',
    'Camera',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _initializeEmail();
  }

  Future<void> _initializeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController = TextEditingController(
        text: prefs.getString('email') ?? '',
      );
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _manufacturerController.dispose();
    _modelNumberController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  // Validation methods
  bool _validateGreenhouseStep() {
    return _selectedGreenhouseId != null;
  }

  bool _validateComponentStep() {
    return _manufacturerController.text.isNotEmpty;
  }

  // Registration method
  Future<void> _registerComponent() async {
    var headers = {
      'x-api-key': 'AgreemoCapstoneProject',
    };

    var body = {
      'greenhouse_id': _selectedGreenhouseId!,
      'email': _emailController.text,
      'componentName': _selectedComponentType,
      'manufacturer': _manufacturerController.text,
      'model_number': _modelNumberController.text,
      'serial_number': _serialNumberController.text,
    };

    var url = Uri.parse(
        'https://agreemo-api-v2.onrender.com/hardware_components/add');

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        _showErrorDialog();
      }
    } catch (e) {
      print('Request failed: $e');
      _showErrorDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Success'),
          ],
        ),
        content: Text('Component Registered Successfully'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Error'),
          ],
        ),
        content: Text('Failed to Register Component'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Register New Component',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[900],
                ),
              ),
            ),
            Expanded(
              child: Stepper(
                type: StepperType.horizontal,
                currentStep: _currentStep,
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() {
                      _currentStep -= 1;
                    });
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                onStepContinue: () {
                  bool isValidStep = false;
                  switch (_currentStep) {
                    case 0:
                      isValidStep = _validateGreenhouseStep();
                      break;
                    case 1:
                      isValidStep = _validateComponentStep();
                      break;
                    case 2:
                      isValidStep = true;
                      break;
                  }

                  if (isValidStep) {
                    if (_currentStep < 2) {
                      setState(() {
                        _currentStep += 1;
                      });
                    } else {
                      _registerComponent();
                    }
                  } else {
                    _showValidationError();
                  }
                },
                steps: [
                  // Greenhouse Selection Step
                  Step(
                    title: _currentStep == 0 ? Text('Greenhouse') : Text(''),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Greenhouse',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 10),
                        _buildGreenhouseDropdown(),
                        SizedBox(height: 10),
                        Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        TextField(
                          controller: _emailController,
                          readOnly: true,
                          decoration: _inputDecoration('Email'),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 0,
                    state: _currentStep > 0
                        ? StepState.complete
                        : StepState.indexed,
                  ),

                  // Component Details Step
                  Step(
                    title: _currentStep == 1 ? Text('Component') : Text(''),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Component Type',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        //HardwareDropdown(),
                        _buildComponentTypeDropdown(),
                        SizedBox(height: 10),
                        Text(
                          'Manufacturer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        TextField(
                          controller: _manufacturerController,
                          decoration: _inputDecoration('Enter Manufacturer'),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 1,
                    state: _currentStep > 1
                        ? StepState.complete
                        : StepState.indexed,
                  ),

                  // Additional Details Step
                  Step(
                    title: _currentStep == 2 ? Text('Details') : Text(''),
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Additional Information (Optional)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _modelNumberController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Model Number'),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _serialNumberController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Serial Number'),
                        ),
                      ],
                    ),
                    isActive: _currentStep >= 2,
                    state: _currentStep == 2
                        ? StepState.complete
                        : StepState.indexed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Please complete all required fields'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildGreenhouseDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: buildGreenhouseDropdownField(
        onChanged: (value) {
          setState(() {
            _selectedGreenhouseId = value;
          });
        },
        selectedValue: _selectedGreenhouseId,
      ),
    );
  }

  Widget _buildComponentTypeDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedComponentType,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          items: _componentTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedComponentType = newValue!;
            });
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue[700]!),
      ),
    );
  }
}

// Usage function
void showComponentRegistrationStepperDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => const ComponentRegistrationStepperDialog(),
  );
}
