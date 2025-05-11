import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'UserFunctions.dart';
import 'sqlite.dart';

Future<String?> fetchPlantIdForGreenhouse(String greenhouseId) async {
  try {
    final url = Uri.parse(
        'https://agreemo-api-v2.onrender.com/planted_crops?greenhouse_id=$greenhouseId');
    final headers = {'x-api-key': 'AgreemoCapstoneProject'};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Handle the actual response format
      if (data is Map<String, dynamic>) {
        final plantedCrops = data['planted_crops'] as List<dynamic>?;

        if (plantedCrops != null && plantedCrops.isNotEmpty) {
          // Find the first entry with matching greenhouse ID
          final matchingEntry = plantedCrops.firstWhere(
            (entry) => entry['greenhouse_id'].toString() == greenhouseId,
            orElse: () => null,
          );

          if (matchingEntry != null) {
            return matchingEntry['plant_id']?.toString();
          }
        }
      }

      throw Exception('No plant_id found for greenhouse $greenhouseId');
    }
    throw Exception('Failed to fetch plant_id: ${response.statusCode}');
  } catch (e) {
    print('Error fetching plant_id: $e');
    return null;
  }
}

Future<void> submitRejectionData({
  required BuildContext context,
  required String selectedGreenhouseId,
  required String selectedCropType,
  required String deduction,
  required String email,
  required TextEditingController sizeController,
  required String type,
  required String qty,
  required TextEditingController damageController,
  required TextEditingController diseaseController,
  required TextEditingController acceptedController,
  required TextEditingController commentController,
}) async {
  final headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  String? plantId = await fetchPlantIdForGreenhouse(selectedGreenhouseId);
  if (plantId == null) {
    showCustomDialog(
      context: context,
      title: 'Error',
      message: 'Could not find plant ID for greenhouse',
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.white,
    );
    return;
  }

  try {
    // Calculate values
    final totalRejected = [
      int.parse(sizeController.text.isEmpty ? '0' : sizeController.text),
      int.parse(damageController.text.isEmpty ? '0' : damageController.text),
      int.parse(diseaseController.text.isEmpty ? '0' : diseaseController.text),
    ].reduce((a, b) => a + b);

    final accepted = int.tryParse(acceptedController.text) ?? 0;
    final totalYield = accepted + totalRejected;

    // Validate greenhouse size
    final dbHelper = DatabaseHelper();
    final greenhouseData = await dbHelper.queryData(
      'greenhouseTable',
      whereClause: 'id = ?',
      whereArgs: [selectedGreenhouseId],
    );

    if (greenhouseData.isEmpty) throw Exception('Greenhouse not found');

    final greenhouseSize =
        int.tryParse(greenhouseData.first['size']?.toString() ?? '0') ?? 0;
    if (totalYield != greenhouseSize) {
      throw Exception(
          'Harvest count ($totalYield) doesn\'t match greenhouse size ($greenhouseSize)');
    }

    // Prepare rejection data with API-required fields
    final rejectionBody = {
      'greenhouse_id': selectedGreenhouseId.toString(),
      'plant_id': plantId.toString(),
      'email': email,
      'type': type,
      'quantity': qty,
      'rejection_date': DateTime.now().toIso8601String().split('T')[0],
      'price': '100.0',
      'deduction_rate': deduction,
      'comments': commentController.text,
    };

    final harvestBody = {
      'user_email': email,
      'greenhouse_id': selectedGreenhouseId,
      'plant_id': plantId,
      'name': (await SharedPreferences.getInstance()).getString('email') ??
          'Unknown',
      'plant_type': selectedCropType.toLowerCase(),
      'total_yield': totalYield.toString(),
      'accepted': accepted.toString(),
      'total_rejected': totalRejected.toString(),
      'harvest_date': DateTime.now().toIso8601String().split('T')[0],
      'price': '100.0',
      'notes': commentController.text,
    };
    /*    final salesBody = {
      'user_email': email,
      'currentPrice': (100.0 - double.parse(deduction)).toString(),
      'originalPrice': '100.0',
      'plant_id': plantId.toString(),
      'quantity': qty,
    }; */

    // Send requests
    final rejectionResponse = await http.post(
      Uri.parse('https://agreemo-api-v2.onrender.com/reason_for_rejection'),
      headers: headers,
      body: rejectionBody,
    );

    final harvestResponse = await http.post(
      Uri.parse('https://agreemo-api-v2.onrender.com/harvests'),
      headers: headers,
      body: harvestBody,
    );

    // Handle responses
    if (rejectionResponse.statusCode != 201 &&
        harvestResponse.statusCode != 201) {
      sizeController.clear();
      damageController.clear();
      diseaseController.clear();
      acceptedController.clear();
      commentController.clear();
      showCustomDialog(
        context: context,
        title: 'Harvest recorded',
        message: 'Harvest data submitted successfully!',
        icon: Icons.check_circle,
        iconColor: Colors.green,
        backgroundColor: Colors.white,
      );
      throw Exception('''
        Failed to submit data:
        Rejection: ${rejectionResponse.statusCode} - ${rejectionResponse.body}
        Harvest: ${harvestResponse.statusCode} - ${harvestResponse.body}
      ''');
    }
  } catch (e) {
    print(e);
    throw Exception('${e.toString()}');
  }
}

