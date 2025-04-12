import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'pushNotif.dart'; // Assuming this contains your push notification logic

class SensorMonitorService {
  final DatabaseReference tempRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref("sensorReadings");

  static const double MIN_PH = 5.5;
  static const double MAX_PH = 6.5;
  static const double MIN_TDS = 560.0;
  static const double MAX_TDS = 840.0;
  static const double MIN_AIR_TEMP = 15.0;
  static const double MAX_AIR_TEMP = 21.0;
  static const double MIN_HUMIDITY = 40.0;
  static const double MAX_HUMIDITY = 60.0;

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(settings);
  }

  static Future<void> sendNotification(String body, int id) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'Hydroponic Alerts',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      id,
      'Greenhouse Alert',
      body,
      notificationDetails,
    );

    NotificationService()
        .sendPushNotification(title: "GreenHouse Alert", message: body);
  }

  void monitorSensorData() {
    tempRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        double pH = (data['ph'] ?? 0).toDouble();
        double tds = (data['tds'] ?? 0).toDouble();
        double airTemp = (data['temp'] ?? 0).toDouble();
        double humidity = (data['humidity'] ?? 0).toDouble();

        int notificationId = 0;

        if (pH < MIN_PH || pH > MAX_PH) {
          sendNotification('pH level is out of range: $pH', notificationId++);
        }
        if (tds < MIN_TDS || tds > MAX_TDS) {
          sendNotification(
              'TDS level is out of range: $tds ppm', notificationId++);
        }
        if (airTemp < MIN_AIR_TEMP || airTemp > MAX_AIR_TEMP) {
          sendNotification('Greenhouse temperature is out of range: $airTemp°C',
              notificationId++);
        }
        if (humidity < MIN_HUMIDITY || humidity > MAX_HUMIDITY) {
          sendNotification(
              'Humidity level is outs of range: $humidity%', notificationId++);
        }
      } else {
        print("No data found in Firebase.");
      }
    });
  }
}
