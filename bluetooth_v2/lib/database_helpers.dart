import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
final String tableEntries = 'entries';
final String columnId = 'id';
final String columnDate = 'date';
final String columnPersons = 'persons';
final String columnLocations = 'locations';
final String columnOpnv = 'opnv';

// data model class
class Entry {
  int id;
  String date;
  String persons;
  String locations;
  String opnv;

  Entry();

  // convenience constructor to create a Word object
  Entry.fromMap(Map<String, dynamic> map) {

    id = map[columnId];
    date = map[columnDate];
    persons = map[columnPersons];
    locations = map[columnLocations];
    opnv = map[columnOpnv];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDate: date,
      columnPersons: persons,
      columnLocations: locations,
      columnOpnv: opnv
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "MyDatabase.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableEntries (
                $columnId INTEGER PRIMARY KEY,
                $columnDate TEXT NOT NULL,
                $columnPersons TEXT,
                $columnLocations TEXT,
                $columnOpnv TEXT
                
              )
              ''');
  }

  // Database helper methods:
  Future<int> insert(Entry entry) async {
    Database db = await database;
    int id = await db.insert(tableEntries, entry.toMap());
    return id;
  }

  Future<Entry> queryWord(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableEntries,
        columns: [
          columnId,
          columnDate,
          columnPersons,
          columnLocations,
          columnOpnv
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Entry.fromMap(maps.first);
    }
    return null;
  }

  // get all rows
  Future<List<Map>> queryAllRows() async {
    Database db = await database;
    List<Map> maps = await db.query(tableEntries);
    if (maps.length > 0) {
      // maps.forEach((row) => {
      // Entry.fromMap(row)
         
      // });


      return maps;
      //   maps.forEach((row) => {
      //     print(row),
      //     // Entry.fromMap(row)});
    }
    return null;
  }

  deleteAll() async {
    final db = await database;
    db.delete(tableEntries);
  }

  // TODO: queryAllWords()
  // TODO: delete(int id)
  // TODO: update(Word word)
}
