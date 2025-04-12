import 'dart:async';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'greenhouse_monitoring.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE seedlingsTable (
      Cropid INTEGER PRIMARY KEY AUTOINCREMENT,
      greenhouse_id INTEGER,
      days_old_seedling INTEGER DEFAULT 0,
      days_in_greenhouse INTEGER DEFAULT 0,
      crop_count INTEGER
    );
  ''');
    await db.execute('''
    CREATE TABLE greenhouseTable (
      id INTEGER PRIMARY KEY,  
      size INETEGER,
      status TEXT
    );
  ''');
    await db.execute('''
    CREATE TABLE toHarvest (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      greenhouse_id INTEGER,
      seedlings_daysOld INTEGER,
	    greenhouse_daysOld INTEGER,
      total_days_grown INTEGER DEFAULT 0,
   	  planting_date DATETME,
      status TEXT
    );
  ''');
    await db.execute('''
  CREATE TABLE Harvested (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    greenhouse_id INTEGER NOT NULL,
    plant_type TEXT NOT NULL,
    accepted INTEGER NOT NULL,
    total_yield INTEGER DEFAULT 0,
    total_rejected INTEGER DEFAULT 0,
    harvest_date TEXT NOT NULL,
    status TEXT NOT NULL
  );
''');
    await db.execute('''
  CREATE TABLE Rejections (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    greenhouse_id INTEGER NOT NULL,
    too_small INTEGER DEFAULT 0,
    physically_damaged INTEGER DEFAULT 0,
    diseased INTEGER DEFAULT 0,
    total_rejected INTEGER DEFAULT 0,
    rejection_date TEXT NOT NULL,
    comments TEXT,
    email TEXT NOT NULL
  );
''');
    await db.execute('''
    CREATE TABLE sensorReading (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    current_temperature REAL,
    current_humidity REAL,
    current_ph INTEGER,
    current_ec REAL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    greenhouse_id INTEGER
    )
