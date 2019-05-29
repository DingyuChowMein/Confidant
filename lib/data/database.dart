import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

const String TABLE_NAME = "entries";
const String ID = "id";
const String TITLE = "title";
const String BODY = "body";
const String DATETIME = "datetime";

const num NUM_CHARS_IN_DATE = 10;

class EntriesDatabase {
  static final EntriesDatabase entriesDatabase =
      new EntriesDatabase._instance();
  Database _db;

  EntriesDatabase._instance();

  static EntriesDatabase get() {
    return entriesDatabase;
  }

  Future _init() async {
    Directory directory = await getApplicationDocumentsDirectory();
    _db = await openDatabase(join(directory.path, "entries.db"), version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''CREATE TABLE $TABLE_NAME ( 
          $DATETIME STRING PRIMARY KEY, 
          $TITLE TEXT NOT NULL,
          $BODY TEXT NOT NULL)''');
    });
  }

  Future<Database> _getDb() async {
    if (_db == null) await _init();
    return _db;
  }

  Future<int> insertOrUpdateEntry(Entry entry) async {
    var db = await _getDb();
    return await db.rawInsert(
        'INSERT OR REPLACE INTO '
        '$TABLE_NAME($DATETIME, $TITLE, $BODY)'
        ' VALUES(?, ?, ?)',
        [entry.dateTime, entry.title, entry.body]);
  }

  Future<List<Entry>> getEntries() async {
    var db = await _getDb();
    List<Map> entities = await db.rawQuery("select * from $TABLE_NAME");
    return entities.map((map) => new Entry.fromMap(map)).toList();
  }

  Future deleteEntry(String dateTime) async {
    var db = await _getDb();
    await db.delete(TABLE_NAME, where: "$DATETIME = ?", whereArgs: [dateTime]);
  }

  Future close() async {
    var db = await _getDb();
    return db.close();
  }
}

class Entry {
  String title;
  String body;
  String dateTime;

  Entry({this.dateTime, this.title = "", this.body = ""});

  Entry.fromMap(Map map) {
    dateTime = map[DATETIME];
    title = map[TITLE];
    body = map[BODY];
  }

  void save() async {
    DateTime now = DateTime.now();
    dateTime ??= now.toIso8601String();
    EntriesDatabase.get().insertOrUpdateEntry(this);
  }

  void delete() async {
    EntriesDatabase.get().deleteEntry(dateTime);
  }

}
