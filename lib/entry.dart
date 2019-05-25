import 'package:shared_preferences/shared_preferences.dart';

class Entry {
  static const String ENTRIES_LIST_ID = "confidant-entries";

  String title;
  String body;
  String dateTime;

  // constructor
  Entry({this.dateTime, this.title = "", this.body = ""});

  void save() async {
    dateTime ??= DateTime.now().toIso8601String();
    var sp = await SharedPreferences.getInstance();
    sp.setString('$dateTime-title', title);
    sp.setString('$dateTime-body', body);
    List<String> entryList = sp.getStringList(ENTRIES_LIST_ID) ?? [];
    // dart somehow does not have a proper way to not add duplicates to a list
    for (String s in entryList) {
      if (s == dateTime) {
        return;
      }
    }
    entryList.add(dateTime);
    sp.setStringList(ENTRIES_LIST_ID, entryList);
  }

  void delete() async {
    var sp = await SharedPreferences.getInstance();
    sp.setString('$dateTime-title', null);
    sp.setString('$dateTime-body', null);
    List<String> entryList = sp.getStringList(ENTRIES_LIST_ID) ?? [];
    entryList.remove('$dateTime');
    sp.setStringList(ENTRIES_LIST_ID, entryList);
  }


}