Future<void> submitOnSqlite({
  required BuildContext context,
  required String selectedGreenhouseId,
  required String selectedCropType,
  required String email,
  required TextEditingController sizeController,
  required TextEditingController damageController,
  required TextEditingController diseaseController,
  required TextEditingController acceptedController,
  required TextEditingController commentController,
}) async {
  /*  String? finalMessage;
  String dialogTitle = 'Success';
  IconData dialogIcon = Icons.check_circle_outline;
  Color iconColor = Colors.green;

  bool hasError = false; */

  int totalRejected = 0;
  int accepted = 0;

  try {
    // Debug: Print input values for rejection fields
    print('Size: ${sizeController.text}');
    print('Damage: ${damageController.text}');
    print('Disease: ${diseaseController.text}');
    print('Accepted: ${acceptedController.text}');
    print('Comments: ${commentController.text}');
    print('Selected Greenhouse ID: $selectedGreenhouseId');
    print('Selected Crop Type: $selectedCropType');
    print('Email: $email');

    // Parse rejection values from text controllers
    final rejectionValues = {
      'Size': int.tryParse(sizeController.text) ?? 0,
      'Damage': int.tryParse(damageController.text) ?? 0,
      'Disease': int.tryParse(diseaseController.text) ?? 0,
    };

    totalRejected = rejectionValues.values.reduce((a, b) => a + b);
    accepted = int.tryParse(acceptedController.text) ?? 0;

    print('Parsed Rejection Values: $rejectionValues');
    print('Total Rejected: $totalRejected');
    print('Accepted: $accepted');

    final int totalSize = await _calculateTotalYield(
        selectedGreenhouseId, accepted + totalRejected);
    print('Calculated Total Yield: $totalSize');

    // Fetch greenhouse size from the database
    final dbHelper = DatabaseHelper();
    final greenhouseData = await dbHelper.queryData('greenhouseTable',
        whereClause: 'id = ?', whereArgs: [selectedGreenhouseId]);

    if (greenhouseData.isNotEmpty) {
      final greenhouseSize =
          int.tryParse(greenhouseData.first['size'] ?? '0') ?? 0;

      // Debug: Print greenhouse size
      print('Greenhouse Size: $greenhouseSize');

      // Check if total yield exceeds greenhouse size
      if (totalSize > greenhouseSize) {
        showCustomDialog(
          context: context,
          title: 'Error',
          message: 'Total size exceeds the greenhouse capacity.',
          icon: Icons.error,
          iconColor: Colors.red,
          backgroundColor: Colors.white,
        );
        return;
      }
    } else {
      showCustomDialog(
        context: context,
        title: 'Error',
        message: 'Greenhouse data not found.',
        icon: Icons.error,
        iconColor: Colors.red,
        backgroundColor: Colors.white,
      );
      return;
    }

    // Insert data into 'harvested' table
    final harvestData = {
      'greenhouse_id': selectedGreenhouseId.toString(),
      'plant_type': selectedCropType.toString(),
      'total_yield': totalSize.toString(),
      'accepted': accepted.toString(),
      'total_rejected': totalRejected.toString(),
      'harvest_date': DateTime.now().toIso8601String().split('T')[0].toString(),
      'notes': commentController.text.isEmpty ? '' : commentController.text,
      'email': email,
    };

    // Debug: Print harvest data before inserting
    print('Harvest Data: $harvestData');

    // Use parsed integer values for rejection data
    final rejectionData = {
      'greenhouse_id': selectedGreenhouseId,
      'too_small': rejectionValues['Size'].toString(),
      'physically_damaged': rejectionValues['Damage'].toString(),
      'diseased': rejectionValues['Disease'].toString(),
      'total_rejected': totalRejected.toString(),
      'rejection_date':
          DateTime.now().toIso8601String().split('T')[0].toString(),
      'comments': commentController.text.isEmpty ? '' : commentController.text,
      'email': email,
    };

    // Debug: Print rejection data before inserting
    print('Rejection Data: $rejectionData');

    await dbHelper.insertData('harvested', harvestData);
    await dbHelper.insertData('rejections', rejectionData);

    /*  finalMessage = 'Harvest and rejection data saved successfully!'; */
  } catch (e) {
    /*  hasError = true;
    finalMessage = 'Database error: ${e.toString()}'; */
    print('🔥 Database Error: ${e.toString()}');
  }

  // Show final result dialog
/*   showCustomDialog(
    context: context,
    title: hasError ? 'Submission Issue' : dialogTitle,
    message: finalMessage,
    icon: hasError ? Icons.error_outline_sharp : dialogIcon,
    iconColor: hasError ? Colors.red : iconColor,s
    backgroundColor: Colors.white,s
  ); */
}

