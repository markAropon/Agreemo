/* import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:greenhouse_monitoring_project/functions/rootView.dart';
import 'package:greenhouse_monitoring_project/pages/growthMonitor.dart';
import 'package:intl/intl.dart';
import 'package:greenhouse_monitoring_project/pages/ProfilePage.dart';
import 'package:greenhouse_monitoring_project/utility_widgets/graph.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Import for the page indicator

import '../functions/weatherAPI.dart';
import 'HistoryData.dart';

class Landing extends StatefulWidget {
  const Landing({super.key});

  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  final String _city = 'Quezon City, PH';
  String _weatherDescription = '';
  double _temperature = 0.0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference tempRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("sensorReadings/temp");
  final DatabaseReference humidityRef = FirebaseDatabase.instanceFor(
          app: Firebase.app(),
          databaseURL:
              'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app')
      .ref("sensorReadings/humidity");

  String temperature = "Loading...";
  String humidity = "Loading...";

  // PageController for PageView and SmoothPageIndicator
  final PageController _pageController = PageController();

  // Function to get the user's name
  String getUserName() {
    User? user = _auth.currentUser;
    return user?.email ?? "Guest";
  }

  void _fetchData() {
    // Fetch temperature data
    tempRef.onValue.listen((DatabaseEvent event) {
      var temp = event.snapshot.value;

      setState(() {
        if (temp != null) {
          temperature = temp.toString();
        } else {
          temperature = 'No temperature data available';
        }
      });
    }, onError: (error) {
      print('Error fetching temperature data: $error');
      setState(() {
        temperature = 'Error fetching temperature data';
      });
    });

    // Fetch humidity data
    humidityRef.onValue.listen((DatabaseEvent event) {
      var humidityData = event.snapshot.value;

      setState(() {
        if (humidityData != null) {
          humidity = humidityData.toString();
        } else {
          humidity = 'No humidity data available';
        }
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
    _fetchData();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    try {
      final weatherData = await WeatherService().getWeather(_city);
      print("Weather data: $weatherData");
      final description =
          weatherData['weather'][0]['description'].toLowerCase();
      setState(() {
        _weatherDescription = description;
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
    if (weatherDescription.contains('clear')) {
      return const Icon(
        Icons.sunny,
        color: Color.fromARGB(255, 255, 239, 94),
        size: 200,
      );
    } else if (weatherDescription.contains('cloud')) {
      return const Icon(
        Icons.cloud,
        color: Colors.grey,
        size: 200,
      );
    } else if (weatherDescription.contains('rain')) {
      return const Icon(
        Icons.cloudy_snowing,
        color: Colors.blue,
        size: 200,
      );
    } else if (weatherDescription.contains('thunderstorm')) {
      return const Icon(
        Icons.flash_on,
        color: Colors.deepPurple,
        size: 200,
      );
    } else {
      return const Icon(
        Icons.help_outline,
        color: Colors.black,
        size: 200,
      );
    }
  }

  // Function to dynamically set gradient color based on weather
  BoxDecoration getGradient() {
    if (_weatherDescription.contains('clear')) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Color.fromARGB(255, 222, 185, 54),
            Color.fromARGB(255, 248, 241, 241),
          ],
        ),
      );
    } else if (_weatherDescription.contains('cloud')) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Color.fromARGB(255, 237, 217, 66), // grey
            Color.fromARGB(255, 240, 234, 234), // darker grey
          ],
        ),
      );
    } else if (_weatherDescription.contains('rain')) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Color.fromARGB(255, 0, 191, 255), // light blue
            Color.fromARGB(255, 248, 241, 241),
          ],
        ),
      );
    } else if (_weatherDescription.contains('thunderstorm')) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Color.fromARGB(255, 138, 43, 226), // deep purple
            Color.fromARGB(255, 248, 241, 241),
          ],
        ),
      );
    } else {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [
            Color.fromARGB(255, 200, 200, 200), // default grey
            Color.fromARGB(255, 248, 241, 241),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = getUserName();

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! < 0) {
                // Swipe to the right
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Growthmonitor(),
                    //builder: (context) => const FinalModel(),
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: getGradient(), // Apply dynamic gradient here
                child: Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UserProfile(),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.person_2_outlined,
                                size: 20,
                              )),
                          const SizedBox(width: 0),
                          Text(name),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              showMenu(
                                context: context,
                                position: const RelativeRect.fromLTRB(
                                    100.0, 100.0, 0.0, 0.0),
                                items: [
                                  const PopupMenuItem(
                                    value: 'settings',
                                    child: Row(
                                      children: [
                                        Icon(Icons.settings),
                                        SizedBox(width: 8),
                                        Text('Settings'),
                                      ],
                                    ),
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
                                ],
                                elevation: 8.0,
                              ).then((value) {
                                if (value == 'logout') {
                                  logout(context);
                                } else if (value == 'settings') {}
                              });
                            },
                            icon: const Icon(
                              Icons.settings,
                              color: Color.fromARGB(255, 0, 0, 0),
                            ),
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
                                    fontSize: 65,
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
                          Flexible(
                            child: getWeatherIcon(_weatherDescription),
                          ),
                        ],
                      ),
                      const Row(
                        children: [
                          Text(
                            'GRH001 CONDITION',
                            style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 19, 62, 135),
                                letterSpacing: 2),
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          Image.asset('assets/icons/tempBlueIcon.png',
                              height: 30, width: 30),
                          const SizedBox(width: 10),
                          const Text(
                            'Temperature',
                            style: TextStyle(
                              color: Color.fromARGB(255, 2, 46, 83),
                            ),
                          ),
                          const SizedBox(width: 50),
                          Text(
                            '$temperature °C',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(2),
                          ),
                          Image.asset('assets/icons/humidityBlueICon.png',
                              height: 30, width: 30),
                          const SizedBox(width: 10),
                          const Text(
                            'Humidity',
                            style: TextStyle(
                              color: Color.fromARGB(255, 2, 46, 83),
                            ),
                          ),
                          const SizedBox(
                            width: 68,
                          ),
                          Text(
                            '$humidity%',
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromARGB(255, 248, 241, 241),
                                Color.fromARGB(255, 68, 194, 72),
                              ],
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
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
                                              const Growthmonitor(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'GROWTH MONITORING',
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
                              const SizedBox(height: 20),
                              const Graph(),
                              SmoothPageIndicator(
                                controller: _pageController,
                                count: 2, // Number of pages in your PageView
                                effect: WormEffect(
                                  dotWidth: 8.0,
                                  dotHeight: 8.0,
                                  dotColor: Colors.white.withOpacity(0.6),
                                  activeDotColor: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    const Text(
                                      "Expected Growth Rate is 8%\nEach Week",
                                      style: TextStyle(
                                          color: Color.fromARGB(255, 2, 46, 83),
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const Historydata(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_forward,
                                          color: Color.fromARGB(255, 2, 46, 83),
                                        ))
                                  ],
                                ),
                              )
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
          // Add additional pages if needed
          const SizedBox(),
        ],
      ),
    );
  }
}
 */