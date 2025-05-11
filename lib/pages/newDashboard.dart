import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse_monitoring_project/functions/UserFunctions.dart';
import 'package:greenhouse_monitoring_project/functions/sqlite.dart';
import 'package:greenhouse_monitoring_project/functions/weatherAPI.dart';
import 'package:greenhouse_monitoring_project/pages/CropStepper.dart';
import 'package:greenhouse_monitoring_project/utility_widgets/ModulePageview.dart';
import 'package:greenhouse_monitoring_project/utility_widgets/box.dart';
import 'package:greenhouse_monitoring_project/utility_widgets/conditionCard.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:greenhouse_monitoring_project/pages/ProfilePage.dart';
import 'package:greenhouse_monitoring_project/pages/growthMonitor.dart';
import 'package:greenhouse_monitoring_project/utility_widgets/graph.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../functions/AutomationFunction.dart';
import '../functions/HarvestFunctions.dart';
import '../utility_widgets/waterLevelContainers.dart';
import 'app_login.dart';
import 'landingPage.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  String name = '';
  final String _city = 'Quezon City, PH';
  String _weatherDescription = '';
  double _temperature = 0.0;
  final DatabaseReference tempRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref("sensorReadings/temp");
  final DatabaseReference humidityRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref("sensorReadings/humidity");

  String temperature = "Loading...";
  String humidity = "Loading...";
  PageController _pageController = PageController();

  // Flag to prevent repeated notifications for the same event
  bool temperatureNotified = false;

  void _fetchData() {
    tempRef.onValue.listen((DatabaseEvent event) async {
      var temp = event.snapshot.value;
      /*  double temperatureValue =
          temp != null ? double.tryParse(temp.toString()) ?? 0.0 : 0.0; */

      setState(() {
        temperature = temp?.toString() ?? 'No temperature data available';
      });
      /*    if (temperatureValue > 21.0 && !temperatureNotified) {
        await NotificationService().showNotification(
          title: "Greenhouse Alert",
          description:
              "Temperature exceeded the desired level. Manual control may be needed.",
        );
        //PushNotificationService.sendPushNotification();
        temperatureNotified = true;
        Future.delayed(const Duration(minutes: 5), () {
          setState(() {
            temperatureNotified = false;
          });
        });
      } */
    }, onError: (error) {
      print('Error fetching temperature data: $error');
      setState(() {
        temperature = 'Error fetching temperature data';
      });
    });

    humidityRef.onValue.listen((DatabaseEvent event) {
      var humidityData = event.snapshot.value;
      setState(() {
        humidity = humidityData?.toString() ?? 'No humidity data available';
      });
    }, onError: (error) {
      print('Error fetching humidity data: $error');
      setState(() {
        humidity = 'Error fetching humidity data';
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _initialize();
    final dbhelper = DatabaseHelper();
    //clear the database tables if needed
    //dbhelper.clearTable('seedlingsTable');
    dbhelper.clearTable('toHarvest');
    //dbhelper.clearTable('sensorReading');

    dbhelper.updateStatusBasedOnDaysOld();
    fetchGreenhouseList();
    _pageController = PageController(initialPage: 1);
  }

  void _initialize() async {
    _fetchData();
    _fetchWeather();
    _loadName();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    if (email == "markaropon@gmail.com") {
      DateTime? lastRun = prefs.getString('lastRun') != null
          ? DateTime.parse(prefs.getString('lastRun')!)
          : null;
      DateTime now = DateTime.now();

      if (lastRun == null || now.difference(lastRun).inHours >= 6) {
        SensorMonitorService.initializeNotifications();
        SensorMonitorService().monitorSensorData();
        prefs.setString('lastRun', now.toIso8601String());
      }
    }

    if (await checkIfUserIsActive()) {
      forceLogout(context);
      showCustomDialog(
        context: context,
        title: "Session Expired",
        message:
            "Your account Is InActive Contact the Admin if you think this is wrong!",
        icon: Icons.info_outline,
        iconColor: Colors.blue,
        backgroundColor: Colors.white,
        onConfirm: () => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        ),
      );
    }

    // Check if 24 hours have passed since last increment
    final dbhelper = DatabaseHelper();
    String? lastIncrementTimeStr = prefs.getString('lastIncrementTime');

    // Reuse the existing DateTime now variable if needed
    if (lastIncrementTimeStr == null) {
      // First time running the app, increment and save current time
      await dbhelper.incrementDaysOldSeedling();
      dbhelper.updateStatusBasedOnDaysOld();
      await dbhelper.incrementDaysOldGreenhouse();
      prefs.setString('lastIncrementTime', DateTime.now.toString());
    } else {
      // Check if 24 hours have passed since last increment
      DateTime lastIncrementTime = DateTime.parse(lastIncrementTimeStr);
      if (DateTime.now().difference(lastIncrementTime).inHours >= 24) {
        await dbhelper.incrementDaysOldSeedling();
        dbhelper.updateStatusBasedOnDaysOld();
        await dbhelper.incrementDaysOldGreenhouse();
        prefs.setString('lastIncrementTime', DateTime.now.toString());
      }
    }
    final existingHarvestData = await dbhelper.getHarvestData();
    final existingSensorData = await dbhelper.getSensorData();

    if (existingHarvestData.isEmpty) {
      dbhelper.insertHarvestData();
    }

    if (existingSensorData.isEmpty) {
      dbhelper.sensorReadingInsert();
    }
  }

  Future<String?> getEmailFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email');
  }

  Future<bool> checkIfUserIsActive() async {
    var headers = {'x-api-key': 'AgreemoCapstoneProject'};

    try {
      final emailFromPrefs = await getEmailFromSharedPrefs();

      if (emailFromPrefs == null || emailFromPrefs.isEmpty) {
        print("No email found in shared preferences.");
        return false;
      }

      final response = await http.get(
        Uri.parse('https://agreemo-api-v2.onrender.com/users'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> users = json.decode(response.body);

        for (var user in users) {
          if (user['email'] == emailFromPrefs) {
            return user['isActive'] == false;
          }
        }
        print("User not found.");
        return false;
      } else {
        print(
            "Failed to fetch user data. Status Code: ${response.statusCode}, Reason: ${response.reasonPhrase}");
        return false;
      }
    } catch (error) {
      print("Error: $error");
      return false;
    }
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherData = await WeatherService().getWeather(_city);
      setState(() {
        _weatherDescription =
            weatherData['weather'][0]['description'].toLowerCase();
        _temperature = weatherData['main']['temp'];
      });
    } catch (e) {
      print("Error fetching weather: $e");
      setState(() {
        _weatherDescription = 'Error fetching weather';
        _temperature = 0.0;
      });
    }
  }

  Widget getWeatherIcon(String weatherDescription) {
    if (weatherDescription.contains('clear/sunny')) {
      return const Icon(Icons.sunny,
          color: Color.fromARGB(255, 255, 239, 94), size: 160);
    } else if (weatherDescription.contains('cloud')) {
      return const Icon(Icons.wb_cloudy, color: Colors.lightBlue, size: 160);
    } else if (weatherDescription.contains('rain')) {
      return const Icon(Icons.cloudy_snowing,
          color: Color.fromARGB(255, 21, 94, 154), size: 160);
    } else if (weatherDescription.contains('thunderstorm')) {
      return const Icon(Icons.flash_on, color: Colors.deepPurple, size: 160);
    } else {
      return const Icon(Icons.help_outline, color: Colors.black, size: 160);
    }
  }

  Future<void> _loadName() async {
    String userName = await getUserName();
    setState(() {
      name = userName;
    });
  }

  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String fullName = prefs.getString('fullname') ?? '';
    return fullName.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Growthmonitor()),
                );
              }
              if (details.primaryVelocity! > 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CropStepper()),
                );
              }
            },
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 85, 186, 99),
                      Color.fromARGB(255, 240, 250, 240),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              getUserData();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserProfile(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person, size: 30),
                          ),
                          Text(name),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              showMenu(
                                context: context,
                                position: const RelativeRect.fromLTRB(
                                    100.0, 100.0, 0.0, 0.0),
                                items: [
                                  PopupMenuItem(
                                    value: 'ManualControl',
                                    child: const Row(
                                      children: [
                                        Icon(Icons.construction_outlined),
                                        SizedBox(width: 8),
                                        Text('Manual Control'),
                                      ],
                                    ),
                                    onTap: () => toggleControl(context),
                                  ),
                                  const PopupMenuItem(
                                    value: 'logout',
                                    child: Row(
                                      children: [
                                        Icon(Icons.logout),
                                        SizedBox(width: 8),
                                        Text('Logout'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'TermsAndConditions',
                                    child: const Row(
                                      children: [
                                        Icon(Icons.book_online_sharp),
                                        SizedBox(width: 8),
                                        Text('Terms And Conditions'),
                                      ],
                                    ),
                                    onTap: () => showTermsDialog(
                                        context: context,
                                        showAgreeButton: false,
                                        Dismissable: true),
                                  ),
                                ],
                                elevation: 8.0,
                              ).then((value) {
                                if (value == 'logout') {
                                  Userlogout(context);
                                }
                              });
                            },
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                '$_temperature°',
                                style: const TextStyle(
                                    fontSize: 50,
                                    color: Color.fromARGB(255, 2, 46, 83),
                                    fontWeight: FontWeight.w900),
                              ),
                              Text(
                                DateFormat('MMMM d, yyyy EEEE')
                                    .format(DateTime.now()),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color.fromARGB(255, 5, 37, 63)),
                              ),
                            ],
                          ),
                          const SizedBox(width: 50),
                          Flexible(child: getWeatherIcon(_weatherDescription)),
                        ],
                      ),
                      CarouselSlider(
                        items: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Box(
                              height: 230,
                              color: Colors.white.withOpacity(0.7),
                              width: MediaQuery.of(context).size.width * 0.6,
                              BorderColor: Colors.blueAccent,
                              child: Center(
                                child: ConditionCard(
                                  title: 'GRH01 Condition',
                                  tempIconPath: 'assets/icons/tempBlueIcon.png',
                                  humidityIconPath:
                                      'assets/icons/humidityBlueICon.png',
                                  temperature: '$temperature°C',
                                  humidity: '$humidity%',
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Box(
                              height: 150,
                              color: Colors.white.withOpacity(0.7),
                              width: MediaQuery.of(context).size.width * 0.6,
                              BorderColor: Colors.blueAccent,
                              child: const GraphSummary(),
                            ),
                          )
                        ],
                        options: CarouselOptions(
                            height: 130,
                            enlargeCenterPage: true,
                            autoPlay: true,
                            enlargeFactor: 0.1,
                            aspectRatio: 12 / 8,
                            enableInfiniteScroll: true,
                            autoPlayInterval: const Duration(seconds: 5),
                            viewportFraction: 0.5),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color.fromARGB(255, 240, 250, 240),
                              Color.fromARGB(255, 80, 160, 90),
                            ],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Growthmonitor()),
                                      );
                                    },
                                    child: const Text(
                                      'Navigate To ➡️',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color:
                                              Color.fromARGB(255, 19, 62, 135),
                                          letterSpacing: 2,
                                          fontWeight: FontWeight.w800),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10)),
                                height: 270,
                                child: Stack(
                                  children: [
                                    Modulepageview(),
                                    Positioned(
                                      bottom: 10,
                                      left: 0,
                                      right: 0,
                                      child: Center(
                                        child: SmoothPageIndicator(
                                          controller: _pageController,
                                          count: 2,
                                          effect: WormEffect(
                                            dotWidth: 8.0,
                                            dotHeight: 8.0,
                                            dotColor:
                                                Colors.white.withOpacity(0.6),
                                            activeDotColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(
                                height: 30,
                              ),
                              ExpansionTile(
                                title: const Text(
                                  'Reservoir Water Level',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: [
                                  const WaterLevelPage(),
                                ],
                              ),
                              ExpansionTile(
                                title: const Text(
                                  'Solution Level',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                children: [
                                  SolutionLevelPage(),
                                ],
                              ),
                              //const Graph(),
                              SmoothPageIndicator(
                                controller: _pageController,
                                count: 3,
                                effect: WormEffect(
                                  dotWidth: 8.0,
                                  dotHeight: 8.0,
                                  dotColor: Colors.white.withOpacity(0.6),
                                  activeDotColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> toggleControl(BuildContext context) async {
  print('Toggling all controls');

  final DatabaseReference database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  List<String> controlPaths = [
    'valveControl/autoMode/airVentCooling',
    'valveControl/autoMode/ECmeter',
    'valveControl/autoMode/ph',
    'pumpControl/autoMode',
  ];

  try {
    // Fetch all current values first
    bool isCurrentlyAuto = true;
    for (String path in controlPaths) {
      DataSnapshot snapshot = await database.child(path).get();
      int currentValue = snapshot.value as int? ?? 0;
      if (currentValue == 0) {
        isCurrentlyAuto = false;
      }
    }

    // Determine new value: Toggle between 0 (manual) and 1 (auto)
    int newValue = isCurrentlyAuto ? 0 : 1;

    // Batch update all control paths
    Map<String, dynamic> updates = {};
    for (String path in controlPaths) {
      updates[path] = newValue;
    }
    await database.update(updates);

    print("All control paths set to: $newValue");

    // If switching to auto mode, reset all pump and valve controls to 0
    if (newValue == 1) {
      await resetFirebaseData();
      showCustomDialog(
        context: context,
        title: "Automatic Controls Activated",
        message: "All controls are now automatic.",
        icon: Icons.check_circle,
        iconColor: Colors.green,
        backgroundColor: Colors.white,
      );
    } else {
      showCustomDialog(
        context: context,
        title: "Manual Controls Activated",
        message: "All systems are now manually activated.",
        icon: Icons.check_circle,
        iconColor: Colors.green,
        backgroundColor: Colors.white,
      );
    }
  } catch (e) {
    print("Error toggling controls: $e");

    showCustomDialog(
      context: context,
      title: "Something went wrong, try again later",
      message: "",
      icon: Icons.error_outline,
      iconColor: Colors.red,
      backgroundColor: Colors.white,
    );
  }
}

// Reset all pump and valve controls to 0
Future<void> resetFirebaseData() async {
  final DatabaseReference database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  Map<String, dynamic> updates = {
    "pumpControl/exhaust": 0,
    "pumpControl/pump1": 0,
    "pumpControl/pump2": 0,
    "valveControl/phUp": 0,
    "valveControl/phDown": 0,
    "valveControl/sol-A": 0,
    "valveControl/sol-B": 0,
  };

  try {
    await database.update(updates);
    print("All values reset to 0 successfully.");
  } catch (error) {
    print("Error resetting values: $error");
  }
}
