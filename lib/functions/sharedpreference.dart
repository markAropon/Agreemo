import 'package:shared_preferences/shared_preferences.dart';

// Generic function to get data from SharedPreferences
Future<T?> getDataFromSharedPreferences<T>(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Check the type of T and retrieve the data accordingly
  if (T == String) {
    return prefs.getString(key) as T?;
  } else if (T == int) {
    return prefs.getInt(key) as T?;
  } else if (T == bool) {
    return prefs.getBool(key) as T?;
  } else if (T == double) {
    return prefs.getDouble(key) as T?;
  } else if (T == List<String>) {
    return prefs.getStringList(key) as T?;
  } else {
    return null;
  }
}
