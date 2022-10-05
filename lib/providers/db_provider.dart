import 'package:honeytrackapp/modals/harvesting_modal.dart';
import 'package:honeytrackapp/modals/inspection_modal.dart';

import 'package:honeytrackapp/modals/user_modal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart';

class DBProvider {
  static Database? _database;
  static final DBProvider db = DBProvider._();

  DBProvider._();

  Future<Database?> get database async {
    // If database exists, return database
    if (_database != null) return _database;

    // If database don't exists, create one
    _database = await initDB();

    return _database;
  }

  // Create the database and the Employee table
  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'honeytrack.db');

    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE User('
          'id INTEGER PRIMARY KEY,'
          'email TEXT,'
          'firstName TEXT,'
          'lastName TEXT,'
          'stationName TEXT,'
          'password TEXT'
          ')');

      await db.execute('CREATE TABLE Stats('
          'apiaries INTEGER,'
          'beekeepers INTEGER,'
          'dealers INTEGER,'
          'transitPass INTEGER'
          ')');

      await db.execute('CREATE TABLE Jobs('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'person_id TEXT,'
          'job_id TEXT,'
          'jobname TEXT,'
          'activity TEXT,'
          'hiveNo TEXT,'
          'tasktype TEXT,'
          'apiary_id TEXT,'
          'hive_attended TEXT,'
          'task_activity_id TEXT,'
          'role TEXT'
          ')');
      //   'observations': _expectedObservation!.join(","),
      // 'action_taken': _actionTaken!.join(","),
      // 'blooming_species': bloomingspecies,
      // 'other_action_taken': specifyActionTaken.toString(),
      // 'other_observations': specifyExpectedObservations.toString(),
      // 'expected_harvest_kg': expectedHarvest.toString(),
      // 'apiary_id': apiaryIds,
      // 'harvest_expected': _radioValue,
      // 'task_activity_id': widget.taskId,
      // 'is_complete': hiveAttended == int.parse(hiveTotal![0]) ? true : false,
      // 'hive_code': _qrInfo,
      // 'colonization_date': formattedDate,

      await db.execute('CREATE TABLE Inspections('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'person_id TEXT,'
          'task_activity_id TEXT,'
          'inspection_season TEXT,'
          'general_condition TEXT,'
          'hive_code TEXT,'
          'colonization_date TEXT,'
          'observations TEXT,'
          'specify_observation TEXT,'
          'action_taken TEXT,'
          'specify_action TEXT,'
          'blooming_species TEXT,'
          'expected_for_harvest TEXT,'
          'expected_harvest_kg TEXT,'
          'apiary_id TEXT,'
          'apiary_name TEXT,'
          'img1 TEXT,'
          'img2 TEXT,'
          'inserting_way TEXT,'
          'upload_status TEXT'
          ')');
      await db.execute('CREATE TABLE Harvesting('
          'id INTEGER PRIMARY KEY AUTOINCREMENT,'
          'person_id TEXT,'
          'job_id TEXT,'
          'apiary_name TEXT,'
          'hive_code TEXT,'
          'no_of_hives TEXT,'
          'weight_of_comb_honey TEXT,'
          'moisture_content TEXT,'
          'weather_condition TEXT,'
          'equipment_used TEXT,'
          'other_bee_product TEXT,'
          'beevenom_weight TEXT,'
          'pollenweight TEXT,'
          'propolisweight TEXT,'
          'royaljelly_weight TEXT,'
          'transportation_means TEXT,'
          'otherMeans TEXT,'
          'transportation_time TEXT,'
          'stationapiary TEXT,'
          'harvesting_cost INTEGER,'
          'harvestedby_name TEXT,'
          'harvestedby_title TEXT,'
          'harvestedby_date TEXT,'
          'certifiedby_name TEXT,'
          'certifiedby_title TEXT,'
          'certifiedby_date TEXT,'
          'img1 TEXT,'
          'img2 TEXT,'
          'upload_status TEXT'
          ')');
    });
  }

  // Insert employee on database
  createUser(User newUser) async {
    try {
      //  print('jsdjdsjdsjdsjds');
      // await deleteAllEmployees();
      final db = await database;
      final res = await db!.insert('User', newUser.toJson());
      print(res);
      var x = await getAllUser();
      print(x);
      return res;
    } catch (e) {
      print(e.toString());
    }
  }

  createStats(var newstats) async {
    print('jsdjdsjdsjdsjds');
    await deleteAllStats();
    final db = await database;
    final res = await db!.insert('Stats', newstats);
    //print(res);
    await getstats();
    //print('jsdjdsjdsjdsjds');
    return res;
  }

  createJobs(var newJobs) async {
    // print('jsdjdsjdsjdsjds');
    //  await deleteAllStats();
    final db = await database;
    final res = await db!.insert('Jobs', newJobs);
    //print(res);
    // await getJobs();

    return res;
  }

  Future<String> insertSingleApiaryInspection(InspectionModal inspect) async {
    // Get a reference to the database.
    // print("am in inserting");
    final db = await database;
    try {
      await db!.insert(
        'Inspections',
        inspect.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      // await getsta();
      return 'Success';
    } catch (e) {
      print('error while inserting data');
      return 'failed';
    }
  }

  Future<String> hiveattendedNumber(jobId) async {
    print("am in inserting");
    final db = await database;
    try {
      final res = await db!
          .rawQuery('SELECT hive_attended FROM Jobs WHERE job_id=?', [jobId]);
      print(res[0]["hive_attended"]);
      return res[0]["hive_attended"].toString();
    } catch (e) {
      print(e.toString() + 'error while updating data');
      return "fail";
    }
  }

  Future<String> UpdateHiveAttended(jobId, value) async {
    // Get a reference to the database.
    print("am in inserting");
    final db = await database;
    try {
      int count = await db!.rawUpdate(
          'UPDATE Jobs SET hive_attended = ? WHERE job_id = ?', [value, jobId]);
      print(count);

      final res = await db
          .rawQuery('SELECT hive_attended FROM Jobs WHERE job_id=?', [jobId]);
      print(res[0]["hive_attended"]);
      return res[0]["hive_attended"].toString();
    } catch (e) {
      print(e.toString() + 'error while updating data');
      return "fail";
    }
  }

  Future<String> insertSingleHarvestData(HarvestingModal harvest) async {
    // Get a reference to the database.
    print("am in inserting");
    final db = await database;
    try {
      await db!.insert(
        'Harvesting',
        harvest.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      //  await getHarvesting();
      return 'Success';
    } catch (e) {
      print('error while inserting data');
      return 'failed';
    }
  }

  Future<int> deleteAllStats() async {
    final db = await database;
    final res = await db!.rawDelete('DELETE FROM Stats');

    return res;
  }

  Future<int?> checkId(String email) async {
    final db = await database;
    var x = await db!.rawQuery('SELECT * FROM User WHERE email=?', [email]);
    print(x);
    final res =
        await db.rawQuery('SELECT COUNT(*) FROM User WHERE email=?', [email]);
    print(res);
    final count = Sqflite.firstIntValue(res);
    // print(count.toString() + "anskfdksnnkkv");

    return count;
  }

  Future<int?> checkJob(String jobId) async {
    final db = await database;

    final res =
        await db!.rawQuery('SELECT COUNT(*) FROM Jobs WHERE job_id=?', [jobId]);

    final count = Sqflite.firstIntValue(res);
    print(count);

    return count;
  }

  Future<int?> countTasks(String id) async {
    final db = await database;

    final res =
        await db!.rawQuery("SELECT COUNT(*) FROM Jobs WHERE person_id=?", [id]);

    final count = Sqflite.firstIntValue(res);
    print(count);

    return count;
  }

  Future getsta(String jobId, String userId) async {
    final db = await database;
    final res = await db!
        .rawQuery("SELECT * FROM Inspections  WHERE job_id=? and person_id=?", [
      jobId,
      userId,
    ]);
    print(res);

    return res;
  }

  Future getHarvesting(String jobId, String userId) async {
    final db = await database;
    final res = await db!
        .rawQuery("SELECT * FROM Harvesting WHERE job_id=? and person_id=?", [
      jobId,
      userId,
    ]);
    print(res);

    return res;
  }

  Future getstats() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM Stats");
    print(res);

    return res;
  }

  Future getJobs(String id) async {
    final db = await database;
    final res =
        await db!.rawQuery("SELECT * FROM Jobs WHERE person_id=?", [id]);
    print(res);

    return res;
  }

  Future<String> verifyUser(String email, String password) async {
    final db = await database;
    final res = await db!.rawQuery('SELECT * FROM User WHERE email=?', [email]);
    print(res);
    if (res[0]['email'] == email && res[0]['password'] == password) {
      return 'success';
    } else {
      return 'fail';
    }
  }

  Future getUserData(String email) async {
    try {
      print(email);
      final db = await database;

      final res =
          await db!.rawQuery('SELECT * FROM User WHERE email=?', [email]);
      print(res);
      print("data");
      return res;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<List<InspectionModal>> getAllTreesDetails() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM Inspections");

    List<InspectionModal> list = res.isNotEmpty
        ? res.map((c) => InspectionModal.fromJson(c)).toList()
        : [];

    return list;
  }

  Future<List<User>> getAllUser() async {
    final db = await database;
    final res = await db!.rawQuery("SELECT * FROM User");
    print(res);
    List<User> list =
        res.isNotEmpty ? res.map((c) => User.fromJson(c)).toList() : [];
    print(list);
    return list;
  }
}