Future<void> fetchHarvestData({
  required BuildContext context,
  required Function setTotalHarvested,
  required Function setRejectedPlants,
  required Function setAcceptedPlants,
  required Function setTotalDiseased,
  required Function setTotalSizes,
  required Function setTotalDamged,
}) async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  var harvestRequest = http.Request(
    'GET',
    Uri.parse('https://agreemo-api-v2.onrender.com/harvests'),
  );

  var rejectionRequest = http.Request(
    'GET',
    Uri.parse('https://agreemo-api-v2.onrender.com/reason_for_rejection'),
  );

  harvestRequest.headers.addAll(headers);
  rejectionRequest.headers.addAll(headers);

  try {
    var responses =
        await Future.wait([harvestRequest.send(), rejectionRequest.send()]);

    // Handle harvest data response
    if (responses[0].statusCode == 200) {
      String harvestsResponseString = await responses[0].stream.bytesToString();
      var harvestsData = json.decode(harvestsResponseString);

      var totalHarvested = harvestsData.fold(0, (sum, item) {
        return sum + (item['total_yield'] ?? 0);
      });

      var totalAccepted = harvestsData.fold(0, (sum, item) {
        return sum + (item['accepted'] ?? 0);
      });

      // Extract the total_rejected from the harvests data
      var totalRejected = harvestsData.fold(0, (sum, item) {
        return sum + (item['total_rejected'] ?? 0);
      });

      setTotalHarvested(totalHarvested);
      setAcceptedPlants(totalAccepted);
      setRejectedPlants(totalRejected);
    } else {
      print(responses[0].reasonPhrase);
    }

    // Handle rejection data response
    if (responses[1].statusCode == 200) {
      String rejectionResponseString =
          await responses[1].stream.bytesToString();
      var rejectionData = json.decode(rejectionResponseString);

      // Initialize variables for each rejection reason
      int totalTooSmall = 0;
      int totalDiseased = 0;
      int totalPhysicallyDamaged = 0;

      // Loop through the rejection data and sum each category separately
      for (var rejection in rejectionData) {
        totalTooSmall += (rejection['too_small'] ?? 0) as int;
        totalDiseased += (rejection['diseased'] ?? 0) as int;
        totalPhysicallyDamaged += (rejection['physically_damaged'] ?? 0) as int;
      }

      // Update the state for the UI with the rejection totals
      setTotalDiseased(totalDiseased);
      setTotalSizes(totalTooSmall);
      setTotalDamged(totalPhysicallyDamaged);
      setRejectedPlants(totalTooSmall + totalDiseased + totalPhysicallyDamaged);
    } else {
      /*ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
          content: Text(
              'Failed to load rejection data: ${responses[1].reasonPhrase}'),
        ),
          );*/
      print(responses[1].reasonPhrase);
    }
  } catch (e) {
    /*  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error fetching data: $e')),
    ); */
    print(e);
  }
}

