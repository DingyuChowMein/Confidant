import 'package:flutter/material.dart';

import 'main.dart';

class ListPage extends StatefulWidget {
  ListPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Confidant'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Make new note'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}