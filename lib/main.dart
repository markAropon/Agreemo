import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'functions/pushNotif.dart';
import 'functions/rootView.dart';
import 'pages/app_login.dart';
import 'pages/dashboard.dart';
import 'pages/landingPage.dart';
//import 'pages/tracker.dart';
//import 'package:firebase_auth/firebase_auth.dart';
//import 'firebase_options.dart';

List<CameraDescription> camera = [];
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Only needed once
  camera = await availableCameras();
  await NotificationService().initialize();
  await Firebase.initializeApp(
      // options: DefaultFirebaseOptions.currentPlatform,
      );
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("bdacb7c4-b045-4a3a-a628-6657a572105a");
  OneSignal.Notifications.requestPermission(true);
  await Hive.initFlutter();
  Hive.openBox("ThisShit");

  /* await Hive.initFlutter();
  await Hive.openBox('userBox');
  Hive.registerAdapter(UserAdapter()); */

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Rootview(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const Dashboard(),
        //'/tracker': (context) => const Tracker(),
        '/landingPage': (context) => const Landingpage(),
      },
    );
  }
}
