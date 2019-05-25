import 'package:flutter/material.dart';

import 'list.dart';
import 'entry.dart';
import 'scopebase.dart';

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
      initialRoute: '/entry',
      routes: {
        '/entry': (context) => EntryPage(new Entry()),
        '/list': (context) => ListPage()
      },
    ));
  }
}

class EntryPage extends StatefulWidget {
  EntryPage(this.entry);

  final Entry entry;

  @override
  _EntryPageState createState() => _EntryPageState(entry);
}

class _EntryPageState extends State<EntryPage> {
  static const num NUM_CHARS_IN_DATE = 10;
  String nowString =
      new DateTime.now().toIso8601String().substring(0, NUM_CHARS_IN_DATE);
  Entry entry;
  String initialBody;
  String initialTitle;

  _EntryPageState(this.entry) {
    initialBody = entry.body;
    initialTitle = entry.title;
  }

  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  var _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          ScopeBaseWidget.of(context).bloc.refresh();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      initialValue: initialTitle,
                      onSaved: (s) => entry.title = s,
                      validator: (s) => s.length > 2 ? null : 'Give it a title',
                      // i do not know what this is
                      textCapitalization: TextCapitalization.sentences,
                      style: Theme.of(context).textTheme.title,
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
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      initialValue: initialBody,
                      onSaved: (s) => entry.body = s,
                      validator: (s) => s.length > 2 ? null : 'Give it a body',
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: Theme.of(context).textTheme.body1,
                      decoration:
                          InputDecoration.collapsed(hintText: 'Write Note'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).buttonColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  onPressed: () {
                    // this calls 'validate' on all widgets in current state
                    if (_formKey.currentState.validate()) {
                      // calls 'save' on all widgets in current state
                      _formKey.currentState.save();
                      entry.save();
                    }
                  }, //Save Button
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.save,
                          color: Theme.of(context).iconTheme.color),
                      SizedBox(width: 3),
                      Text('Save')
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
