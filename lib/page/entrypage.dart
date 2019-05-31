import 'package:flutter/material.dart';

import 'package:confidant/data/database.dart';
import 'package:confidant/widget/scopebase.dart';
import 'package:confidant/widget/radarlove.dart';
import 'package:confidant/widget/entrytextinput.dart';
import 'package:confidant/emotion/emotions.dart';

class EntryPage extends StatefulWidget {
  EntryPage(this.entry);

  EntryPage.newEntry() : entry = new Entry();

  final Entry entry;

  @override
  _EntryPageState createState() => _EntryPageState(entry);
}

class _EntryPageState extends State<EntryPage> {
  Entry entry;

  _EntryPageState(this.entry);

  // Create a global key that will uniquely identify the Form widget and allow
  // us to validate the form
  var _formKey = GlobalKey<FormState>();

  void saveEntry() {
    // calls 'validate' on all widgets in current state
    _formKey.currentState.validate();
    // calls 'save' on all widgets in current state
    _formKey.currentState.save();
    entry.save();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          saveEntry();
          ScopeBaseWidget.of(context).bloc.refresh();
          return true;
        },
        child: Form(
            key: _formKey,
            child: Scaffold(
              /** TODO: EMOTIONAL ANALYSIS INFO STUFF **/
              endDrawer: Drawer(
                  child: Column(children: <Widget>[
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(30),
                  child: Text('Emotional Analysis',
                      style: Theme.of(context).textTheme.headline),
                ),
                new ListTile(
                    title: new Text("Beautiful info goes here"), onTap: () {}),
                Center(
                  child: Container(
                    child: EmotionalRadarChart(
                      emotionSet: EmotionSet(
                          angerIntensity: 5,
                          fearIntensity: 4,
                          joyIntensity: 8,
                          tentativeIntensity: 4,
                          confidentIntensity: 9,
                          analyticalIntensity: 5),
                    ),
                  ),
                )
              ])),
              appBar: AppBar(
                title: Row(
                    //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: TextFormField(
                              initialValue:
                                  entry.title == "" ? "Untitled" : entry.title,
                              onSaved: (s) => entry.title = s,
                              validator: (s) =>
                                  s.length > 2 ? null : 'Give it a title',
                              textCapitalization: TextCapitalization.sentences,
                              style: Theme.of(context).textTheme.title,
                              decoration: InputDecoration(border: InputBorder.none),
                            )),
                      )
                    ]),
              ),
              body: EntryTextInput(
                  textFormField: TextFormField(
                initialValue: entry.body,
                onSaved: (s) => entry.body = s,
                validator: (s) => s.length > 2 ? null : 'Give it a body',
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: Theme.of(context).textTheme.body1,
                decoration: InputDecoration.collapsed(hintText: 'Type'),
              )),
              bottomNavigationBar: BottomAppBar(
                color: Theme.of(context).buttonColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () => saveEntry(), //Save Button
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.save,
                              color: Theme.of(context).iconTheme.color),
                          SizedBox(width: 3),
                          Text('Save')
                        ],
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        entry.delete();
                        Navigator.pop(context);
                      }, //Save Button
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.delete,
                              color: Theme.of(context).iconTheme.color),
                          SizedBox(width: 3),
                          Text('Delete')
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )));
  }
}