''');
  }

  Future<int> insertData(String table, Map<String, dynamic> data) async {
    Database db = await database;
    return await db.insert(table, data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateData(String table, Map<String, dynamic> data,
      String whereClause, List<dynamic> whereArgs) async {
    Database db = await database;
    return await db.update(table, data,
        where: whereClause, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> JoinQueryData() async {
    final db = await database;

    // Perform the JOIN operation between seedlingsTable and toHarvest
    List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT * 
    FROM seedlingsTable AS s
    JOIN toHarvest AS t ON s.greenhouse_id = t.greenhouse_id;
  ''');

    return result;
  }

  Future<List<Map<String, dynamic>>> queryData(String tableName,
      {String? whereClause, List<dynamic>? whereArgs}) async {
    final db = await database;
    return await db.query(tableName, where: whereClause, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> HarvestQuery(
      String table, int greenhouseId) async {
    Database db = await database;
    return await db.query(
      table,
      where: 'greenhouse_id = ?',
      whereArgs: [greenhouseId],
    );
  }

  Future<int> deleteData(
      String table, String whereClause, List<dynamic> whereArgs) async {
    Database db = await database;
    return await db.delete(table, where: whereClause, whereArgs: whereArgs);
  }

  Future<void> clearTable(String tableName) async {
    Database db = await database;
    await db.delete(tableName);
    print("All data from table $tableName has been cleared.");
  }

  Future<void> incrementDaysOldSeedling() async {
    Database db = await database;
    await db.rawUpdate(
        'UPDATE seedlingsTable SET days_old_seedling = days_old_seedling + 1');
  }

  Future<void> incrementDaysOldGreenhouse() async {
    Database db = await database;
    await db.rawUpdate(
        'UPDATE toHarvest SET greenhouse_daysOld = greenhouse_daysOld + 1');
  }

  // Timer to update every 24 hours
  Timer? _dailyUpdateTimer;

  Future<List<Map<String, dynamic>>> getHarvestData() async {
    final db = await database;
    return await db.query('toHarvest');
  }

  Future<List<Map<String, dynamic>>> getSensorData() async {
    final db = await database;
    return await db.query('sensorReading');
  }

  void startDailyUpdateTimer() {
    // Cancel existing timer if any
    _dailyUpdateTimer?.cancel();

    // Run every 24 hours
    _dailyUpdateTimer = Timer.periodic(Duration(hours: 24), (_) {
      incrementDaysOldSeedling();
      incrementDaysOldGreenhouse();
    });
  }

  void stopDailyUpdateTimer() {
    _dailyUpdateTimer?.cancel();
    _dailyUpdateTimer = null;
  }

  Future<void> updateStatusBasedOnDaysOld() async {
    final db = await database;

    var result = await db.query('toHarvest');

    for (var record in result) {
      int greenhouseDaysOld = (record['greenhouse_daysOld'] as int?) ?? 0;

      String status;
      if (greenhouseDaysOld > 26) {
        status = 'Ready for Harvest';
      } else if (greenhouseDaysOld >= 5 && greenhouseDaysOld <= 26) {
        status = 'Not Ready for Harvest';
      } else if (greenhouseDaysOld < 5) {
        status = 'Just Got Transferred';
      } else {
        status = 'Undefined';
      }

      await db.update(
        'toHarvest',
        {'status': status},
        where: 'id = ?',
        whereArgs: [record['id']],
      );
    }
  }

  Future<void> insertHarvestData() async {
    final db = await database;

    // List of data to be inserted
    final dataToInsert = [
      // Ready for Harvest
      {
        'greenhouse_id': 1,
        'seedlings_daysOld': 10,
        'greenhouse_daysOld': 35,
        'planting_date': DateTime.now()
            .subtract(Duration(days: 35))
            .toIso8601String(), // Convert DateTime to ISO 8601 string
        'status': 'Ready for Harvest'
      },
      {
        'greenhouse_id': 2,
        'seedlings_daysOld': 7,
        'greenhouse_daysOld': 30,
        'planting_date': DateTime.now()
            .subtract(Duration(days: 30))
            .toIso8601String(), // Convert DateTime to ISO 8601 string
        'status': 'Ready for Harvest'
      },
      {
        'greenhouse_id': 3,
        'seedlings_daysOld': 5,
        'greenhouse_daysOld': 33,
        'planting_date': DateTime.now()
            .subtract(Duration(days: 33))
            .toIso8601String(), // Convert DateTime to ISO 8601 string
        'status': 'Ready for Harvest'
      },
      {
        'greenhouse_id': 4,
        'seedlings_daysOld': 2,
        'greenhouse_daysOld': 31,
        'planting_date': DateTime.now()
            .subtract(Duration(days: 31))
            .toIso8601String(), // Convert DateTime to ISO 8601 string
        'status': 'Ready for Harvest'
      },

      // Not Ready for Harvest
      {
        'greenhouse_id': 5,
        'seedlings_daysOld': 3,
        'greenhouse_daysOld': 20,
        'planting_date': DateTime.now()
            .subtract(Duration(days: 20))
            .toIso8601String(), // Convert DateTime to ISO 8601 string
        'status': 'Not Ready for Harvest'
      },
      {
        'greenhouse_id': 6,
        'seedlings_daysOld': 5,
        'greenhouse_daysOld': 22,
        'planting_date': DateTime.now()
            .subtract(Duration(days: 22))
            .toIso8601String(), // Convert DateTime to ISO 8601 string
        'status': 'Not Ready for Harvest'
      },
      {
        'greenhouse_id': 7,
        'seedlings_daysOld': 7,
        'greenhouse_daysOld': 24,
        'planting_date': DateTime.now()
            .subtract(Duration(days: 24))
            .toIso8601String(), // Convert DateTime to ISO 8601 string
        'status': 'Not Ready for Harvest'
      },
      {
        'greenhouse_id': 8,
        'seedlings_daysOld': 9,
        'greenhouse_daysOld': 21,
        'planting_date': DateTime.now()
            .subtract(Duration(days: 21))
            .toIso8601String(), // Convert DateTime to ISO 8601 string
        'status': 'Not Ready for Harvest'
      },

      // Just Got Transferred
      {
        'greenhouse_id': 9,
        'seedlings_daysOld': 1,
        'greenhouse_daysOld': 2,
        'planting_date':
            DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
        'status': 'Just Got Transferred'
      },
      {
        'greenhouse_id': 10,
        'seedlings_daysOld': 2,
        'greenhouse_daysOld': 3,
        'planting_date':
            DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'status': 'Just Got Transferred'
      },
      {
        'greenhouse_id': 11,
        'seedlings_daysOld': 2,
        'greenhouse_daysOld': 3,
        'planting_date':
            DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
        'status': 'Not Ready for Harvest'
      },
    ];

    // Insert the data
    for (var record in dataToInsert) {
      await db.insert(
        'toHarvest',
        record,
        conflictAlgorithm:
            ConflictAlgorithm.replace, // Avoid conflict during insert
      );
      print('Inserted record: $record'); // Debugging statement
    }
    try {
      print(
          'All data has been inserted into the toHarvest table.'); // Debugging statement
    } catch (e) {
      print(
          'Failed to insert data into the toHarvest table: $e'); // Debugging statement for failure
    }
  }

  Future<void> sensorReadingInsert() async {
    final db = await database;

    // List of data to be inserted
    final Random _random = Random();
    double generateInRange(double min, double max) {
      return min + _random.nextDouble() * (max - min);
    }

    final dataToInsert = [
      {
        'id': 1,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp': DateTime.now().toIso8601String(),
      },
      {
        'id': 2,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
      },
      {
        'id': 3,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 3)).toIso8601String(),
      },
      {
        'id': 4,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 4)).toIso8601String(),
      },
      {
        'id': 5,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 5)).toIso8601String(),
      },
      {
        'id': 6,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 6)).toIso8601String(),
      },
      {
        'id': 7,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 7)).toIso8601String(),
      },
      {
        'id': 8,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
      },
      {
        'id': 9,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 9)).toIso8601String(),
      },
      {
        'id': 10,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 10)).toIso8601String(),
      },
      {
        'id': 11,
        'current_temperature': generateInRange(22.0, 25.0),
        'current_humidity': generateInRange(50.0, 70.0),
        'current_ph': generateInRange(6.0, 7.0),
        'current_ec': generateInRange(600.0, 700.0),
        'timestamp':
            DateTime.now().subtract(Duration(days: 11)).toIso8601String(),
      },
    ];

    // Insert the data
    for (var record in dataToInsert) {
      await db.insert(
        'sensorReading',
        record,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Inserted record: $record'); // Debugging statement
    }
    try {
      print(
          'All data has been inserted into the sensorReadings table.'); // Debugging statement
    } catch (e) {
      print(
          'Failed to insert data into the Sensor Readings table: $e'); // Debugging statement for failure
    }
  }
}
