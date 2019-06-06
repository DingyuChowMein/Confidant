import 'package:flutter/material.dart';

import 'package:confidant/page/listpage.dart';
import 'package:confidant/page/entrypage.dart';
import 'package:confidant/widget/scopebase.dart';

import "globals.dart" as globals;

void main() => runApp(Confidant());

class Confidant extends StatefulWidget {
  Confidant({
    Key key,
  }): super(key: key);

  @override
  ConfidantState createState() => new ConfidantState();
}

class ConfidantState extends State<Confidant> {
  static TextTheme textTheme = TextTheme(
    title: TextStyle(fontSize: 32, color: Colors.black),
    subtitle: TextStyle(fontSize: 14),
    body1: TextStyle(fontSize: 24),
    body2: TextStyle(fontSize: 18),
  );

  static ThemeData theme = ThemeData(
      primaryColor: globals.themeColor,
      textTheme: textTheme);

  @override
  void setState(fn) {
    theme = ThemeData(
      primaryColor: globals.themeColor,
      textTheme: textTheme);
    super.setState(fn);
    this.build(context);
  }

  @override
  Widget build(BuildContext context) {
    return ScopeBaseWidget(
        child: MaterialApp(
          title: 'Confidant',
          theme: theme,
          home: ListPage(),
          initialRoute: '/new_entry',
          routes: {
            '/new_entry': (context) => EntryPage.newEntry(),
            '/list': (context) => ListPage()
          },
        ));
  }
}

/*
class Confidant extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(
      primaryColor: Colors.orange,
      textTheme: TextTheme(
        title: TextStyle(fontSize: 32, color: Colors.white),
        subtitle: TextStyle(fontSize: 14),
        body1: TextStyle(fontSize: 24),
        body2: TextStyle(fontSize: 18),
      ));

    return ScopeBaseWidget(
        child: MaterialApp(
      title: 'Confidant',
      theme: theme,
      home: ListPage(),
      initialRoute: '/new_entry',
      routes: {
        '/new_entry': (context) => EntryPage.newEntry(),
        '/list': (context) => ListPage()
      },
    ));
  }
}*/