Future<void> GetCardData({
  required BuildContext context,
  required Function setGreenhouses,
}) async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };
  var rejectionRequest = http.Request(
    'GET',
    Uri.parse('https://agreemo-api-v2.onrender.com/reason_for_rejection'),
  );
  rejectionRequest.headers.addAll(headers);
  try {} catch (e) {
    showCustomDialog(
        context: context,
        title: 'Error',
        message: 'Something went Wrong',
        icon: Icons.error_outline_rounded,
        iconColor: Colors.red,
        backgroundColor: Colors.white);
  }
}

Future<Map<String, dynamic>> fetchDataList() async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  var harvestRequest = http.Request(
    'GET',
    Uri.parse('https://agreemo-api-v2.onrender.com/harvests'),
  );

  var rejectionRequest = http.Request(
    'GET',
    Uri.parse('https://agreemo-api-v2.onrender.com/reason_for_rejection'),
  );

  harvestRequest.headers.addAll(headers);
  rejectionRequest.headers.addAll(headers);

  try {
    var responses =
        await Future.wait([harvestRequest.send(), rejectionRequest.send()]);

    List<dynamic> harvestsData = [];
    List<dynamic> rejectionData = [];

    // Handle harvest data response
    if (responses[0].statusCode == 200) {
      String harvestsResponseString = await responses[0].stream.bytesToString();
      //print('Harvests Data: $harvestsResponseString'); // Debug line
      harvestsData = json.decode(harvestsResponseString);
    } else {
      print('Failed to load harvest data: ${responses[0].reasonPhrase}');
    }

    // Handle rejection data response
    if (responses[1].statusCode == 200) {
      String rejectionResponseString =
          await responses[1].stream.bytesToString();
      //print('Rejection Data: $rejectionResponseString'); // Debug line
      rejectionData = json.decode(rejectionResponseString);
    } else {
      print('Failed to load rejection data: ${responses[1].reasonPhrase}');
    }

    return {
      'harvestsData': harvestsData.isNotEmpty ? harvestsData : [],
      'rejectionData': rejectionData.isNotEmpty ? rejectionData : [],
    };
  } catch (e) {
    print('Error: $e');
    return {
      'harvestsData': [],
      'rejectionData': [],
    };
  }
}

Future<int> _calculateTotalYield(String greenhouseId, int total) async {
  print('Calculated yield for greenhouse $greenhouseId: $total');
  return total;
}

//confirm exit dialog
Future<bool> showExitDialog(BuildContext context) async {
  return (await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Exit'),
          content: const Text('Do you want to exit without saving?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Exit'),
            ),
          ],
        ),
      )) ??
      false;
}

