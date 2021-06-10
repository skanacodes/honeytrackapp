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
          'lastName TEXT'
          ')');
    });
  }

  // Insert employee on database
  createUser(User newUser) async {
    print('jsdjdsjdsjdsjds');
    // await deleteAllEmployees();
    final db = await database;
    final res = await db!.insert('User', newUser.toJson());
    //print(res);
    await getAllUser();
    print('jsdjdsjdsjdsjds');
    return res;
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
