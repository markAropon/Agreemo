import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_login.dart'; // Import your login page
import 'signUpv2.dart'; // Import your sign-up page

class Landingpage extends StatefulWidget {
  const Landingpage({Key? key}) : super(key: key);

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  @override
  void initState() {
    super.initState();
    _checkTermsAgreement();
  }

  _checkTermsAgreement() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? agreed = prefs.getBool('terms_agreed');

    if (agreed == null || !agreed) {
      showTermsDialog(context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 27, 58, 105),
              Color.fromARGB(255, 97, 174, 236),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Image.asset(
                    'assets/icons/app_icon.png',
                    height: 200,
                    width: 200,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/Group127.png',
                        fit: BoxFit.fill,
                        width: 50,
                        height: 50,
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'GREEMO',
                        style: TextStyle(
                          color: Color.fromARGB(255, 0, 151, 8),
                          fontSize: 50,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Agriculture Green Monitoring',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 50,
              bottom: 40,
              child: TextButton(
                onPressed: () {
                  goToLogin(context);
                },
                child: const Text(
                  'Log In',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 50,
              bottom: 40,
              child: TextButton(
                onPressed: () {
                  goToSignUp(context);
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void goToSignUp(BuildContext context) {
    Navigator.push(
      context,
      _createSheetTransition(const Signupv2(), fromBottom: true),
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.push(
      context,
      _createSheetTransition(const LoginScreen(), fromBottom: false),
    );
  }

  PageRouteBuilder _createSheetTransition(Widget page,
      {required bool fromBottom}) {
    final begin = fromBottom ? const Offset(0.0, 1.0) : const Offset(0.0, -1.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}

Future<void> showTermsDialog({
  required BuildContext context,
  bool showAgreeButton = true,
  bool Dismissable = true,
  VoidCallback? onAgree,
}) async {
  const termsContent = """
    1. Introduction\n\n
    Welcome to AGREEMO, an Android application for Solar-Powered Hydroponic Greenhouse Management. This system is designed to monitor plant growth, automate nutrient distribution, and provide real-time environmental tracking. By using this application, you agree to comply with the following terms and conditions.

    2. System Usage\n\n
    The AGREEMO system is designed for hydroponic farming and should be used for plant monitoring, nutrient control, and environmental regulation.
    The application requires an active internet connection to access real-time data from Firebase and PostgreSQL servers.
    Only authorized users (Farm Manager, Assistant Manager, and Farmers) can access the system with assigned permissions.

    3. Data Collection and Privacy\n\n
    The system collects sensor data (pH, TDS, temperature, humidity) to optimize plant growth and automate irrigation.
    Image processing with Yolov8 is used to analyze growth stages.
    User account data, including login credentials, is secured via Firebase Authentication.
    The collected data will not be shared with third parties without user consent.

    4. Responsibilities of Users\n\n
    Users must ensure proper setup and calibration of sensors and IoT components.
    Farmers must manually refill water reservoirs when notified by the system.
    Users should regularly update the app to ensure compatibility with system updates.

    5. Limitations of Liability\n\n
    AGREEMO is not responsible for crop failures due to power outages, sensor malfunctions, or incorrect system settings.
    The solar panel system powers only specific components (sensors, misting, ventilation) and does not guarantee 24/7 operation.
    The system does not include pest control mechanisms; farmers must manually handle pest management.

    6. Modifications and Updates\n\n
    AGREEMO developers may update the system to improve automation, data accuracy, and security.
    Users will be notified of major updates, and continued use of the application implies agreement with new terms.

    7. Termination of Access\n\n
    The Farm Manager has the right to restrict access to users who misuse or manipulate system data.
    AGREEMO reserves the right to suspend or terminate services if users attempt to tamper with IoT hardware or software settings.

    8. Agreement Confirmation\n\n
    By using the AGREEMO system, you confirm that you have read, understood, and agreed to these terms.
  """;

  showDialog(
    barrierDismissible: Dismissable,
    context: context,
    builder: (context) {
      return AlertDialog(
        scrollable: true,
        title: Text(
          'Terms and Agreement',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Container(
          height: 300,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  termsContent,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                if (showAgreeButton)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        onPressed: () async {
                          if (onAgree != null) {
                            onAgree();
                          }

                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool('terms_agreed', true);
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'I Agree',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
