import 'dart:async';
import 'package:confidant/database/entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

// [B]usiness [Lo]gic [C]omponent Pattern
class EntriesBLoC {
  List<Entry> entryList;

  /** TODO: PROPER DATABASE STUFF**/

  // PLACEHOLDER DATABASE MANAGEMENT
  void refresh() async {
    var sp = await SharedPreferences.getInstance();
    entryList = [];
    if (sp.getStringList(Entry.ENTRIES_LIST_ID) != null) {
      for (var dt in sp.getStringList(Entry.ENTRIES_LIST_ID)) {
        entryList.add(Entry(dateTime: dt,
            title: sp.getString('$dt-title'),
            body: sp.getString('$dt-body')));
      }
    }
    listSink.add(entryList);
  }

  static final EntriesBLoC _singleton = EntriesBLoC._create();

  var _streamController = StreamController<String>();
  var _listStreamController = StreamController<List<Entry>>();

  Stream<List<Entry>> get listStream => _listStreamController.stream;
  Stream<String> get stream => _streamController.stream;

  Sink<List<Entry>> get listSink => _listStreamController.sink;
  Sink<String> get sink => _streamController.sink;

  EntriesBLoC._create();

  factory EntriesBLoC() {
    return _singleton;
  }
  
  void dispose(){
    _listStreamController.close();
    _streamController.close();
    sink.close();
  }

}