import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static final NotificationService _singleton = NotificationService._internal();
  factory NotificationService() {
    return _singleton;
  }
  NotificationService._internal();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize method for local notifications
  Future<void> initialize() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('app_icon');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create notification channel (for Android 8.0 and higher)
    _createNotificationChannel();
  }

  // Create notification channel
  void _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channel_id', // The id of the channel.
      'channel_name', // The name of the channel.
      description:
          'Your notification description', // Description of the channel
      importance: Importance.high, // Notification importance
      playSound: true, // Play sound on notification
      enableLights: true, // Enable lights on notification
    );

    final androidPlugin =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(channel);
      print('Notification channel created successfully');
    } else {
      print('Failed to create notification channel');
    }
  }

  // Show a local notification
  Future<void> showNotification({
    required String title,
    required String description,
  }) async {
    const largeIcon = DrawableResourceAndroidBitmap('app_icon');
    const smallIcon = 'app_icon';

    var androidDetails = AndroidNotificationDetails(
      'channel_id', // The id of the notification channel
      'Greenhouse Alerts', // Name of the channel
      channelDescription:
          'Notifications related to greenhouse monitoring', // Channel description
      importance: Importance.high, // Set notification importance
      priority: Priority.high, // Set notification priority
      playSound: true, // Play sound
      enableLights: true, // Enable lights for notification
      largeIcon: largeIcon, // Large icon to show in the notification
      icon: smallIcon, // Small icon for the status bar
      styleInformation: BigTextStyleInformation(
        description, // Description of the notification content
        htmlFormatBigText: true,
        contentTitle: title, // The title of the notification
        htmlFormatContentTitle: true,
      ),
      ticker: 'Greenhouse Alert', // Optional ticker text
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await flutterLocalNotificationsPlugin.show(
        0, // Notification ID
        title, // Notification title
        description, // Notification description
        notificationDetails,
        payload: 'alert', // Optional payload (could be used for interactions)
      );
      print('Notification shown');
    } catch (e) {
      print("Error showing notification: $e");
    }
  }

  void sendPushNotification({
    required String title,
    required String message,
  }) async {
    // Set the URL for the POST request
    final url = Uri.parse('https://onesignal.com/api/v1/notifications');

    // Set the headers for the request
    final headers = {
      'Authorization':
          'basic os_v2_app_xwwlprfqivfdvjrimzl2k4qqliyyfuojxy3uvyv43d2jxqgty32ekx4jsog6gokzr42etqwujekgkyrdwnoflwjfw24gxcybone4hdy',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Set the body of the request
    final body = jsonEncode({
      'app_id': 'bdacb7c4-b045-4a3a-a628-6657a572105a',
      'headings': {'en': title},
      'contents': {'en': message},
      'included_segments': ['All'],
    });

    try {
      // Make the POST request
      final response = await http.post(url, headers: headers, body: body);

      // Check if the request was successful
      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.body}');
      } else {
        print(
            'Failed to send notification. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}

class PushNotificationService {
  // Static method to send notifications, can be accessed globally
  static Future<void> sendPushNotification() async {
    final url = Uri.parse('https://onesignal.com/api/v1/notifications');
    final headers = {
      'Authorization':
          'basic os_v2_app_xwwlprfqivfdvjrimzl2k4qqliyyfuojxy3uvyv43d2jxqgty32ekx4jsog6gokzr42etqwujekgkyrdwnoflwjfw24gxcybone4hdy',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'app_id': 'bdacb7c4-b045-4a3a-a628-6657a572105a',
      'contents': {'en': 'Your message body here.'},
      'included_segments': ['All'],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Notification sent successfully: ${response.body}');
      } else {
        print(
            'Failed to send notification. Status code: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
