import 'package:flutter/material.dart';

import 'list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confidant',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        textTheme: TextTheme(
          title: TextStyle(fontSize: 32, color: Colors.white),
          body1: TextStyle(fontSize: 18),
        ),
      ),
      home: NotePage(title: 'Confidant'),
    );
  }
}

class NotePage extends StatefulWidget {
  NotePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  static const num NUM_CHARS_IN_DATE = 10;
  String nowString =
  new DateTime.now().toIso8601String().substring(0, NUM_CHARS_IN_DATE);
  TextEditingController _titleController;

  _NotePageState() {
    _titleController = new TextEditingController(text: nowString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListPage()));
                },
              ),
              Expanded(
                child: TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  style: Theme
                      .of(context)
                      .textTheme
                      .title,
                  decoration: InputDecoration(border: InputBorder.none),
                ),
              )
            ]),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        height: double.infinity,
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              children: <Widget>[
                TextFormField(
                  //validator: (s) => s.length > 2 ? null : 'Write Some Note', // i do not know what this is
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: Theme
                      .of(context)
                      .textTheme
                      .body1,
                  decoration: InputDecoration.collapsed(hintText: 'Write Note'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
