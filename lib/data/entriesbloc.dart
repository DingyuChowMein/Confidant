import 'dart:async';
import 'package:confidant/data/database.dart';

// [B]usiness [Lo]gic [C]omponent Pattern
class EntriesBLoC {
  List<Entry> entryList;

  void refresh() async {
    List<Entry> entryList = await EntriesDatabase.get().getEntries();
    // sort it or else it comes out in a random order
    //entryList.sort((a, b) => a.dateTime.compareTo(b.dateTime));
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