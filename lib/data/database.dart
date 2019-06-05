import 'dart:async';
import 'dart:io';
import 'dart:core';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'package:confidant/authentication/portal.dart';
import 'package:confidant/emotion/tonejson.dart';

const String TABLE_NAME = "entries";
const String ID = "id";
const String TITLE = "title";
const String BODY = "body";
const String DATETIME = "datetime";
const String PIN_PROTECTED = "pin_protected";

const num NUM_CHARS_IN_DATE = 10;

class EntriesDatabase {
  static final EntriesDatabase entriesDatabase =
      new EntriesDatabase._instance();
  Database _db;

  List<Entry> fbEntries = new List();

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
          $BODY TEXT NOT NULL,
          $PIN_PROTECTED TEXT NOT NULL)''');
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
        '$TABLE_NAME($DATETIME, $TITLE, $BODY, $PIN_PROTECTED)'
        ' VALUES(?, ?, ?, ?)',
        [entry.dateTime, entry.title, entry.body, entry.pinProtected]);
  }

  Future<List<Entry>> getEntries() async {
    var db = await _getDb();
    List<Map> entities =
        await db.rawQuery("SELECT * FROM $TABLE_NAME ORDER BY $DATETIME");
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
  static const String TRUE_BIT = '1';

  String key;
  String userId;

  String title;
  String body;
  String dateTime;
  bool pinProtected;
  //Map<String, dynamic> toneJson;

  FirebaseDatabase _fdb = FirebaseDatabase.instance;

  Entry(
      {this.dateTime,
      this.title = "",
      this.body = "",
      this.userId = "",
      this.pinProtected = false});

  Entry.fromMap(Map map) {
    dateTime = map[DATETIME];
    title = map[TITLE];
    body = map[BODY];
    pinProtected = map[PIN_PROTECTED] == TRUE_BIT;
  }

  Entry.fromSnapshot(DataSnapshot snap) {
    dateTime = snap.key;
    title = snap.value[TITLE];
    body = snap.value[BODY];
    pinProtected = snap.value[PIN_PROTECTED];
  }

  Map<String, dynamic> toJson() {
    return {
      TITLE: title,
      BODY: body,
      PIN_PROTECTED: pinProtected
    };
  }

  void save() async {
    DateTime now = DateTime.now();
    dateTime ??= now.toIso8601String().replaceAll('.', '*');
    EntriesDatabase.get().insertOrUpdateEntry(this);
  }

  void upload(String userId) async {
    if (userId == LOGGED_OUT_POP) {
      print("can't upload, not signed in"); // todo: take to sign in page
      return;
    }
    print("trying to upload this dateTime: " + dateTime);
    _fdb.reference().child(userId).child(dateTime).set(toJson());
  }

  void delete() async {
    EntriesDatabase.get().deleteEntry(dateTime);
  }

  String bodyToUri() {
    return Uri.encodeFull(body);
  }

  Future<EmotionalAnalysis> analyse() async {
    final String userPass = "apikey:7WAbN9QUhcR8QlNjbI7N3N4jWonTh1nRF59gx2cv-sjU";
    final String args = '/v3/tone?version=2017-09-21&text=';
    final String bodyUri = bodyToUri();
    final String url = 'https://$userPass@gateway-lon.watsonplatform.net/tone-analyzer/api$args$bodyUri';

    final response = await http.get(url);
    final responseJson = json.decode(response.body); // different body

    //final String response = '''{document_tone: {tones: [{score: 0.707864, tone_id: anger, tone_name: Anger}]}, sentences_tone: [{sentence_id: 0, text: i hate you, tones: [{score: 0.931034, tone_id: fear, tone_name: Fear}, {score: 1.0, tone_id: anger, tone_name: Anger}, {score: 0.916667, tone_id: sadness, tone_name: Sadness}]}, {sentence_id: 1, text: you are bad, tones: [{score: 0.931034, tone_id: fear, tone_name: Fear}, {score: 0.931034, tone_id: anger, tone_name: Anger}, {score: 0.916667, tone_id: sadness, tone_name: Sadness}]}, {sentence_id: 2, text: you suck , tones: []}, {sentence_id: 3, text: i am unhappy, tones: [{score: 0.931034, tone_id: anger, tone_name: Anger}, {score: 0.916667, tone_id: sadness, tone_name: Sadness}]}]}''';

    print(responseJson.toString());

    print('\n\n');

    EmotionalAnalysis analysis = EmotionalAnalysis.fromJson(responseJson);
    print(analysis.toString());
    return analysis;
  }
}
