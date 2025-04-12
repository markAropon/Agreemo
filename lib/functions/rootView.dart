import 'package:flutter/material.dart';
import '../pages/dashboard.dart';
import '../pages/landingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Rootview extends StatelessWidget {
  const Rootview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == true) {
            return const Dashboard();
          } else {
            return const Landingpage();
          }
        },
      ),
    );
  }

  // Check if session data exists in SharedPreferences (e.g., loginId, fullname, etc.)
  Future<bool> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve session data
    int? loginId = prefs.getInt('loginId');

    // Check if loginId exists (you can check other session data as needed)
    return loginId != null && loginId != 0;
  }
}




//firebase root view 
/* class Rootview extends StatelessWidget {
  const Rootview({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // User is logged in, show Dashboard
            if (snapshot.hasData) {
              return const Dashboard();
            } else {
              return const Landingpage();
            }
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
 */