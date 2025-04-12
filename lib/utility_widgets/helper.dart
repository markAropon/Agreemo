import 'package:firebase_database/firebase_database.dart';

class FirebaseDataService {
  final DatabaseReference database;

  FirebaseDataService({required this.database});

  Future<String> getData(String path) async {
    try {
      // Get the reference for the given path
      final ref = database.ref;

      // Fetch the data
      final snapshot = await ref.get();

      // Check if data exists
      if (snapshot.exists) {
        return snapshot.value.toString();
      } else {
        return 'No data available';
      }
    } catch (e) {
      return 'Error fetching data: $e';
    }
  }
}
