import 'package:flutter/material.dart';

import 'package:confidant/page/list.dart';
import 'package:confidant/page/entrypage.dart';
import 'package:confidant/database/scopebase.dart';

// probalby maybe i guess ought to go in different place
const num NUM_CHARS_IN_DATE = 10;

void main() => runApp(Confidant());

class Confidant extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopeBaseWidget(
        child: MaterialApp(
      title: 'Confidant',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: TextTheme(
          title: TextStyle(fontSize: 32, color: Colors.white),
          body1: TextStyle(fontSize: 18),
        ),
      ),
      home: ListPage(),
      initialRoute: '/new_entry',
      routes: {
        '/new_entry': (context) => EntryPage.newEntry(),
        '/list': (context) => ListPage()
      },
    ));
  }
}

