import 'package:flutter/material.dart';

import 'package:confidant/page/list.dart';
import 'package:confidant/page/entrypage.dart';
import 'package:confidant/widget/scopebase.dart';

void main() => runApp(Confidant());

class Confidant extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScopeBaseWidget(
        child: MaterialApp(
      title: 'Confidant',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        textTheme: TextTheme(
          title: TextStyle(fontSize: 32, color: Colors.white),
          subtitle: TextStyle(fontSize: 14),
          body1: TextStyle(fontSize: 24),
          body2: TextStyle(fontSize: 18),
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