Future<List<Map<String, dynamic>>> fetchGreenhouseList() async {
  var headers = {
    'x-api-key': 'AgreemoCapstoneProject',
  };

  var url = Uri.parse('https://agreemo-api-v2.onrender.com/greenhouses');
  var request = http.Request('GET', url);
  request.headers.addAll(headers);

  try {
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();
      final decoded = json.decode(responseBody);

      if (decoded is Map<String, dynamic> && decoded['greenhouses'] is List) {
        final List<dynamic> greenhouseList = decoded['greenhouses'];
        final dbHelper = DatabaseHelper();

        for (var greenhouse in greenhouseList) {
          await dbHelper.insertData('greenhouseTable', {
            'id': greenhouse['greenhouse_id']?.toString() ?? 'Unknown',
            'size': greenhouse['size']?.toString() ?? 'Unknown',
            'status': greenhouse['status']?.toString() ?? 'Unknown',
          });
        }

        return greenhouseList
            .map<Map<String, dynamic>>((greenhouse) => {
                  'id': greenhouse['greenhouse_id']?.toString() ?? 'Unknown',
                  'size': greenhouse['size']?.toString() ?? 'Unknown',
                  'status': greenhouse['status']?.toString() ?? 'Unknown',
                })
            .toList();
      } else {
        print('Unexpected data format: $decoded');
        return [];
      }
    } else {
      print('Request failed with status: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error: $e');
    return [];
  }
}

Future<Map<String, dynamic>> postPlantedCrops({
  required BuildContext context,
  required String selectedGreenhouseId,
}) async {
  try {
    // API URL
    final url = Uri.parse('https://agreemo-api-v2.onrender.com/planted_crops');

    // Headers
    final headers = {
      'x-api-key': 'AgreemoCapstoneProject',
    };

    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> toHarvestData = await dbHelper.queryData(
      'seedlingsTable',
      whereClause: 'greenhouse_id = ?',
      whereArgs: [selectedGreenhouseId],
    );

    // Use the first record from the fetched data
    final harvestRecord = toHarvestData.first;
    final daysOld = harvestRecord['days_old_seedling'];
    final cropCount = harvestRecord['cropCount'];

    final body = {
      'seedlings_daysOld':
          (daysOld != null && daysOld is int) ? daysOld.toString() : '0',
      'count':
          (cropCount != null && cropCount is int) ? cropCount.toString() : '6',
      'greenhouse_id': selectedGreenhouseId,
      'planting_date': harvestRecord['planting_date'] ??
          DateTime.now().toIso8601String().split('T')[0],
      'user_email':
          (await SharedPreferences.getInstance()).getString('email') ?? '',
    };

    print('Sending POST request to: $url');

    final response = await http.post(url, headers: headers, body: body);
    print('Received response: ${response.statusCode} ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      showCustomDialog(
        context: context,
        title: "Plant Recorded",
        message: "Planted crops record saved successfully",
        icon: Icons.check_circle_outline,
        iconColor: Colors.white,
        backgroundColor: Colors.green,
      );
      print('Planted crops record saved successfully');

      return {
        'status': 'success',
        'message': 'Planted crops record saved successfully',
      };
    } else {
      // Handle error response
      print('Error: ${response.reasonPhrase}');
      showCustomDialog(
        context: context,
        title: 'Error',
        message: 'Something went wrong. Please try again Later',
        icon: Icons.error,
        iconColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 198, 64, 64),
      );
      // Return an error message in a map
      return {
        'status': 'error',
        'message': response.reasonPhrase ?? 'Unknown error occurred',
      };
    }
  } catch (e) {
    // Handle exception
    print('Exception occurred: $e');
    showCustomDialog(
      context: context,
      title: 'Error',
      message: 'An unexpected error occurred.',
      icon: Icons.error,
      iconColor: Colors.red,
      backgroundColor: Colors.red[50]!,
    );
    // Return an error message in a map
    return {
      'status': 'error',
      'message': 'An unexpected error occurred',
    };
  }
}
