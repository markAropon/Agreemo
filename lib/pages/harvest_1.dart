import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenhouse_monitoring_project/functions/UserFunctions.dart';
import 'package:greenhouse_monitoring_project/utility_widgets/harvestUtilities.dart';
import '../functions/HarvestFunctions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utility_widgets/harvestDatalist.dart';

class Harvest1 extends StatefulWidget {
  const Harvest1({super.key});

  @override
  _HarvestTrackerPageState createState() => _HarvestTrackerPageState();
}

class _HarvestTrackerPageState extends State<Harvest1> {
  int totalHarvested = 0;
  int rejectedPlants = 0;
  int acceptedPlants = 0;

  int acceptedProgress = 0;
  int diseaseProgress = 0;
  int sizeProgress = 0;
  int damageProgress = 0;

  bool isExpanded = false;
  TextEditingController commentController = TextEditingController();

  int selectedGreenhouseId = 0;
  TextEditingController sizeController = TextEditingController();
  TextEditingController Damage = TextEditingController();
  TextEditingController Disease = TextEditingController();
  TextEditingController acceptedController = TextEditingController();

  String name = "";

  // Add a page controller to handle navigation
  final PageController _pageController = PageController(initialPage: 0);

  Future<void> _loadName() async {
    String userName = await getUserName();
    setState(() {
      name = userName;
    });
  }

  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fullName = prefs.getString('fullname') ?? 'Not available';
    return fullName;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    _loadName();
  }

  Future<void> fetchData() async {
    await fetchHarvestData(
      context: context,
      setTotalHarvested: (int harvested) {
        setState(() {
          totalHarvested = harvested;
        });
      },
      setAcceptedPlants: (int accepted) {
        setState(() {
          acceptedPlants = accepted;
        });
      },
      setRejectedPlants: (int rejected) {
        setState(() {
          rejectedPlants = rejected;
        });
      },
      setTotalDamged: (int totalDamaged) {
        setState(() {
          damageProgress = totalDamaged;
        });
      },
      setTotalDiseased: (int totalDiseased) {
        setState(() {
          diseaseProgress = totalDiseased;
        });
      },
      setTotalSizes: (int totalSizes) {
        setState(() {
          sizeProgress = totalSizes;
        });
      },
    );
  }

  // Function to submit data to the API
  Future<void> submitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    bool isSuccess = true;
    String errorMessage = '';

    if (email == null) {
      print("Error: No email found in SharedPreferences");
      return;
    }

    try {
      if (sizeController.text.isNotEmpty &&
          int.parse(sizeController.text) > 0) {
        await submitRejectionData(
          context: context,
          selectedGreenhouseId: selectedGreenhouseId.toString(),
          acceptedController: acceptedController,
          commentController: commentController,
          email: email,
          selectedCropType: 'lettuce',
          sizeController: sizeController,
          damageController: Damage,
          diseaseController: Disease,
          deduction: '5',
          type: 'too_small',
          qty: sizeController.text,
        );
      }

      if (Damage.text.isNotEmpty && int.parse(Damage.text) > 0) {
        await submitRejectionData(
          context: context,
          selectedGreenhouseId: selectedGreenhouseId.toString(),
          acceptedController: acceptedController,
          commentController: commentController,
          email: email,
          selectedCropType: 'lettuce',
          sizeController: sizeController,
          damageController: Damage,
          diseaseController: Disease,
          deduction: '7',
          type: 'physically_damaged',
          qty: Damage.text,
        );
      }

      if (Disease.text.isNotEmpty && int.parse(Disease.text) > 0) {
        await submitRejectionData(
          context: context,
          selectedGreenhouseId: selectedGreenhouseId.toString(),
          acceptedController: acceptedController,
          commentController: commentController,
          email: email,
          selectedCropType: 'lettuce',
          sizeController: sizeController,
          damageController: Damage,
          diseaseController: Disease,
          deduction: '10',
          type: 'diseased',
          qty: Disease.text,
        );
      }
    } catch (e) {
      isSuccess = false;
      errorMessage = e.toString();

      print("Error submitting rejection data: $e");

      submitOnSqlite(
        context: context,
        selectedGreenhouseId: selectedGreenhouseId.toString(),
        selectedCropType: 'lettuce',
        email: email,
        sizeController: sizeController,
        damageController: Damage,
        diseaseController: Disease,
        acceptedController: acceptedController,
        commentController: commentController,
      );
    } finally {
      showCustomDialog(
        context: context,
        title: isSuccess ? 'Harvest recorded' : 'Error',
        message: isSuccess
            ? 'Harvest data submitted successfully!'
            : errorMessage.replaceAll('Exception:', ''),
        icon: isSuccess ? Icons.check_circle : Icons.error,
        iconColor: isSuccess ? Colors.green : Colors.red,
        backgroundColor: Colors.white,
      );
    }
  }

  void ontap() {
    _pageController.animateToPage(
      1,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    double rejectionPercentage =
        totalHarvested > 0 ? (rejectedPlants / totalHarvested) * 100 : 0;

    // Use safe calculation for progress bar
    double acceptedProgressPercentage =
        totalHarvested > 0 ? (acceptedPlants / totalHarvested) : 0;
    double diseaseProgressPercentage =
        totalHarvested > 0 ? (diseaseProgress / totalHarvested) : 0;
    double sizeProgressPercentage =
        totalHarvested > 0 ? (sizeProgress / totalHarvested) : 0;
    double damageProgressPercentage =
        totalHarvested > 0 ? (damageProgress / totalHarvested) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Harvest'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              if (_pageController.page?.round() == 0) {
                Navigator.pop(context);
              } else {
                _pageController.animateToPage(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            },
            icon: Icon(Icons.arrow_back)),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color.fromARGB(255, 35, 158, 156),
                Colors.lightBlue.shade200
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.lightBlue.shade200],
            ),
          ),
          child: PageView(
            controller: _pageController,
            // Disable swiping between pages
            physics: NeverScrollableScrollPhysics(),
            onPageChanged: (int page) {
              setState(() {});
            },
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        DataListView(
                          ontap: (int greenhouseId) {
                            setState(() {
                              selectedGreenhouseId = greenhouseId;
                            });
                            ontap();
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.020,
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Tap to record your harvest information',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blueGrey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward,
                                    color: Colors.blueGrey),
                              ],
                            ),
                          ),
                        ),
                      ]),
                ),
              ),

              // Second page with harvest tracking UI
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Text(
                                  'Harvest Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Selected Greenhouse ID: $selectedGreenhouseId',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      Spacer(),
                                    ],
                                  ),
                                  Text(
                                    'Estimated Dimension: 9x11 with 4 leaves',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  Text(
                                    'Estimated Number of Leaves: 6',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      buildSummarySection(totalHarvested, acceptedPlants,
                          rejectedPlants, rejectionPercentage, context),
                      const SizedBox(height: 16),
                      _buildExpandableSection(
                          acceptedProgressPercentage:
                              acceptedProgressPercentage,
                          diseaseProgressPercentage: diseaseProgressPercentage,
                          sizeProgressPercentage: sizeProgressPercentage,
                          damageProgressPercentage: damageProgressPercentage),
                      const SizedBox(height: 16),
                      buildAcceptedInputField(
                        acceptedController: acceptedController,
                        iconPath: 'assets/icons/harvest.png',
                      ),
                      const SizedBox(height: 16),
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ExpansionTile(
                          title: Row(
                            children: [
                              Image.asset(
                                'assets/icons/deadplant.png',
                                width: 26,
                                height: 26,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Add Rejected Plants',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildRejectionTextField(
                                      controller: sizeController,
                                      labelText: "Too Small",
                                      hintText: ''),
                                  const SizedBox(height: 14),
                                  _buildRejectionTextField(
                                      controller: Damage,
                                      labelText: "Damaged",
                                      hintText: ''),
                                  const SizedBox(height: 14),
                                  _buildRejectionTextField(
                                      controller: Disease,
                                      labelText: "Diseased",
                                      hintText: ''),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildCommentField(),
                      const SizedBox(height: 16),
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required double acceptedProgressPercentage,
    required double diseaseProgressPercentage,
    required double sizeProgressPercentage,
    required double damageProgressPercentage,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: AnimatedContainer(
              width: double.infinity, // Full width
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              child: ListTile(
                title: const Text(
                  'More Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: AnimatedRotation(
                  duration: const Duration(milliseconds: 500),
                  turns: isExpanded ? 0.5 : 0,
                  child: const Icon(Icons.expand_more),
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            child: Container(
              width: double.infinity, // Full width
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              constraints: isExpanded
                  ? const BoxConstraints(maxHeight: 300)
                  : const BoxConstraints(),
              child: isExpanded
                  ? SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.stretch, // Stretch children
                        children: [
                          buildProgressBar(
                            totalHarvested: totalHarvested,
                            acceptedProgress:
                                (acceptedProgressPercentage * 100).toInt(),
                            diseaseProgress:
                                (diseaseProgressPercentage * 100).toInt(),
                            sizeProgress:
                                (sizeProgressPercentage * 100).toInt(),
                            damageProgress:
                                (damageProgressPercentage * 100).toInt(),
                          ),
                          const SizedBox(height: 16),
                          _buildRejectionStatsPage(),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionStatsPage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children
        children: [
          const Text(
            'Rejection Reasons',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildStatCard(
              'Disease', int.tryParse(Disease.text) ?? 0, 'Due to disease'),
          _buildStatCard(
              'Size', int.tryParse(sizeController.text) ?? 0, 'Too small'),
          _buildStatCard(
              'Damage', int.tryParse(Damage.text) ?? 0, 'Physical damage'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int value, String reason) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 60,
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  reason,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$value',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentField() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: commentController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: 'Comment',
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.blue.shade50,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Colors.lightBlue.shade200,
            const Color.fromARGB(255, 39, 198, 195),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          submitData();
        },
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: const Text(
          'Submit',
          style: TextStyle(fontSize: 16, color: Colors.black, letterSpacing: 4),
        ),
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
        // Ensure the text field takes up full width
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Future<void> _onRefresh() async {
    await fetchData();
    sizeController.clear();
    Damage.clear();
    Disease.clear();
    selectedGreenhouseId = 0;
    acceptedController.clear();
    commentController.clear();
  }

  void showAddPlantedCropsDialog(BuildContext context) {
    // Define controllers for the input fields
    final TextEditingController daysOldController = TextEditingController();
    final TextEditingController countController = TextEditingController();

    // Show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.eco_sharp, color: Colors.greenAccent),
              const SizedBox(width: 8),
              const Text('Add Planted Crops'),
            ],
          ),
          content: Container(
            width: double.maxFinite, // Make dialog wider
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch children
              children: [
                const Text('Enter the details for the newly planted crops:'),
                const SizedBox(height: 16),
                // Days Old input
                TextFormField(
                  controller: daysOldController,
                  decoration: const InputDecoration(
                    labelText: 'Days Old',
                    hintText: 'Enter days old',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                // Count input
                TextFormField(
                  controller: countController,
                  decoration: const InputDecoration(
                    labelText: 'Count',
                    hintText: 'Enter count of crops',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly, // Ensure only numbers are entered
                  ],
                ),
              ],
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            // Confirm button
            TextButton(
              onPressed: () {
                final greenhouseId = selectedGreenhouseId.toString();
                final daysOld = daysOldController.text;
                final count = countController.text;

                print(
                    'greenhouseId: $greenhouseId, daysOld: $daysOld, count: $count');

                if (greenhouseId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please Choose greenhouse ID')),
                  );
                } else if (daysOld.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid number of days')),
                  );
                } else if (count.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid count')),
                  );
                } else {
                  postPlantedCrops(
                    selectedGreenhouseId: greenhouseId,
                    context: context,
                  ).then((response) {
                    print('Planted crops response: $response');
                  }).catchError((error) {
                    showCustomDialog(
                      context: context,
                      title: "Error",
                      message: error.toString(),
                      icon: Icons.error_outline,
                      iconColor: Colors.white,
                      backgroundColor: Colors.redAccent,
                    );
                    print(error.toString());
                  });
                }
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
