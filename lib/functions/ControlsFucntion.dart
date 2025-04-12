import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

// Helper function to check autoMode status for ECmeter and pH
Future<bool> isManualControlAllowed(String controlType) async {
  final DatabaseReference database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();

  try {
    if (controlType == "pump") {
      DatabaseReference pumpAutoModeRef =
          database.child("pumpControl/autoMode");
      DataSnapshot pumpSnapshot = await pumpAutoModeRef.get();
      // Debug print to check retrieved value
      if (kDebugMode) print("Pump AutoMode Value: ${pumpSnapshot.value}");
      int pumpValue = int.tryParse(pumpSnapshot.value.toString()) ?? -1;
      return pumpValue == 0;
    } else if (controlType == "valve") {
      // Verify if these paths match your Firebase structure
      DatabaseReference ecAutoModeRef =
          database.child("valveControl/autoMode/ECmeter");
      DatabaseReference phAutoModeRef =
          database.child("valveControl/autoMode/ph");

      DataSnapshot ecSnapshot = await ecAutoModeRef.get();
      DataSnapshot phSnapshot = await phAutoModeRef.get();

      // Debug prints
      if (kDebugMode) {
        print("EC AutoMode Value: ${ecSnapshot.value}");
        print("pH AutoMode Value: ${phSnapshot.value}");
      }

      int ecValue = int.tryParse(ecSnapshot.value.toString()) ?? -1;
      int phValue = int.tryParse(phSnapshot.value.toString()) ?? -1;

      return (ecValue == 0 && phValue == 0);
    } else if (controlType == "exhaust") {
      DatabaseReference exhaustAutoModeRef =
          database.child("valveControl/autoMode/airVentCooling");
      DataSnapshot exhaustSnapshot = await exhaustAutoModeRef.get();
      if (kDebugMode) print("Exhaust AutoMode Value: ${exhaustSnapshot.value}");
      int exhaustValue = int.tryParse(exhaustSnapshot.value.toString()) ?? -1;
      return exhaustValue == 0;
    }
  } catch (error) {
    if (kDebugMode) print("Error checking autoMode for $controlType: $error");
  }
  return false;
}

// Toggle Valve State
Future<void> toggleValveState(String valveName) async {
  if (!await isManualControlAllowed("valve")) {
    if (kDebugMode) print("Manual control blocked: autoMode is enabled.");
    return;
  }

  final DatabaseReference database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  DatabaseReference valveRef = database.child("valveControl/$valveName");

  try {
    DataSnapshot snapshot = await valveRef.get();
    if (snapshot.exists) {
      bool currentValue = (snapshot.value == 1);
      await valveRef.set(currentValue ? 0 : 1);
      if (kDebugMode) {
        print("$valveName state updated to: ${!currentValue}");
      }
    } else {
      if (kDebugMode) print("No data found for $valveName");
    }
  } catch (error) {
    if (kDebugMode) print("Error updating data for $valveName: $error");
  }
}

// Toggle Pump State
Future<void> togglePumpState(int pumpNumber) async {
  if (!await isManualControlAllowed("pump")) {
    if (kDebugMode) print("Manual control blocked: autoMode is enabled.");
    return;
  }

  final DatabaseReference database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  DatabaseReference pumpRef = database.child("pumpControl/pump$pumpNumber");

  try {
    DataSnapshot snapshot = await pumpRef.get();
    if (snapshot.exists) {
      bool currentValue = (snapshot.value == 1);
      await pumpRef.set(currentValue ? 0 : 1);
      if (kDebugMode) {
        print("Pump $pumpNumber state updated to: ${!currentValue}");
      }
    } else {
      if (kDebugMode) print("No data found for pump$pumpNumber");
    }
  } catch (error) {
    if (kDebugMode) print("Error updating data for pump$pumpNumber: $error");
  }
}

// Toggle Exhaust State
Future<void> toggleExhaustState() async {
  if (!await isManualControlAllowed("exhaust")) {
    if (kDebugMode) print("Manual control blocked: autoMode is enabled.");
    return;
  }

  final DatabaseReference database = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://aggreemo-login-default-rtdb.asia-southeast1.firebasedatabase.app',
  ).ref();
  DatabaseReference exhaustRef = database.child("pumpControl/exhaust");

  try {
    DataSnapshot snapshot = await exhaustRef.get();
    if (snapshot.exists) {
      bool currentValue = (snapshot.value == 1);
      await exhaustRef.set(currentValue ? 0 : 1);
      if (kDebugMode) {
        print("Exhaust state updated to: ${!currentValue}");
      }
    } else {
      if (kDebugMode) print("No data found for exhaust");
    }
  } catch (error) {
    if (kDebugMode) print("Error updating data for exhaust: $error");
  }
}
