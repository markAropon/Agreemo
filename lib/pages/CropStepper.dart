import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse_monitoring_project/pages/dashboard.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';

class CropStepper extends StatefulWidget {
  const CropStepper({super.key});

  @override
  _CropStepperState createState() => _CropStepperState();
}

class _CropStepperState extends State<CropStepper> {
  DateTime _startDate = DateTime.now();
  final ScrollController _scrollController = ScrollController();
  List<DateTime> dateList = [];
  int selectedGreenhouseId = 1;
  bool isLoading = false;
  final PageController stepperPage = PageController();

  @override
  void initState() {
    super.initState();
    _fetchPlantingDate();
  }

  Future<void> _fetchPlantingDate() async {
    setState(() => isLoading = true);

    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    try {
      final snapshot = await database
          .child('newlyPlanted/$selectedGreenhouseId/plantingDate')
          .get();

      if (snapshot.exists) {
        String plantingDateStr = snapshot.value as String;
        DateTime plantingDate = DateFormat('MM-dd-yyyy').parse(plantingDateStr);

        setState(() {
          _startDate = plantingDate;
          dateList = List.generate(
              30, (index) => _startDate.add(Duration(days: index)));
          isLoading = false;
        });
      } else {
        print("No data found for greenhouse ID $selectedGreenhouseId");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => isLoading = false);
    }
  }

  void _onGreenhouseChanged(String? value) {
    if (value != null) {
      setState(() {
        selectedGreenhouseId = int.parse(value);
      });
      _fetchPlantingDate();
    }
  }

  String _formattedDate(DateTime date) {
    return DateFormat('EEE, MMM dd').format(date);
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    int todayIndex = dateList.indexWhere((date) =>
        date.day == today.day &&
        date.month == today.month &&
        date.year == today.year);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && todayIndex != -1) {
        _scrollController.animateTo(
          todayIndex * 100.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      body: PageView(
        controller: stepperPage,
        physics: const BouncingScrollPhysics(),
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Dashboard()),
                );
              }
            },
            child: Stack(
              children: [
                // Background image - kept as is
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://images.pexels.com/photos/1072824/pexels-photo-1072824.jpeg?auto=compress&cs=tinysrgb&w=1200',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(color: Colors.black.withOpacity(0.7)),
                ),

                // App title
                Positioned(
                  top: 40,
                  left: 20,
                  child: Text(
                    "Crop Timeline",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),

                // Improved dropdown
                Positioned(
                  top: 85,
                  left: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.cyanAccent.withOpacity(0.5), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    child: DropdownButtonFormField<String>(
                      dropdownColor: Colors.black.withOpacity(0.8),
                      icon: const Icon(Icons.arrow_drop_down_circle,
                          color: Colors.cyanAccent),
                      decoration: const InputDecoration(
                        labelText: 'Select Greenhouse',
                        labelStyle: TextStyle(color: Colors.white),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      value: selectedGreenhouseId.toString(),
                      items: ['1', '2'].map((id) {
                        return DropdownMenuItem<String>(
                          value: id,
                          child: Text('Greenhouse $id'),
                        );
                      }).toList(),
                      onChanged: _onGreenhouseChanged,
                    ),
                  ),
                ),

                // Improved stepper
                Padding(
                  padding: const EdgeInsets.only(left: 40, top: 160, right: 20),
                  child: isLoading
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.cyanAccent,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Loading crop data...",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: dateList.length + 1,
                          itemBuilder: (context, index) {
                            bool isActive = index == todayIndex;
                            bool isPast = index < todayIndex;
                            bool isLastStep = index == dateList.length;
                            if (isLastStep && isActive) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const EndOfCycleDialog();
                                  },
                                );
                              });
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (index > 0 && !isLastStep)
                                  Container(
                                    width: 3,
                                    height: 80,
                                    color: isPast
                                        ? Colors.cyanAccent
                                        : Colors.cyanAccent.withOpacity(0.3),
                                  ),
                                if (!isLastStep)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Row(
                                      children: [
                                        AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 400),
                                          width: isActive ? 50 : 20,
                                          height: isActive ? 50 : 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isPast || isActive
                                                  ? Colors.transparent
                                                  : Colors.cyanAccent
                                                      .withOpacity(0.5),
                                              width: 2,
                                            ),
                                            boxShadow: isActive
                                                ? [
                                                    BoxShadow(
                                                      color: Colors.cyanAccent
                                                          .withOpacity(0.5),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                    )
                                                  ]
                                                : null,
                                            color: isActive
                                                ? Colors.cyanAccent
                                                : isPast
                                                    ? Colors.cyanAccent
                                                        .withOpacity(0.7)
                                                    : Colors.transparent,
                                          ),
                                          child: isActive || isPast
                                              ? Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: isActive ? 24 : 14,
                                                )
                                              : const SizedBox(),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Day ${index + 1}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isActive
                                                      ? Colors.cyanAccent
                                                      : Colors.white
                                                          .withOpacity(0.7),
                                                ),
                                              ),
                                              Text(
                                                _formattedDate(dateList[index]),
                                                style: TextStyle(
                                                  fontSize: isActive ? 20 : 16,
                                                  fontWeight: isActive
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                  color: isActive
                                                      ? Colors.white
                                                      : Colors.white
                                                          .withOpacity(0.8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (isLastStep)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 20.0, bottom: 40),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.redAccent,
                                                Colors.orangeAccent
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.redAccent
                                                    .withOpacity(0.5),
                                                blurRadius: 15,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: const Center(
                                            child: Icon(Icons.flag,
                                                color: Colors.white, size: 30),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        const Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Harvest Day",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                            Text(
                                              "End of Cycle",
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                ),

                // Navigation hint
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.swipe_left,
                            color: Colors.white.withOpacity(0.7), size: 16),
                        const SizedBox(width: 5),
                        Text(
                          "Swipe for dashboard",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EndOfCycleDialog extends StatelessWidget {
  const EndOfCycleDialog({super.key});

  static Future<List<Map<String, dynamic>>> _fetchSeedlingsData() async {
    final DatabaseReference database = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
    ).ref();

    try {
      final snapshot = await database.child('seedlings').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        List<Map<String, dynamic>> seedlings = [];

        data.forEach((key, value) {
          if (value is Map) {
            final Map<String, dynamic> seedling = Map<String, dynamic>.from(
              value.map((k, v) => MapEntry(k.toString(), v)),
            );
            seedling['id'] = key;
            seedlings.add(seedling);
          }
        });

        return seedlings;
      } else {
        print("No seedling data found");
        return [];
      }
    } catch (e) {
      print("Error fetching seedling data: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.grey[900],
      title: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSeedlingsData(),
        builder: (context, snapshot) {
          return Row(
            children: [
              const Icon(Icons.flag, color: Colors.redAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  snapshot.connectionState == ConnectionState.waiting
                      ? "Loading seedling data..."
                      : snapshot.hasData && snapshot.data!.isNotEmpty
                          ? "End of Cycle - ${snapshot.data!.first['seedlingName'] ?? 'Seedling'}"
                          : "End of Cycle",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      ),
      content: const Text(
        "You have reached the harvest day. Your crop cycle is complete!",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
